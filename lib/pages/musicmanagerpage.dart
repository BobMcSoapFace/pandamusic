import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pandamusic/components/downloadinterface.dart';
import 'package:pandamusic/components/playlistviewer/playlistviewer.dart';
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
  MusicSortType videoSortType = MusicSortType.name;
  TextEditingController folderController = TextEditingController();
  TextEditingController urlController = TextEditingController();
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
    _directoryStream = getDirectoryVideos(path);
    _directoryStreamListener = _directoryStream!.listen((data){
      setState((){
        directoryVideos.add(data);
        videoList.add(data);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    videoManager.videoSortTypeStream.listen((sortType)=>setState(() {
      videoSortType = sortType;
      sortMusic(List.from(directoryVideos), sortType).then(
        (newList) async {
            int ni = 0;
            videoList = [];
            while(videoSortType == sortType && ni < newList.length){
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
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}