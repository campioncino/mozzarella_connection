import 'dart:io';

import 'package:flutter/services.dart';
// import 'package:open_file/open_file.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();
    String savePath;

    if (Platform.isAndroid) {
       Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {directory = await getExternalStorageDirectory();}
      String dir =directory!.path;
      dir = "$dir/";
      savePath = "$dir$name";
    } else {
      String dir = (await getApplicationDocumentsDirectory()).path;
      savePath = "$dir$name";
    }
    final file = File(savePath);

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFilex.open(url);
  }
}