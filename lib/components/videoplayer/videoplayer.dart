
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pandamusic/components/videoplayer/videomanager.dart';
import 'package:pandamusic/data/colors.dart';

// ignore: non_constant_identifier_names
AppPlaylistPlayer AppVideoPlayer({
  required String videoPath,
  required AppVideoManager manager,
  bool isFile = true
}) => AppPlaylistPlayer(
  videoList: [videoPath], 
  manager: manager,
  isFile: isFile
);
class AppPlaylistPlayer extends StatefulWidget {
  final List<String> videoList;
  final AppVideoManager manager;
  final bool isFile;
  const AppPlaylistPlayer({
    super.key,
    required this.videoList,
    required this.manager,
    required this.isFile, 
  });
  @override
  AppPlaylistPlayerState createState() => AppPlaylistPlayerState();
}
class AppPlaylistPlayerState extends State<AppPlaylistPlayer> {
  static final durationBarFidelity = 10000;
  late final player = Player();
  late final controller = VideoController(
    player,
    configuration: VideoControllerConfiguration()
  );
  double _currentVolume = 100;
  double playbackPercent = 0;
  int? playbackDuration;
  int playbackPosition = 0;
  int videoIndex = 0;
  bool videoIsPlaying = false;
  bool volumeMuted = false;
  final double _maxVolume = 200;
  late StreamSubscription<Duration> _durationListener;
  late StreamSubscription<bool> _playingListener;
  late StreamSubscription<int> _indexListener;
  
  String _secondsToString(double seconds){
    return "${(seconds/60).toInt() < 10 ? "0":""}${(seconds/60).toInt()}:${(seconds%60).toInt() < 10 ? "0":""}${(seconds%60).toInt()}";
  }

  void refreshVideoIndex(int index){
    player.open(Media((widget.isFile ? "file:///":"") + widget.videoList[index].replaceAll("\\", "/")));
    playbackPosition = 0;
    playbackPercent = 0;
  }
  @override
  void initState() {
    super.initState();
    if(widget.videoList.isNotEmpty){
      player.open(Media((widget.isFile ? "file:///":"") + widget.videoList[videoIndex]));
    }
    player.pause();
    player.setVolume(_currentVolume);
    _durationListener = player.stream.duration.listen(
      (duration){
        setState(() {
          playbackDuration = duration.inMilliseconds;
        });
      }
    );
    _playingListener = player.stream.playing.listen(
      (isPlaying){
        setState(() {
          videoIsPlaying = isPlaying;
          if(!isPlaying && playbackDuration != null && playbackPosition >= playbackDuration!){
            
          }
        });
      }
    );
    player.stream.position.listen(
      (duration){
        setState(() {
          playbackPosition = duration.inMilliseconds;
          playbackPercent = (playbackDuration ?? 0) > 0 ? (playbackPosition.toDouble()/playbackDuration!) : 0;
        });
      }
    );
    widget.manager.videoIndexStream.listen((newIndex){
      setState(() {
        videoIndex = newIndex;
        refreshVideoIndex(newIndex);
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
    player.dispose();
    _durationListener.cancel();
    _playingListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return 
      Container(
        alignment: AlignmentGeometry.center,  
        padding: EdgeInsets.fromLTRB(2, 2, 2, 8),
        decoration: BoxDecoration(
          color: AppColor.scheme(context).primary,
          borderRadius: BorderRadius.circular(5)
        ),
        child: 
          Column(
            children: [
              Video(
                filterQuality: FilterQuality.high,
                pauseUponEnteringBackgroundMode: false,
                controls: null,
                width: double.infinity,
                height: 200,
                controller: controller
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: 4,
                width: double.infinity,
                color: AppColor.scheme(context).surfaceContainer,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                      flex: playbackPercent > 0.01 ? (playbackPercent*durationBarFidelity).toInt() : 1,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: AppColor.scheme(context).primary,
                      )
                    ),
                    Flexible(
                      flex: durationBarFidelity-(playbackPercent*durationBarFidelity).toInt(),
                      child: SizedBox()
                    )
                  ],
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  ...List.generate(3, (i)=>i).map((i)=>
                  Material(
                    color: AppColor.scheme(context).primary,
                    shape: CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        if(i == 0 || i == 2){
                          if(videoIndex > 0 && i == 0){
                            widget.manager.emit(videoIndex-1);
                          } else if (i == 2 && videoIndex < widget.videoList.length-1){
                            widget.manager.emit(videoIndex+1);
                          } else {
                            return;
                          }
                        } else if(i == 1){
                          setState(() {
                            player.playOrPause();
                          });
                        }
                      },
                      child: Icon(
                        i == 1 ? (videoIsPlaying ? Icons.pause : Icons.play_arrow)
                        : i == 2 ? Icons.skip_next 
                        : i == 0 ? Icons.skip_previous
                        : Icons.error,
                        color: AppColor.scheme(context).onPrimary,
                      ),
                    ),
                  ))
                ],
              ),
              SizedBox(height: 7),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("Azari - Sell a Friend ⧸ 重音テト [yJ1hNjuAKtM]",
                  style: GoogleFonts.googleSans(
                    fontSize: 20
                  ),
                ),
              ),
              SizedBox(height: 2),
              if(playbackDuration!=null) Text("(${_secondsToString(playbackPosition/1000)} - ${_secondsToString(playbackDuration!/1000)})",
                style: GoogleFonts.googleSans(
                  fontSize: 14
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: 
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: AppColor.scheme(context).primary,
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            if(!volumeMuted){
                              volumeMuted = true;
                              player.setVolume(0);
                            } else {
                              volumeMuted = false;
                              player.setVolume(_currentVolume);
                            }
                          });
                        },
                        child: Icon(
                          _currentVolume <= 3 || volumeMuted ? Icons.volume_off : 
                          _currentVolume >= 133 ? Icons.volume_up : 
                          _currentVolume <= 67 ? Icons.volume_mute :
                          Icons.volume_down,
                          color: AppColor.scheme(context).onPrimary,
                        ),
                      ),
                    ),
                    Material(
                      color: AppColor.scheme(context).primary,
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbSize: WidgetStatePropertyAll(
                            Size(4, 24)
                          ),
                          valueIndicatorTextStyle: GoogleFonts.googleSans(
                            color: AppColor.scheme(context).primary,
                            fontSize: 12
                          )
                        ), 
                        child:  Slider(
                          value: !volumeMuted ? _currentVolume : 0,
                          activeColor: AppColor.scheme(context).onPrimary,
                          onChanged: (newValue)=>setState((){
                            volumeMuted = false;
                            _currentVolume=newValue;
                            player.setVolume(newValue);
                          }),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          year2023: false,
                          label: "${_currentVolume.toStringAsFixed(0)}%",
                          secondaryActiveColor: AppColor.scheme(context).primary,
                          max: _maxVolume,
                        ),
                      )
                    ),
                  ],
                )
              )
            ],
          )
      );
  }

}