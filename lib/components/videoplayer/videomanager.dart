import 'dart:async';

class AppVideoManager {
  final StreamController<int> _videoIndexStreamController = StreamController<int>.broadcast();
  late Stream<int> videoIndexStream;
  AppVideoManager(){
    videoIndexStream = _videoIndexStreamController.stream;
    emit(0);
  }
  void emit(int index) => _videoIndexStreamController.sink.add(index);

  
}