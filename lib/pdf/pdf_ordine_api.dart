import 'dart:io';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/pdf/pdf_api.dart';
import 'package:flutter/services.dart';
// import 'package:generate_pdf_invoice_example/api/pdf_api.dart';
// import 'package:generate_pdf_invoice_example/model/customer.dart';
// import 'package:generate_pdf_invoice_example/model/invoice.dart';
// import 'package:generate_pdf_invoice_example/model/supplier.dart';
// import 'package:generate_pdf_invoice_example/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../model/cart_item_ext.dart';
import '../model/ordine_ext.dart';
import '../utils/app_utils.dart';

class PdfOrdineApi {
  static Future<File> generate(Ordine ordine,List<CartItemExt> prodotti, PuntoVendita puntovendita) async {
    final pdf = Document();
    final font = await rootBundle.load("assets/fonts/open_sans_regular.ttf");



    // String? logo = await rootBundle.loadString('assets/images/bbc.svg');

    pdf.addPage(MultiPage(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
        bold: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
        italic: Font.ttf(await rootBundle.load("assets/fonts/open_sans_regular.ttf")),
        boldItalic: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      build: (context) => [
        // buildHeader(ordine,puntovendita),
        buildHeader(ordine,puntovendita),
        Divider(),
        SizedBox(height: 3 * PdfPageFormat.mm),
        Text('Consegna prevista il ${AppUtils.dateToString(ordine.dtConsegna)}, presso ${ordine.indirizzoConsegna}'),
        SizedBox(height: 8 * PdfPageFormat.mm),
        buildTitle(ordine),
        buildInvoice(prodotti),
        Divider(),
        buildTotal(ordine,prodotti),
      ],
      header: (context)=>  Column(
          children: [ Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
          children: [

            // pw.SvgImage(svg:logo,width: 55),
            SizedBox(width: 20),
            buildSupplierAddress(),
          ]),SizedBox(height: 1 * PdfPageFormat.mm),

        Divider(height: 1 * PdfPageFormat.mm,
            // color: PdfColor.fromHex('bfd5e3')
        )]),
      footer: (context) => buildFooter(ordine),
    ));

    return PdfApi.saveDocument(name: '${ordine.numero}.pdf', pdf: pdf);
  }

  static Widget buildHeader(Ordine ordine,PuntoVendita puntoVendita) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 5 * PdfPageFormat.mm),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildCustomerAddress(puntoVendita),
        ],
      ),
      Divider(),
      Text('ORDINE',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),

      SizedBox(height: 3 * PdfPageFormat.mm),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildInvoiceInfo(ordine),
          Container(
            height: 50,
            width: 50,
            child: BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: ordine.numero.toString(),
            ),
          ),
        ],
      ),
      ],
  );

  static Widget buildCustomerAddress(PuntoVendita puntoVendita) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Spettabile"),
      Text(puntoVendita.denominazione!, style: TextStyle(fontWeight: FontWeight.bold)),
      Text(puntoVendita.ragSociale!),
      SizedBox(height: 5),
      Text('Partita Iva: ${puntoVendita.partitaIva!}'),
      Text('Id Fatturazione: ${puntoVendita.idFatturazione}')
    ],
  );

  static Widget buildInvoiceInfo(Ordine ordine) {
    String statoOrdine=ordine.statoCodice!;
    if(ordine.statoCodice=='INVIATO'){
      statoOrdine+=' *';
    }
    final titles = <String>[
      'Stato:',
      'Numero: ',
      'Effttuato il:',
      'Note:'
    ];
    final data = <String>[
      statoOrdine,
      '${ordine.numero.toString()}',
      AppUtils.convertTimestamptzToStringDate(ordine.createdAt??'').substring(0,10)?? '',
      ordine.note??''
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


  static Widget buildSupplierAddress() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Bufala Buona", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 33)),
      // SizedBox(height: 1 * PdfPageFormat.mm),
      Text("Azienda Agricola Giancarlo D'Angelo"),
      // SizedBox(height: 1 * PdfPageFormat.mm),
      // Text( 'Via Salaria 1965 (km 19,600) - Roma'),
    ],
  );

  static Widget buildTitle(Ordine ordine) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PRODOTTI',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 0.3 * PdfPageFormat.cm),
    ],
  );

  static Widget buildInvoice(List<CartItemExt> prodotti) {
    final headers = [
      'Cod',
      'Denominazione',
      'Descrizione',
      'Quantita',
      'Prezzo Unitario',
      'TOTALE'
    ];
    final data = prodotti.map((item) {
      var price= item.price! * item.quantita!;

      return [
        item.prodCodice,
        item.prodDenominazione,
        item.prodDescrizione,
        '${item.quantita} (${item.prodUnimisCodice})',
        '${item.price} \€',
        '${price.toString()} \€'
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      columnWidths:{
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(5),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(2),
        5: FlexColumnWidth(3),
      },
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerLeft,
        2: Alignment.centerLeft,
        3: Alignment.centerLeft,
        4: Alignment.center,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Ordine ordine,List<CartItemExt> prodotti) {
    final netTotal = prodotti.map((item) => item.price! * item.quantita!)
        .reduce((item1, item2) => item1 + item2);
    final vatPercent = 0.04;// invoice.items.first.vat;
    final vat = netTotal * vatPercent;
    final total = netTotal + vat;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Totale',
                  value: '${netTotal.toString()} €',
                  unite: true,
                ),
                buildText(
                  title: 'Iva ${vatPercent * 100} %',
                  value: '${vat.toString()} €',
                  unite: true,

                ),
                Divider(),
                buildText(
                  title: 'Totale dovuto',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: '${total.toString()} €',
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Ordine ordine) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Divider(),
      if(ordine.statoCodice=='INVIATO')Text("*ATTENZIONE: l'ordine in stato INVIATO non è stato ancora confermato dal venditore, potrebbe quindi subire ancora delle modifiche legate alla disponibilità dei prodotti o alla data di consegna",style: TextStyle(fontSize:9)),


      // SizedBox(height: 1 * PdfPageFormat.mm),
      // buildSimpleText(title: 'Partita IVa', value:'XXXXX'),
      // SizedBox(height: 1 * PdfPageFormat.mm),
      // Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [ buildSimpleText(title: 'Telefono ', value:'391.40.86.120'),
      //   buildSimpleText(title: 'email ', value:'caseificio@aziendaagricoladangelo.com'),
      // ])
    ],
  );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
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