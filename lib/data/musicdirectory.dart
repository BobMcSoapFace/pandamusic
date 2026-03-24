import 'dart:io';

Stream<FileSystemEntity> getDirectoryVideos(
  String directoryPath
){
  try {
    Directory directory = Directory(directoryPath);
    return directory.list(
      recursive: false,
      followLinks: false,
    ).where((FileSystemEntity entity)=>(entity is File) && entity.path.endsWith('mp4'));
  } catch (e){
    print("DIRECTORY ACCESS / STREAM ERROR");
    rethrow;
  }
}