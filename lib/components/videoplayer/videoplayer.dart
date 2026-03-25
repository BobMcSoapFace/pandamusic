
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pandamusic/data/streams/videomanager.dart';
import 'package:pandamusic/data/colors.dart';
import 'package:pandamusic/data/responsive.dart';

class AppPlaylistPlayer extends StatefulWidget {
  final List<String> videoList;
  final AppVideoManager manager;
  final bool isFile;
  final bool shuffle;
  const AppPlaylistPlayer({
    super.key,
    required this.videoList,
    required this.manager,
    required this.isFile,
    this.shuffle = false, 
  });
  @override
  AppPlaylistPlayerState createState() => AppPlaylistPlayerState();
}
class AppPlaylistPlayerState extends State<AppPlaylistPlayer> {
  static final Random rand = Random();
  static final durationBarFidelity = 10000;
  late final controller = VideoController(
    player,
    configuration: VideoControllerConfiguration()
  );
  final player = Player();
  String cachedPath = "Music Title";
  double _currentVolume = 100;
  double playbackPercent = 0;
  int? playbackDuration;
  int playbackPosition = 0;
  int videoIndex = 0;
  int skipbackLength = 5000;
  bool videoIsPlaying = false;
  bool volumeMuted = false;
  bool videoLoops = false;
  final double _maxVolume = 200;
  late StreamSubscription<Duration> _durationListener;
  late StreamSubscription<Duration> _positionListener;
  late StreamSubscription<bool> _playingListener;
  late StreamSubscription<int> _indexListener;
  late StreamSubscription<MusicSortType> _sortListener;
  
  String _secondsToString(double seconds){
    return "${(seconds/60).toInt() < 10 ? "0":""}${(seconds/60).toInt()}:${(seconds%60).toInt() < 10 ? "0":""}${(seconds%60).toInt()}";
  }

