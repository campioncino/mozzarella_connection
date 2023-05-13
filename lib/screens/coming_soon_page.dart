import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComingSoonPage extends StatelessWidget {
  @override
  Widget build(context) {
    // Pass the text down to another widget
    return  Center(
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
           Text("funzionalita_non_disponibile",
            // Even changing font-style is done through a Dart class.
            style: new TextStyle(fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
           Padding(padding: EdgeInsets.all(20.0)),
           Icon(
            Icons.warning,
            size: 200.0,
            color: Colors.grey[500],
          ),
          TextButton(onPressed: ()=>_onSignOutPress(context), child: Text("signOut"))
        ],
      ),
    );
  }

  Future _onSignOutPress(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }
}
