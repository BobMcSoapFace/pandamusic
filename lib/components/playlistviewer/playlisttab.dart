import 'dart:io';
import 'dart:typed_data';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pandamusic/data/colors.dart';

class PlayListTab extends StatefulWidget {
  final FileSystemEntity videoFile;
  final bool isSelectedVideo;
  final void Function() playVideo;
  const PlayListTab({
    super.key, 
    required this.videoFile, 
    required this.playVideo, 
    this.isSelectedVideo = false,
  });
  @override
  PlaylistTabState createState() => PlaylistTabState();
}
class PlaylistTabState extends State<PlayListTab> {
  static final plugin = FcNativeVideoThumbnail();
  static final Map<String, Uint8List> thumbnailMap = {};
  Uint8List? videoThumbnail;

  @override
  void initState() {
    super.initState();
    if(!thumbnailMap.containsKey(widget.videoFile.path)){
      plugin.saveThumbnailToBytes(
        srcFile: widget.videoFile.path.replaceAll("/", "\\"),
        width: 50,
        height: 50,
        quality: 70, 
        format: "jpeg",
      ).then(
        (bytes){
          if(bytes==null || !mounted){
            return;
          }
          thumbnailMap[widget.videoFile.path] = bytes; 
          setState(() {
            videoThumbnail=bytes;
          });
        }
      );
    } else {
      setState(() {
        videoThumbnail = thumbnailMap[widget.videoFile.path];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.isSelectedVideo ? Colors.grey.withAlpha(50) : Colors.transparent,
      child: InkWell(
        onTap: ()=>widget.playVideo(),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: !widget.isSelectedVideo ? AppColor.scheme(context).primary : AppColor.scheme(context).surface,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8
          ),
          child: Flex(
            spacing: 12,
            direction: Axis.horizontal,
            children: [
              if(videoThumbnail!=null) Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 1,
                      color: AppColor.scheme(context).onPrimary
                    )
                  ),
                  child: Material(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      key: Key(widget.videoFile.path),
                      videoThumbnail!,
                    ),
                  ),
                )
              ),
              Flexible(
                flex: 4,
                child: Text(widget.videoFile.path.split('\\').last,
                  key: Key(widget.videoFile.path),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.googleSans(
                    color: !widget.isSelectedVideo ? AppColor.scheme(context).onPrimary : AppColor.scheme(context).primary,
                    fontWeight: !widget.isSelectedVideo ? null : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          )
        ),
      )
    );
  }

}