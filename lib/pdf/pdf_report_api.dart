import 'dart:convert';
import 'dart:io';
import 'package:bufalabuona/data/report_produzione_rest_service.dart';
import 'package:bufalabuona/model/report_produzione.dart';
import 'package:bufalabuona/model/report_produzione_casaro_json_data.dart';
import 'package:bufalabuona/model/report_produzione_json_data.dart';
import 'package:bufalabuona/pdf/pdf_api.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfReportApi {
  static final dateFormatter = new DateFormat('dd-MM-yyyy');
  static final dateFormatterFile = new DateFormat('dd_MM_yyyy');

  static Future<File> generate(ReportProduzione reportProduzione,List<dynamic> listProds) async {
    final font = await rootBundle.load("assets/fonts/open_sans_regular.ttf");
    final ttf = Font.ttf(font);
    final pdf = Document();
    pdf.addPage(
        MultiPage(
          theme: ThemeData.withFont(
            base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
            bold: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
            italic: Font.ttf(await rootBundle.load("assets/fonts/open_sans_regular.ttf")),
            boldItalic: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
          ),
      build: (context) => [
        buildHeader(reportProduzione),
        SizedBox(height: 1 * PdfPageFormat.cm),
        // buildTitle(reportProduzione,listProds),
        buildInvoice(reportProduzione,listProds),
        Divider(),
      ],
      header:  (context)=>  Column(
    children: [ Row(
    crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SvgImage(svg:logo,width: 55),
          SizedBox(width: 20),
          buildSupplierAddress(),
        ]),
      SizedBox(height: 1 * PdfPageFormat.mm),

    Divider(height: 1 * PdfPageFormat.mm,
    // color: PdfColor.fromHex('bfd5e3')
    )]),
      footer: (context) => buildFooter(reportProduzione),
    ));

    String filename = "report_prouzione_${dateFormatterFile.format(reportProduzione.dtRiferimento!).substring(0,10)}";
    return PdfApi.saveDocument(name: '$filename.pdf', pdf: pdf);
  }

  static Widget buildSupplierAddress() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Bufala Buona", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 33)),
      Text("Azienda Agricola Giancarlo D'Angelo"),
    ],
  );

  static Widget buildHeader(ReportProduzione reportProduzione) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 4 * PdfPageFormat.mm),
      Text('REPORT PRODUZIONE',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),
      // SizedBox(height: 1 * PdfPageFormat.cm),
      // Text('REPORT PRODUZIONE',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),
      SizedBox(height: 4 * PdfPageFormat.mm),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildInvoiceInfo(reportProduzione),
          Container(
            height: 50,
            width: 50,
            child: BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: reportProduzione.hash!,
            ),
          ),
        ],
      ),
    ],
  );


  static Widget buildInvoiceInfo(ReportProduzione report) {
    final titles = <String>[
      'del:',
      'v.'
    ];
    final data = <String>[
      dateFormatter.format(report.dtRiferimento!).substring(0,10),
      report.index.toString(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }


  static Widget buildTitle(ReportProduzione report,List<dynamic> listProds) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'REPORT PRODUZIONE del ${dateFormatter.format(report.dtRiferimento!).substring(0,10)}',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 0.8 * PdfPageFormat.cm),
      Text(report.note??''),
      SizedBox(height: 0.8 * PdfPageFormat.cm),
    ],
  );

  static Widget buildInvoice(ReportProduzione report,List listProds) {
    final headers = [
      'Prodotto',
      'Dettaglio',
      'KG',
      'Pezzi'
    ];

    List<ReportProduzioneCasaroJsonData> list = listProds
        .map<ReportProduzioneCasaroJsonData>((f) => ReportProduzioneCasaroJsonData.fromJson(f))
        .toList();

    final data = list.map((item) {
      return [
        item.tipProdDescrizione,
        item.dettaglio,
        '${item.totale!/1000}',
        '${(item.totale!/item.qtaProduzione!).ceil()}'
      ];
    }).toList();


    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
      },
    );
  }
  // static Widget buildInvoice(ReportProduzione report,List listProds) {
  //   final headers = [
  //     'ID Prodotto',
  //     'Codice',
  //     'Prodotto',
  //     'Quantita',
  //     'Descrizione'
  //   ];
  //
  //   List<ReportProduzioneJsonData> list = listProds
  //       .map<ReportProduzioneJsonData>((f) => ReportProduzioneJsonData.fromJson(f))
  //       .toList();
  //
  //   final data = list.map((item) {
  //     return [
  //       item.prodId,
  //       item.codice,
  //       item.denominazione,
  //       '${item.sumToDeliver} (${item.unimisCodice})',
  //       item.descrizione,
  //     ];
  //   }).toList();
  //
  //
  //   return Table.fromTextArray(
  //     headers: headers,
  //     data: data,
  //     border: null,
  //     headerStyle: TextStyle(fontWeight: FontWeight.bold),
  //     headerDecoration: BoxDecoration(color: PdfColors.grey300),
  //     cellHeight: 30,
  //     cellAlignments: {
  //       0: Alignment.centerLeft,
  //       1: Alignment.centerRight,
  //       2: Alignment.centerRight,
  //       3: Alignment.centerRight,
  //       4: Alignment.centerRight,
  //     },
  //   );
  // }


  static Widget buildFooter(ReportProduzione invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Divider(),
      SizedBox(height: 2 * PdfPageFormat.mm),
      // buildSimpleText(title: 'Address', value: invoice.supplier.address),
      SizedBox(height: 1 * PdfPageFormat.mm),
      // buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
    ],
  );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}