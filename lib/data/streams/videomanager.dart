import 'dart:async';
import 'dart:io';

enum MusicSortType{
  name,
  dateModified,
  reverseName,
  reverseDateModified,
}
String musicSortTypeToName(MusicSortType type)=>
  [
    "name ↑",
    "date modified ↑",
    "name ↓",
    "date modified ↓",
  ][MusicSortType.values.indexOf(type)];
class AppVideoManager {
  final StreamController<int> _videoIndexStreamController = StreamController<int>.broadcast();
  final StreamController<MusicSortType> _videoSortTypeStreamController = StreamController<MusicSortType>();
  late Stream<int> videoIndexStream;
  late Stream<MusicSortType> videoSortTypeStream;
  AppVideoManager(){
    videoIndexStream = _videoIndexStreamController.stream;
    videoSortTypeStream = _videoSortTypeStreamController.stream;
    emitIndex(0);
    emitSort(MusicSortType.name);
  }
  void emitIndex(int index) => _videoIndexStreamController.sink.add(index);
  void emitSort(MusicSortType type) => _videoSortTypeStreamController.sink.add(type);
}
String getFileName(
  String path
)=>path.split("\\").last.split("//").last;
Future<List<FileSystemEntity>> sortMusic(
  List<FileSystemEntity> oldList,
  MusicSortType sortType,
) async {
  switch (sortType) {
    case MusicSortType.dateModified || MusicSortType.reverseDateModified:
      var newList = (await Future.wait(oldList.map((file) async =>MapEntry(file, await file.stat())).toList()))..sort(
        (a,b)=>(a.value.modified.millisecondsSinceEpoch-b.value.modified.millisecondsSinceEpoch)
        *(sortType == MusicSortType.reverseDateModified ? -1 : 1)
      );
      var finalList = newList.map((a)=>a.key).toList();
      return finalList;
    default:
      return oldList..sort(
        (a,b)=>getFileName(a.path).compareTo(getFileName(b.path))*(sortType==MusicSortType.reverseName?-1:1)
      );
  }
}