  int getShuffledIndex(){
    if(widget.videoList.length <= 1){
      return 0;
    }
    int newIndex = videoIndex;
    while(newIndex == videoIndex){
      newIndex = rand.nextInt(widget.videoList.length);
    }
    return newIndex;
  }
  void refreshVideoIndex(
    int index,
    {bool newHistory = true
  }){
    player.open(Media((widget.isFile ? "file:///":"") + widget.videoList[index].replaceAll("\\", "/")));
    player.seek(Duration.zero);
    setState(() {
      playbackPosition = 0;
      playbackPercent = 0;
      cachedPath = widget.videoList[index];
    });
    if(newHistory){
      setState(() {
        widget.manager.videoHistory.add(widget.videoList[index]);
        widget.manager.videoHistoryIndex = widget.manager.videoHistory.length-1;
      });
    }
    widget.manager.notifyHistoryChange();
  }
  void refreshVideoIndexByPath(
    String path,
    {bool newHistory = true
  }) async {
    player.open(Media((widget.isFile ? "file:///":"") + path.replaceAll("\\", "/")));
    player.seek(Duration.zero);
    setState(() {
      playbackPosition = 0;
      playbackPercent = 0;
      cachedPath = path;
    });
    if(newHistory){
      setState(() {
        widget.manager.videoHistory.add(path);
        widget.manager.videoHistoryIndex = widget.manager.videoHistory.length-1;
      });
    }
    widget.manager.notifyHistoryChange();

    if(!widget.videoList.contains(path)){
      while(!widget.videoList.contains(path)) {await Future.delayed(Duration(milliseconds: 100));}
      setState(() {
        videoIndex = widget.videoList.indexOf(path);
      });
    }
  }
  @override
  void initState() {
    super.initState();
    if(widget.videoList.isNotEmpty){
      refreshVideoIndex(videoIndex, newHistory: true);
    }
    player.pause();
    player.setVolume(_currentVolume);
    _sortListener = widget.manager.videoSortTypeStream.listen((_)async{
      while(!widget.videoList.contains(cachedPath)) {await Future.delayed(Duration(milliseconds: 50));}
      setState(() {
        videoIndex = widget.videoList.indexOf(cachedPath);
      });
    });
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
          if(!isPlaying && playbackDuration != null && (playbackPosition >= playbackDuration! - 500)){
            if(videoLoops){
              player.play();
            } else if(widget.shuffle && (widget.videoList.length > 1)){
              if(widget.manager.videoHistoryIndex < widget.manager.videoHistory.length-1){
                widget.manager.videoHistoryIndex+=1;
                refreshVideoIndexByPath(widget.manager.videoHistory[widget.manager.videoHistoryIndex], newHistory: false);
              } else {
                widget.manager.emitIndex(getShuffledIndex());
              }
            } else if(videoIndex<widget.videoList.length-1) {
              widget.manager.emitIndex(videoIndex+1);
            }
          }
        });
      }
    );
    _positionListener = player.stream.position.listen(
      (duration){
        setState(() {
          playbackPosition = duration.inMilliseconds;
          playbackPercent = (playbackDuration ?? 0) > 0 ? (playbackPosition.toDouble()/playbackDuration!) : 0;
        });
      }
    );
    _indexListener = widget.manager.videoIndexStream.listen((newIndex) async {
      while(newIndex >= widget.videoList.length) {await Future.delayed(Duration(milliseconds: 100));}
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
    _positionListener.cancel();
    _indexListener.cancel();
    _sortListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return 
      Container(
        clipBehavior: Clip.hardEdge,
        constraints: BoxConstraints(
          minWidth: 400
        ),
        alignment: AlignmentGeometry.center,  
        padding: EdgeInsets.fromLTRB(2, 2, 2, !Responsive.isMobile(context) ? 8 : 2),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  ...List.generate(5, (i)=>i).map((i)=>
                  Material(
                    color: AppColor.scheme(context).primary,
                    shape: CircleBorder(),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(200),
                      onTap: () {
                        if(i == 1 || i == 3){
                          if(widget.shuffle){
                            if(i == 1 && widget.manager.videoHistoryIndex > 0){
                              widget.manager.videoHistoryIndex-=1;
                              refreshVideoIndexByPath(widget.manager.videoHistory[widget.manager.videoHistoryIndex], newHistory: false);
                            } else if(i==3) {
                              if(widget.manager.videoHistoryIndex < widget.manager.videoHistory.length-1){
                                widget.manager.videoHistoryIndex+=1;
                                refreshVideoIndexByPath(widget.manager.videoHistory[widget.manager.videoHistoryIndex], newHistory: false);
                              } else {
                                widget.manager.emitIndex(getShuffledIndex());
                              }
                            }
                          } else if(videoIndex > 0 && i == 1){
                            widget.manager.emitIndex(videoIndex-1);
                          } else if (i == 3 && videoIndex < widget.videoList.length-1){
                            widget.manager.emitIndex(videoIndex+1);
                          } else {
                            return;
                          }
                        } else if(i == 2){
                          setState(() {
                            player.playOrPause();
                          });
                        } else if (playbackDuration == null){
                          return;
                        } else if(i == 4 || i == 0){
                          player.seek(Duration(milliseconds: 
                            i == 0 ? (playbackPosition - skipbackLength > 0 ? playbackPosition - skipbackLength : 0)
                            : (playbackPosition + skipbackLength < playbackDuration! ? playbackPosition + skipbackLength : playbackDuration!)));
                        }
                      },
                      child: 
                      i >= 1 && i <= 3 ? Icon(
                        i == 1 ? Icons.skip_previous 
                        : i == 2 ? (videoIsPlaying ? Icons.pause : Icons.play_arrow)
                        : i == 3 ? Icons.skip_next 
                        : Icons.error,
                        size : 30,
                        color: AppColor.scheme(context).onPrimary,
                      ) : Container(
                        padding: EdgeInsets.all(5),
                        child: Image(
                          image: AssetImage(
                            i == 0 ? (skipbackLength == 5000 ? "assets/icons8-replay-5-48.png" : "assets/icons8-replay-10-48.png")
                            : (skipbackLength == 5000 ? "assets/icons8-forward-5-48.png" : "assets/icons8-forward-10-48.png"),
                          ),
                          width: 22,
                          height: 22,
                        ),
                      )
                    ),
                  ))
                ],
              ),
              SizedBox(height: 7),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(getFileName(cachedPath),
                  style: GoogleFonts.googleSans(
                    fontSize: !Responsive.isMobile(context) ? 20 : 16
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
                Flex(
                  spacing: 8,
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            color: AppColor.scheme(context).primary,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(200),
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
                                ),
                                showValueIndicator: ShowValueIndicator.onDrag
                              ), 
                              child: Slider(
                                value: !volumeMuted ? _currentVolume : 0,
                                activeColor: AppColor.scheme(context).onPrimary,
                                onChanged: (newValue)=>setState((){
                                  volumeMuted = false;
                                  _currentVolume=newValue;
                                  player.setVolume(newValue);
                                }),
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                // ignore: deprecated_member_use
                                year2023: false,
                                label: "${_currentVolume.toStringAsFixed(0)}%",
                                secondaryActiveColor: AppColor.scheme(context).primary,
                                max: _maxVolume,
                              ),
                            )
                          ),
                          Material(
                            color: AppColor.scheme(context).primary,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(200),
                              onTap: () {
                                setState(() {
                                  videoLoops = !videoLoops;
                                });
                              },
                              child: Icon(
                                !videoLoops ? Icons.loop_rounded : Icons.check,
                                color: AppColor.scheme(context).onPrimary,
                                size: !Responsive.isMobile(context) ? 24 : 20,
                              ),
                            ),
                          ),
                          SizedBox(width: !Responsive.isMobile(context) ? 8 : 5,),
                          Material(
                            color: AppColor.scheme(context).primary,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(200),
                              onTap: () {
                                setState(() {
                                  skipbackLength = skipbackLength == 5000 ? 10000 : 5000;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusGeometry.circular(200),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignOutside
                                  )
                                ),
                                width: 24,
                                height: 24,
                                child: Text(
                                  (skipbackLength/1000).toInt().toString(),
                                  style: GoogleFonts.googleSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: !Responsive.isMobile(context) ? 14 : 10,
                                    color: AppColor.scheme(context).onPrimary,
                                  ),
                                ),
                              )
                            ),
                          ),
                        ],
                      )
                    )
                  ],
                )
              )
            ],
          )
      );
  }

}