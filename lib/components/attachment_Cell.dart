import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sky_luxury/components/strings.dart';

class AttachmentCell extends StatelessWidget {
  final String path;
  final String pathExtension;
  File? file;
  final String? adminName;

  final bool isMe;
  AttachmentCell(
      {required this.path,
      required this.isMe,
      required this.pathExtension,
      this.adminName});

  @override
  Widget build(BuildContext context) {
    Future.wait({downloadFile()}).then((value) => file = value.first);
    // final extensionFromUrl = extension(path).split('.').last.split('?').first;

    print('extension build ' + pathExtension);
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        InkWell(
          onTap: () async {
            // File? file = await downloadFile();
            if (file == null) return;

            print('adad');
            OpenFile.open(file!.path).catchError((e) => print(e.toString()));
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5),
            width: size.width * 0.4,
            height: size.height * 0.3,
            decoration: _decoration(size),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                    visible: pathExtension == Strings.pdf,
                    child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        color: Colors.grey.withOpacity(0.8),
                        child: Text(
                          'click to preview pdf',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )))
              ],
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _decoration(Size size) {
    return BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            offset: Offset(0, 0),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
        image: DecorationImage(
            image: pathExtension == Strings.pdf
                ? AssetImage(Strings.pdfPicture) as ImageProvider
                : CachedNetworkImageProvider(path),
            fit: pathExtension == Strings.pdf ? BoxFit.contain : BoxFit.fill),
        color: isMe ? Colors.grey.shade200 : Strings.kPrimaryColor,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size.width * 0.04),
            topRight: Radius.circular(size.width * 0.04),
            bottomLeft:
                isMe ? Radius.circular(0) : Radius.circular(size.width * 0.04),
            bottomRight: isMe
                ? Radius.circular(size.width * 0.04)
                : Radius.circular(0)));
  }

  Future<File?> downloadFile() async {
    final extention = extension(path);
    final split = extention.split('?').first;
    print(split);

    final pathsplit = path.split('%').last;

    final finalSplit = pathsplit.split('.').first;

    try {
      final appstorage = await getApplicationDocumentsDirectory();

      final file = File('${appstorage.path}/$finalSplit$split');
      print('pathh' + file.path);
      final basenames = basename(path);
      final response = await Dio().get(path,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              receiveTimeout: 0));

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    } catch (error) {
      print(error);
      return null;
    }
  }
}
