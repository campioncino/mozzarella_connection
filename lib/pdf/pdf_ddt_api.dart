import 'dart:convert';
import 'dart:io';
import 'package:bufalabuona/data/report_produzione_rest_service.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/report_confezionamento.dart';
import 'package:bufalabuona/model/report_ddt.dart';
import 'package:bufalabuona/model/report_produzione.dart';
import 'package:bufalabuona/model/report_produzione_casaro_json_data.dart';
import 'package:bufalabuona/model/report_produzione_json_data.dart';
import 'package:bufalabuona/pdf/pdf_api.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;

import '../model/report_ddt_prodotto.dart';

class PdfDdtApi {
  static final dateFormatter = new DateFormat('dd-MM-yyyy');
  static final dateFormatterFile = new DateFormat('dd_MM_yyyy');




  static Future<File> generate(ReportConfezionamento reportConfezionamento, ReportDdt ddt, PuntoVendita puntoVendita, List<ReportDdtProtto> listProds) async {
    final font = await rootBundle.load("assets/fonts/open_sans_regular.ttf");
    final ttf = Font.ttf(font);
    final pdf = Document();
    final image = (await rootBundle.load("assets/images/bb.png")).buffer.asUint8List();
    pdf.addPage(
        MultiPage(
          theme: ThemeData.withFont(
            base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
            bold: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
            italic: Font.ttf(await rootBundle.load("assets/fonts/open_sans_regular.ttf")),
            boldItalic: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
          ),
      build: (context) => [
        // buildHeader(reportConfezionamento),
        // Divider(height: 1 * PdfPageFormat.mm,),

        buildDettaglioOrdine(ddt),
        Divider(),
        buildColli(),

        Divider(height: 1 * PdfPageFormat.mm,),
        SizedBox(height: 1 * PdfPageFormat.cm),

        Container(
            // decoration: BoxDecoration( border: Border.all(
            //     width: 1,
            //     ),),
            child: Column(children: [
          buildHeaderOrdine(ddt,listProds),
          buildListaProdotti(reportConfezionamento,listProds),
          Divider(),
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("Totale : ${ddt.totaleOrdine}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),SizedBox(width: 5)]),
        ])),

      ],
      header:  (context)=>
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

                  Container(
                      child:Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image(MemoryImage(image),width: 80,height: 80, fit: BoxFit.cover),

                            Container(
                              height: 70,
                              width: 70,
                              child: BarcodeWidget(
                                barcode: Barcode.qrCode(),
                                data: reportConfezionamento.hash!,
                              ),
                            ),
                            buildDdtInfo(reportConfezionamento),

                          ])),
                  Row(children: [
                    buildSupplierAddress(),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          buildReceiverAddress(puntoVendita),
                          buildIndirizzoConsegna(ddt),
                    ]),
                  ]),
              SizedBox(height: 1 * PdfPageFormat.mm),
              Divider(height: 1 * PdfPageFormat.mm,
    )]),
    footer: (context) => buildFooter(reportConfezionamento,puntoVendita)));

    String filename = "ddt_${reportConfezionamento.numeroDdt}";
    return PdfApi.saveDocument(name: '$filename.pdf', pdf: pdf);
  }

  static Widget buildSupplierAddress() => Container(
      width: 300,
      child:Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Text("Bufala Buona", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 33)),
      Text("Azienda Agricola Giancarlo D'Angelo",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 26)),
      Text("P.Iva 09768270580"),
      Text("C.F. DGNGCR51A02H501Z" ),
      Text("Via Fernando Lori 171"),
      Text("00138 ROMA")
    ],
  ));

  static Widget buildReceiverAddress(PuntoVendita pv)=>Container(
    width: 190,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //   width: 1,
      //   ),
      // ),
      child:Padding(padding: EdgeInsets.all(10), child:
          Container(
            decoration: BoxDecoration(
              border: Border.all(
              width: 1,
                color: PdfColors.grey100,
              ),
            ),

              child:
          Padding(padding: EdgeInsets.all(2),child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: double.infinity,
              color: PdfColors.grey100,child:Text("Destinatario",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),
          Text("${pv.ragSociale}"),
          // Text("${pv.denominazione}"),
          Text("P.Iva : ${pv.partitaIva}"),
          Text("Indirizzo : ${pv.indirizzo}"),
          Text("SDI :  ${pv.idFatturazione}")
        ]
  )))));

  static Widget buildDdtInfo(ReportConfezionamento report)=>Container(
      width: 220,
      height: 70,
      child:
      Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: PdfColors.grey100,
            ),
          ),

          child:
          Padding(padding: EdgeInsets.all(2),child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              Container(
              width: double.infinity,
              color: PdfColors.grey100,
                  child:Text("Documento di Trasporto",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),
              Text('numero : ${report.numeroDdt} ', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
              Text('del : ${AppUtils.convertTimestamptzToStringDate(report.createdAt.toString()??'').substring(0,10) ??''}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16))
              ]

          ))));

  static Widget buildDettaglioOrdine(ReportDdt ddt)=>Container(
      child:Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
        Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tipo Fatturazione",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11)),
                  Text("${ddt.tipoFatturazione??''}"),
                ]),

       Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Vettore Trasporto",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11)),
                  Text("${ddt.vettoreTrasporto??''}"),
                ]),

        Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Causale Trasporto",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11)),
                  Text("${ddt.causale??''}"),
                ]),

        Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Costo Spedizione",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11)),
                  Text("${ddt.costoSpedizione??''}"),
                ]),
      ])));

  static Widget buildIndirizzoConsegna(ReportDdt ddt)=>Container(
      width: 190,
      child:Padding(
          padding: EdgeInsets.all(10),
          child:
          Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: PdfColors.grey100,
                ),
              ),child:
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: double.infinity,
                    color: PdfColors.grey100,child:Text("Consegna Presso",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),
                Text("${ddt.indirizzoConsegnaOrdine??''}"),
              ]
          ))));

  static Widget buildHeader(ReportConfezionamento reportConfezionamento) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 4 * PdfPageFormat.mm),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
          Column(children:[
          Text('Tipo Documento',style: TextStyle(fontSize: 11,)),
          Text('DDT',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))]),

            Column(children:[
                  Text('Numero Documento',style: TextStyle(fontSize: 11,)),
                  Text('${reportConfezionamento.numeroDdt}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                ]),

            Column(children:[
                  Text('Data Documento',style: TextStyle(fontSize: 11,)),
                  Text('${AppUtils.convertTimestamptzToStringDate(reportConfezionamento.createdAt??'').substring(0,10) ??'' }',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                ]),

        Container(
          height: 50,
          width: 50,
          child: BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: reportConfezionamento.hash!,
          ),
        ),
      ]),
      // SizedBox(height: 1 * PdfPageFormat.cm),
      // Text('REPORT PRODUZIONE',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),
      SizedBox(height: 4 * PdfPageFormat.mm),
    ],
  );


  static  String calcolaParziale(ReportDdtProtto item){
    num val =(item.quantita!*item.price!);
    return val.toStringAsFixed(2);
  }

  static Widget buildHeaderOrdine(ReportDdt report,List<ReportDdtProtto> listProds) {
    final headers = [
      'Ordine #${report.numeroOrdine}',
      'del: ${AppUtils.convertTimestamptzToStringDate(listProds[0].createdAt.toString()??'').substring(0,19) ??''}',
    ];
    List<ReportDdtProtto> listProdsMod = [];
    listProdsMod.addAll(listProds);
    listProdsMod.removeRange(1, listProdsMod.length);
    final data = listProdsMod.map((item) {
      return [
        // 'numero : ${report.numeroOrdine}',
        // 'del :${AppUtils.convertTimestamptzToStringDate(item.createdAt.toString()??'').substring(0,19) ??''}',
      ];
    }).toList();
    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),
      headerDecoration: BoxDecoration(color: PdfColors.grey400),
      cellHeight: 20,
      // columnWidths: {
      //   4: FixedColumnWidth(1)
      // },
      columnWidths: {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
      },

      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
      },
    );
  }

   static Widget buildListaProdotti(ReportConfezionamento report,List<ReportDdtProtto> listProds) {
    final headers = [
      'Codice',
      'Prodotto',
      'Qta',
      'Pezzo\nUnita',
      'TOT'
    ];

    final data = listProds.map((item) {
      return [
        item.codice,
        item.denominazione,
        '${item.quantita}',
        '${item.price}',
        calcolaParziale(item)
      ];
    }).toList();


    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey200),
      cellHeight: 30,
      // columnWidths: {
      //   4: FixedColumnWidth(1)
      // },
      columnWidths: {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FixedColumnWidth(50.0),
        3: FixedColumnWidth(50.0),
        4: FixedColumnWidth(50.0)
      },

      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerLeft,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
      },
    );
  }

  static Widget buildColli()=>Container(
    child:Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Aspetto Esteriore Dei Beni",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11)),
              Text("VISIBILE"),
            ]),

        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Numero Colli",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11)),
              Text("1"),
            ]),

        Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Peso KG",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11)),
                    Text("   "),
                  ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Porto",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11)),
                    Text("   "),
                  ]),
            ])));



  static Widget footerTable(ReportConfezionamento invoice,PuntoVendita pv){
    final headers = [
      'Firma Mittente',
      'Firma Trasportatore',
      'Firma Cliente'
    ];


    List<List<dynamic>> empty = [];
    return Table.fromTextArray(headers:headers, border: null, data: empty ,headerStyle: TextStyle(fontWeight: FontWeight.bold),);
  }

  static Widget footerRow() =>Container(
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
      Container(child: Column(children: [Text("Firma Mittente"),SizedBox(height: 10)])),
      Container(child: Column(children: [Text("Firma Trasportatore"),SizedBox(height: 10)])),
      Container(child: Column(children: [Text("Firma Cliente"),SizedBox(height: 10)])),
    ])
  );

  static Widget buildFooter(ReportConfezionamento invoice,PuntoVendita pv) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Divider(),
      Container(
          height: 1 * PdfPageFormat.cm,
          child:footerRow()),
          // child:footerTable(invoice,pv)),
      Divider(height: 1 * PdfPageFormat.cm,),


      Text("SEGUE FATTURA"),
      // SizedBox(height: 2 * PdfPageFormat.mm),
      // buildSimpleText(title: 'Address', value: invoice.supplier.address),
      // SizedBox(height: 1 * PdfPageFormat.mm),
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