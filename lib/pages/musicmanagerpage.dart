import 'package:flutter/material.dart';
import 'package:pandamusic/components/colorschemepalette.dart';
import 'package:pandamusic/components/videoplayer/videomanager.dart';
import 'package:pandamusic/components/videoplayer/videoplayer.dart';

class MusicManagerPage extends StatefulWidget {
  const MusicManagerPage({super.key});
  
  @override
  MusicManagerPageState createState() => MusicManagerPageState();
}
class MusicManagerPageState extends State<MusicManagerPage> {
  final AppVideoManager videoManager =  AppVideoManager();
  @override
  Widget build(BuildContext context) {
    AppPlaylistPlayer playlistPlayer = AppPlaylistPlayer(
      videoList: [
        "C:/Users/riley/Music/music/怪物 [k0g04t7ZeSw].mp4", 
        "C:\\Users\\riley\\Music\\music\\AiAiA [83zmIfIiNWc].mp4",
        "C:\\Users\\riley\\Music\\music\\Summer Horror Party [HZYLKmsY8W8].mp4"
      ], 
      manager: videoManager,
      isFile: true
    );
    return SizedBox.expand(
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            flex: 1,
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
              child:Column(
                spacing: 10,
                children: [
                  playlistPlayer,
                  ColorSchemePalette(),
                  TextButton(
                    onPressed: (){
                      videoManager.emit(0);
                    }, 
                    child: Text("test")
                  )
                ],
              ),
            )
          ),
          Flexible(
            flex: 3,
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