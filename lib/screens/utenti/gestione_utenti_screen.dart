import 'package:bufalabuona/data/utenti_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/punti_vendita_crud.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';


class GestioneUtentiScreen extends StatefulWidget {
  const GestioneUtentiScreen({Key? key}) : super(key: key);

  @override
  State<GestioneUtentiScreen> createState() => _GestioneUtentiScreenState();
}

class _GestioneUtentiScreenState extends State<GestioneUtentiScreen> {
  List<Utente>? utentiList;
  List<PuntoVendita>? puntiVenditaList;
  Categoria? _cat;
  bool _isLoading = true;

  readData() async {
    WSResponse resp = await UtentiRestService.internal(context).getAll();
    if(resp.success!){
      utentiList = UtentiRestService.internal(context).parseList(resp.data!.toList());
    }
    else{
      debugPrint("errore!!");
    }
  }

  Future<void> readPuntiVendita() async {
    WSResponse resp = await UtentiRestService.internal(context).getAll();
    if(resp.success!){
      utentiList = UtentiRestService.internal(context).parseList(resp.data!.toList());
    }
    else{
      debugPrint("errore!!");
    }
  }

  List<Categoria> parseList(List responseBody) {
    List<Categoria> list = responseBody
        .map<Categoria>((f) => Categoria.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  @override
  void initState() {
    super.initState();
    init();

  }

  void init() async{
    await readPuntiVendita();
    await readData();
    setState(() {
      _isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: (utentiList!=null && utentiList!.isNotEmpty)
            ? ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: utentiList?.length,
            itemBuilder: (context, index) {
              return  _isLoading ? SizedBox(
                height: MediaQuery.of(context).size.height / 1.3,
                child: const Center(
                    child: CircularProgressIndicator()
                ),
              ):Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                    Row(
                      children: [
                        Flexible(
                          child: Card(
                            elevation: 1.0,
                            child: InkWell(
                              onTap: (){debugPrint("aaaa");},
                              child: Container(
                                foregroundDecoration:(!utentiList![index].confermato!) ? const RotatedCornerDecoration(
                                  color: Colors.red,
                                  geometry: const BadgeGeometry(width: 64, height: 64,cornerRadius: 12),
                                  textSpan: const TextSpan(
                                    text: 'NON\nATTIVO',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ) : null,
                                width: double.infinity,
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15,),
                                      // Text(utentiList![index].toJson().toString()),
                                      Text(utentiList![index].name!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                      Text(utentiList![index].username!),
                                      Text(utentiList![index].email!),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            })
            : const Center(
          child: Text("Nessun elemento"),

        ),

      ),
        floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child:  const Icon(Icons.add),
          // backgroundColor: const Color(0xFFE57373),
          onPressed: _goToInsert
        ),
    );
  }

  // Widget categorieText(int catId){
  //   // Categoria c = puntiVenditaList!.firstWhere((element) => element.id==catId);
  //   // // c.descrizione;
  //   // return Text("CATEGORIA : ${c.descrizione ?? 'NON SPECIFICATO'} ");
  // }

  void _goToEdit(dynamic data){
    // PuntoVendita p = PuntoVendita.fromJson(data);
    // Navigator.push(context,  MaterialPageRoute(
    //     builder: (context) =>
    //     new PuntiVenditaCrud(puntoVendita: p, listaCategorie : puntiVenditaList )));
  }

  void _goToInsert(){
    // Navigator.push(context,  MaterialPageRoute(
    //     builder: (context) =>
    //     new PuntiVenditaCrud(puntoVendita: null, listaCategorie : puntiVenditaList )));
  }

}
