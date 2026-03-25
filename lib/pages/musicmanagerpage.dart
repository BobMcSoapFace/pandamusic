import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstore/localstore.dart';
import 'package:pandamusic/components/downloadinterface.dart';
import 'package:pandamusic/components/playlistviewer/playlistviewer.dart';
import 'package:pandamusic/data/colors.dart';
import 'package:pandamusic/data/streams/videomanager.dart';
import 'package:pandamusic/components/videoplayer/videoplayer.dart';
import 'package:pandamusic/data/musicdirectory.dart';
import 'package:pandamusic/data/responsive.dart';

class MusicManagerPage extends StatefulWidget {
  const MusicManagerPage({super.key});
  
  @override
  MusicManagerPageState createState() => MusicManagerPageState();
}
class MusicManagerPageState extends State<MusicManagerPage> {
  static const sortLoadingSpeed = 10;
  final AppVideoManager videoManager =  AppVideoManager();
  List<FileSystemEntity> directoryVideos = [];
  Stream<FileSystemEntity>? _directoryStream;
  StreamSubscription<FileSystemEntity>? _directoryStreamListener;
  List<FileSystemEntity> videoList = [];
  List<MapEntry<String, int>> directoriesList = [];
  MusicSortType videoSortType = MusicSortType.name;
  TextEditingController folderController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  String? currentDirectory;
  bool shuffle = false;

  void loadDirectory(
    String? path
  ) async {
    if(path == null || path.isEmpty){
      setState(() {
        _directoryStreamListener!.cancel();
        directoryVideos = [];
        videoList = [];
      });
      return;
    }
    if(!await Directory(path).exists()){
      return;
    }
    if(_directoryStreamListener != null){
      setState(() {
        _directoryStreamListener!.cancel();
        directoryVideos = [];
        videoList = [];
      });
    }
    currentDirectory = path;
    _directoryStream = getDirectoryVideos(path);
    _directoryStreamListener = _directoryStream!.listen((data){
      setState((){
        directoryVideos.add(data);
        videoList.add(data);
      });
    });
    MapEntry<String, dynamic>? directoryData = (await Localstore.instance.collection(DIRECTORY_COLLECTION).get())?.entries.where(
      (entry)=>entry.value["path"] == path
    ).firstOrNull;
    print((await Localstore.instance.collection(DIRECTORY_COLLECTION).get())?.entries);
    print(directoryData != null ? (directoryData.value["times"] + 1) : 1);
    await Localstore.instance.collection(DIRECTORY_COLLECTION).doc(directoryData?.key).set({
      "times": directoryData != null ? (directoryData.value["times"] + 1) : 1,
      "path": path
    }, SetOptions(merge: true));
    refreshDirectories();
  }
  void refreshDirectories() async {
    var newDirs = (await Localstore.instance.collection(DIRECTORY_COLLECTION).get());
    setState(() {
      directoriesList = newDirs?.entries.map((entry)=>
        MapEntry(entry.value["path"] as String, entry.value["times"] as int)).toList() ?? []
      ..sort((a,b)=>a.value-b.value);
    });
  }

  @override
  void initState() {
    super.initState();
    refreshDirectories();
    videoManager.videoSortTypeStream.listen((sortType)=>setState(() {
      videoSortType = sortType;
      String? sortedDirectory = currentDirectory;
      sortMusic(List.from(directoryVideos), sortType).then(
        (newList) async {
            int ni = 0;
            videoList = [];
            while(videoSortType == sortType && ni < newList.length && (sortedDirectory == null || sortedDirectory == currentDirectory)){
              setState(()=>videoList.add(newList[ni]));
              ni++;
              await Future.delayed(Duration(milliseconds: sortLoadingSpeed));
            }
        }
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            flex: Responsive.isDesktop(context) ? 1 : 2,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6
              ),
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                direction: Axis.vertical,
                children: [
                  if(videoList.isNotEmpty) AppPlaylistPlayer(
                    videoList: videoList.map((file)=>file.path).toList(),
                    manager: videoManager,
                    isFile: true,
                    shuffle: shuffle,
                  ),
                  Flexible(
                    flex: 3,
                    child: PlaylistViewer(
                      videoList: videoList,
                      videoManager: videoManager,
                      sortType: videoSortType,
                      setSortType: (type) => videoManager.emitSort(type), 
                      shuffle: shuffle, 
                      setShuffle: (bool p1)=>setState(()=>shuffle=p1),
                    )
                  )
                ],
              ),
            )
          ),
          Flexible(
            flex: Responsive.isDesktop(context) ? 3 : 
              Responsive.isTablet(context) ? 4 : 2,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  DownloadInterface(
                    folderController: folderController, 
                    urlController: urlController, 
                    loadFolder: () {
                      loadDirectory(folderController.text);
                    }, 
                    downloadUrl: () {
                      downloadPlaylistVideos(
                        urlController.text, 
                        folderController.text
                      ).then((result){
                        print(result);
                      });
                    },
                  ),
                  Expanded(
                      child: GridPaper(
                        color: AppColor.scheme(context).tertiary.withAlpha(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          child: ListView(
                            children: [
                              SizedBox(height: 30,),
                              Text("Media",
                                style: GoogleFonts.googleSans(
                                  color: AppColor.scheme(context).primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30,
                                ),
                              ),
                              SizedBox(height: 10,),
                              ...directoriesList.map((entry)=>
                                Material(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: ()=>loadDirectory(entry.key),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: AppColor.scheme(context).surface,
                                        border: Border.all(
                                          width: 1.5,
                                          color: AppColor.scheme(context).primary
                                        )
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth: 200
                                      ),
                                      margin: EdgeInsets.symmetric(
                                        vertical: 8.0
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            entry.key,
                                            style: GoogleFonts.googleSans(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.scheme(context).primary
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}