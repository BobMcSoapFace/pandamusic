import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pandamusic/components/playlistviewer/playlisttab.dart';
import 'package:pandamusic/data/streams/videomanager.dart';
import 'package:pandamusic/data/colors.dart';

class PlaylistViewer extends StatefulWidget {
  final List<FileSystemEntity> videoList;
  final AppVideoManager videoManager;
  final MusicSortType sortType;
  final void Function(MusicSortType) setSortType;
  const PlaylistViewer({
    super.key, 
    required this.videoList, 
    required this.videoManager, 
    required this.sortType, 
    required this.setSortType
  });
  @override
  State<StatefulWidget> createState() => PlaylistViewerState();

}
class PlaylistViewerState extends State<PlaylistViewer>{
  late StreamSubscription<int> _indexListener;
  final ScrollController _scrollController = ScrollController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _indexListener = widget.videoManager.videoIndexStream.listen((index)=>
      setState(()=>
        currentIndex=index
      )
    );
  }
  @override
  void dispose() {
    super.dispose();
    _indexListener.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.scheme(context).surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 5,
          color: AppColor.scheme(context).primary
        )
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: AppColor.scheme(context).primary,
              border: Border.all(
                width: 4,
                color: AppColor.scheme(context).primary,
                strokeAlign: BorderSide.strokeAlignOutside
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(200),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      var newSortType = MusicSortType.values[
                        MusicSortType.values.indexOf(widget.sortType)<MusicSortType.values.length-1?
                        MusicSortType.values.indexOf(widget.sortType)+1 : 0
                      ];
                      widget.setSortType(newSortType);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            color: AppColor.scheme(context).onPrimary,
                            size: 16,
                          ),
                          Text(musicSortTypeToName(widget.sortType),
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              color: AppColor.scheme(context).onPrimary,
                              fontWeight: FontWeight.w500
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                )
              ],
            )
          ),
          Expanded(
            child: GridPaper(
              color: AppColor.scheme(context).tertiary.withAlpha(100),
              child: Container(
                padding: EdgeInsets.all(20),
                child: ListView(
                  controller: _scrollController,
                  itemExtent: 50,
                  children: widget.videoList.asMap().entries.map((entry)=>
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 1),
                      child: PlayListTab(
                        key: Key(entry.value.path),
                        videoFile: entry.value,
                        playVideo: ()=>widget.videoManager.emitIndex(entry.key),
                        isSelectedVideo: entry.key==currentIndex,
                      ),
                    )
                  ).toList(),
                ),
              )
            ),
          )
        ],
      )
    );
  }

}