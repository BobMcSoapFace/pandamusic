import 'dart:io';

import 'package:flutter/material.dart';
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
  final AppVideoManager videoManager =  AppVideoManager();
  late final Stream<FileSystemEntity> directoryStream;
  final List<FileSystemEntity> directoryVideos = [];
  List<FileSystemEntity> videoList = [];
  MusicSortType videoSortType = MusicSortType.name;
  @override
  void initState() {
    super.initState();
    directoryStream = getDirectoryVideos("C:/Users/riley/Music/music")..listen((data){
      setState((){
        directoryVideos.add(data);
        videoList.add(data);
      });
    });
    videoManager.videoSortTypeStream.listen((sortType)=>setState(() {
      videoSortType = sortType;
      sortMusic(List.from(directoryVideos), sortType).then(
        (newList) async {
            int ni = 0;
            videoList = [];
            while(videoSortType == sortType && ni < newList.length){
              setState(()=>videoList.add(newList[ni]));
              ni++;
              await Future.delayed(Duration(milliseconds: 20));
            }
        }
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    AppPlaylistPlayer playlistPlayer = AppPlaylistPlayer(
      videoList: videoList.map((file)=>file.path).toList(),
      manager: videoManager,
      isFile: true
    );
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
                  if(videoList.isNotEmpty) playlistPlayer,
                  Flexible(
                    flex: 3,
                    child: PlaylistViewer(
                      videoList: videoList,
                      videoManager: playlistPlayer.manager,
                      sortType: videoSortType,
                      setSortType: (type) => videoManager.emitSort(type),
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
            )
          )
        ],
      ),
    );
  }
}