import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pandamusic/data/colors.dart';
import 'package:pandamusic/data/responsive.dart';

class DownloadInterface extends StatefulWidget {
  final TextEditingController folderController;
  final TextEditingController urlController;
  final void Function() loadFolder;
  final void Function() downloadUrl;
  const DownloadInterface({
    super.key, 
    required this.folderController, 
    required this.urlController, 
    required this.loadFolder, 
    required this.downloadUrl
  });

  @override
  DownloadInterfaceState createState() => DownloadInterfaceState();
}
class DownloadInterfaceState extends State<DownloadInterface> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.scheme(context).primary
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14
      ),
      width: double.infinity,
      child: Flex(
        direction: Axis.vertical,
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flex(
            spacing: 14,
            direction: Axis.horizontal,
            children: [
              Icon(
                Icons.folder,
                size: 32,
                color: AppColor.scheme(context).onPrimary,
              ),
              Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: !Responsive.isMobile(context) ? 280 : 240,
                  child: TextField(
                    style: GoogleFonts.googleSans(
                      fontWeight: FontWeight.w500,
                      color: AppColor.scheme(context).onPrimary
                    ),
                    showCursor: true,
                    cursorColor: AppColor.scheme(context).onPrimary,
                    decoration: InputDecoration.collapsed(
                      hintText: "C://Users/example/Music",
                      hintStyle: GoogleFonts.googleSans(
                        fontWeight: FontWeight.w500,
                        color: AppColor.scheme(context).outlineVariant
                      ),
                    ),
                    controller: widget.folderController,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.loadFolder,
                  child: Icon(
                    Icons.download,
                    color: AppColor.scheme(context).onPrimary,
                  ),
                ),
              )
          ]),
          Flex(
            spacing: 14,
            direction: Axis.horizontal,
            children: [
              Icon(
                Icons.monitor,
                size: 32,
                color: AppColor.scheme(context).onPrimary,
              ),
              Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: !Responsive.isMobile(context) ? 320 : 240,
                  child: TextField(
                    style: GoogleFonts.googleSans(
                      fontWeight: FontWeight.w500,
                      color: AppColor.scheme(context).onPrimary
                    ),
                    showCursor: true,
                    cursorColor: AppColor.scheme(context).onPrimary,
                    decoration: InputDecoration.collapsed(
                      hintText: "https://www.youtube.com/playlist?list=...",
                      hintStyle: GoogleFonts.googleSans(
                        fontWeight: FontWeight.w500,
                        color: AppColor.scheme(context).outlineVariant
                      ),
                    ),
                    controller: widget.urlController,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.downloadUrl,
                  child: Icon(
                    Icons.download,
                    color: AppColor.scheme(context).onPrimary,
                  ),
                ),
              )
          ]),
        ],
      ),
    );
  }

}