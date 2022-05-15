import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:sky_luxury/admin/pdf_screen.dart';
import 'package:sky_luxury/model/add_agent.dart';

class InvoiceApiProvider {
  static int invoiceNumber = 0;
  static Future<File> InvoiceMaker(AddAgent agent) async {
    invoiceNumber = invoiceNumber + 1;
    final pdf = Document();

    final bytes = (await rootBundle.load('assets/Official-logo.png'))
        .buffer
        .asUint8List();
    final image = MemoryImage(bytes);
    pdf.addPage(PdfPageView.pdfCreation(image: image, addAgent: agent));

    return saveDocument(name: 'my_invoice_$invoiceNumber.pdf', pdf: pdf);
  }

  static Widget buildTitle(Document pdf) {
    return Column(children: [
      SizedBox(height: 0.8 * PdfPageFormat.cm),
      Text('description')
    ]);
  }

  static Future<File> saveDocument(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openPdf(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
