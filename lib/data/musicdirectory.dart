import 'dart:io';
import 'package:serious_python/serious_python.dart';

Stream<FileSystemEntity> getDirectoryVideos(
  String directoryPath
){
  try {
    Directory directory = Directory(directoryPath);
    return directory.list(
      recursive: false,
      followLinks: false,
    ).where((FileSystemEntity entity)=>(entity is File) && (entity.path.endsWith('mp4') || entity.path.endsWith('webm')));
  } catch (e){
    rethrow;
  }
}
Future<String> downloadPlaylistVideos(
  String url,
  String folder,
) async {
  try {
    if(!(await Directory(folder).exists()) && !(await Directory(folder).parent.exists())){
      return "Download location folder does not exist.";
    }
    await SeriousPython.run(
      "downloader/ytdownloader.zip",
      environmentVariables: {
        "DOWNLOAD_LOCATION": folder,
        "YT_PLAYLIST_URL": url,
      }
    );
    return "Beginning download...";
  } catch(e){
    return "ERROR downloading: $e";
  }
}