import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/ui_icons.dart';

class ProdottiList extends StatefulWidget {
  const ProdottiList({Key? key}) : super(key: key);

  @override
  State<ProdottiList> createState() => _ProdottiListState();
}

class _ProdottiListState extends State<ProdottiList> {
  List? dashList;

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    var response = await Supabase.instance.client
        .from('prodotti')
        .select()
        .order('prod_id', ascending: true)
        ;
    setState(() {
      if(response.data!=null){
      dashList = response.data.toList();}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ListTile(title: Text('Prodotti'),leading: UiIcons.prodottiCo2)),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, top: 15, right: 10),
        child: (dashList!=null && dashList!.isNotEmpty)
            ? ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: dashList?.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Card(
                    child: Container(
                      width: double.infinity,
                      height: 90,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                            (dashList![index]["denominazione"]).toString()),
                      ),
                    ),
                  ),
                ],
              );
            })
            : const Center(
          child: Text("Nessun elemento"),
        ),
      ),
    );
  }
}