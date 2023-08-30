import 'package:bufalabuona/main.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:bufalabuona/utils/ui_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/ui_icons.dart';
import '/components/auth_required_state.dart';


class ProfileScreen extends StatefulWidget {
  final Utente? utente;
  final Map<String?, dynamic>? options;
  const ProfileScreen({Key? key,  this.options,this.utente}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _ProfileScreenState();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();


  final RoundedLoadingButtonController _signOutBtnController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _updateProfileBtnController = RoundedLoadingButtonController();

  // final _picker = ImagePicker();

  Utente? _utente;
  User? _user;
  bool loadingProfile = true;
  bool isValid=false;
  String _appBarTitle = 'Modifica Impostazioni';
  TextEditingController? _usernameController;
  TextEditingController? _phoneNumberController ;
  TextEditingController? _fullNameController ;
  TextEditingController? _passwordController;
  TextEditingController _emailController = new TextEditingController();
  String? _email;
  String? _username;
  String? _phoneNumber;
  String? _fullName;
  String? _password;

  bool _obscureText = true;
  Icon _eyeIcon = UiIcons.eyeSlash;


  Map<String?, dynamic>? _options;

  var now = new DateTime.now();

  ScrollController? _scroll;
  FocusNode _focus = new FocusNode();


  @override
  void initState() {
    super.initState();
    _options = this.widget.options;
    _scroll =  new ScrollController();
    initUtente();
  }

  @override
  void onAuthenticated(Session session) async {
    final user = session.user;
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }


  initUtente() async {

    if(_options!=null){
      _options = this.widget.options;

      if(_options!['utente']!=null){
        _options!['route']='PROFILE';
        _utente = _options!['utente'];
        loadingProfile=false;
        _password = await AppUtils.retrievePassword();
      }
      else{
        _loadProfile(_user!.id);
      }
    }else{
      debugPrint("qua non ci dovrei manco passare");
    }
    initProfile();
  }

  initProfile() {
    setState(()  {
      _email = _utente!.email;
      _username = _utente!.username;
      _phoneNumber = _utente!.phoneNumber;
      _fullName = _utente!.name;
      _usernameController = new TextEditingController(text: _username  );
      _phoneNumberController = new TextEditingController(text: _phoneNumber);
      _fullNameController = new TextEditingController(text: _fullName);
      _passwordController = new TextEditingController(text: _password);
      _emailController = new TextEditingController(text: _email);
    });
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final response = await supabase.from('profiles')
          .select(
          ).eq('id', userId)
          .maybeSingle()
          ;
      if (response == null) {
        throw "Load profile failed";
      }
    } catch (e) {
      debugPrint("error :${e.toString()}");
      // showMessage(e.toString());
    } finally {
      setState(() {
        loadingProfile = false;
      });
    }
  }

  Future _onSignOutPress(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
  }

  // Future _updateAvatar(BuildContext context) async {
  //   try {
  //     final pickedFile = await _picker.pickImage(
  //       source: ImageSource.gallery,
  //       maxHeight: 600,
  //       maxWidth: 600,
  //     );
  //     if (pickedFile == null) {
  //       return;
  //     }
  //
  //     final size = await pickedFile.length();
  //     if (size > 1000000) {
  //       throw "The file is too large. Allowed maximum size is 1 MB.";
  //     }
  //
  //     final bytes = await pickedFile.readAsBytes();
  //     final fileName = _avatarUrl == '' ? '${randomString(15)}.jpg' : _avatarUrl;
  //     const fileOptions = FileOptions(upsert: true);
  //     final uploadRes = await Supabase.instance.client.storage
  //         .from('avatars')
  //         .uploadBinary(fileName, bytes, fileOptions: fileOptions);
  //
  //     if (uploadRes.error != null) {
  //       throw uploadRes.error!.message;
  //     }
  //
  //     final updatedAt = DateTime.now().toString();
  //     final res = await Supabase.instance.client.from('profiles').upsert({
  //       'id': user!.id,
  //       'avatar_url': fileName,
  //       'updated_at': updatedAt,
  //       'phone_number': _phoneNumber,
  //       'address':_address,
  //       'vat_number':_vatNumber,
  //       'full_name':_fullName
  //     });
  //     if (res.error != null) {
  //       throw res.error!.message;
  //     }
  //
  //     setState(() {
  //       _avatarUrl = fileName;
  //       _avatarKey = '$fileName-$updatedAt';
  //     });
  //     showMessage("Avatar updated!");
  //   } catch (e) {
  //     showMessage(e.toString());
  //   }
  // }

  void validateUserData(){

    if(_username!=null && _username!.isNotEmpty ){
      setState(() {
        isValid = true;
      });
    }
  }

  Future _onUpdateProfilePress(BuildContext context) async {
    if(!isValid){
      showMessage('Compila tutti i campi obbligatri');
      _updateProfileBtnController.reset();
    }else{
    try {
      FocusScope.of(context).unfocus();
      final updates = {
        'id': _utente!.profileId,
        'username': _username,
        'updated_at': DateTime.now().toString(),
        'phone_number': _phoneNumber,
        'full_name':_fullName,
        'email':_email
      };

      final response = await supabase
          .from('profiles')
          .upsert(updates).select()
          ;
      if (response!= null) {
        showMessage("Profilo aggiornato con successo!");
      }else{
        throw "Errore nell'aggiornamento del profilo: ${response.error!.message}";
      }
    } catch (e) {
      showMessage(e.toString());
    } finally {
      _updateProfileBtnController.reset();
    }
    }
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message,style: TextStyle(color: Colors.greenAccent),),backgroundColor: Colors.white70,);
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    if (loadingProfile) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          backgroundColor: UiColors.PRIMARY,
          title: _utente!.ruolo =='admin' ? null :Text(_appBarTitle,style: TextStyle(color: Colors.white)),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: scaffoldKey,
        appBar:  AppBar(
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          backgroundColor: UiColors.PRIMARY,
          title: _utente!.ruolo =='admin' ? null : Text(_appBarTitle,style: TextStyle(color: Colors.white)),
        ) ,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // height: MediaQuery.of(context).size.height/10*2,
              height: 100,
              color: UiColors.PRIMARY,
              child: Align(
                alignment:Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18.0,18,18,10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiIcons.editProfile,
                      SizedBox(height: 22,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:18.0,vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("${AppUtils.utente.name}",style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w800),maxLines: 3,),
                          ],
                        ),
                      ),                        ],
                  ),
                ),
              ),),
             Expanded(
               child: SingleChildScrollView(
                 controller: _scroll,
                 child: Column(
                  children: [
                    // SizedBox(height: 10,),
                    formFields(),
                    ListTile(title: Text("Cambia Password",style: TextStyle(color: Colors.black45),),trailing: IconButton(icon: UiIcons.chevronRight,
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile/changePassword',arguments: _options);
                        },),),
                    ListTile(title: Text("Cambia Utente",style: TextStyle(color: Colors.purple[300]),),trailing: IconButton(icon: UiIcons.chevronRight,
                      onPressed: ()=> _onSignOutPress(context),),),
                    SizedBox(height: 15,),
                    RoundedLoadingButton(
                      borderRadius: 15,
                      color: Colors.green,
                      controller: _updateProfileBtnController,
                      onPressed: () {
                        // _onUpdateProfilePress(context);
                        _validateInputs();
                      },
                      child: const Text('Salva Modifiche',
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ],
                  ),
               ),
             ),



          ],
        ),
      );
    }
  }



  void _validateInputs() {
    validateUserData();
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      _onUpdateProfilePress(context);
    }
    if((!isValid)){_updateProfileBtnController.reset();}
  }

Widget formFields(){
  return Padding(
    padding:  EdgeInsets.all(20.0),
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              enabled: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Colors.green[800],
                  fontSize: 18.0,
                ),
              ),
              controller: _emailController,
            ),
            TextFormField(
              enabled: false,
              decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      color: Colors.green[900],
                      fontSize: 18.0,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  controller: _usernameController,
                  // focusNode: _focusNodeUsernameController,
                  validator: _validateMinLength,
                  onSaved: (val) => _username = val,
                ),
            TextFormField(
              readOnly: true,
              obscuringCharacter: '*',
              obscureText: _obscureText,
              controller: _passwordController,
              decoration:  InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.green[900],
                  fontSize: 18.0,
                ),
                suffixIcon: new IconButton(
                    icon: _eyeIcon, iconSize: 18.0, onPressed: _toggle),
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nome e Cognome',
                labelStyle: TextStyle(
                  color: Colors.green[900],
                  fontSize: 18.0,
                ),
              ),
              keyboardType: TextInputType.text,
              controller: _fullNameController,
              // focusNode: _focusNodeFullNameController,
              validator: _validateString,
              onSaved: (val) => _fullName = val,
            ),

            TextFormField(
              decoration: InputDecoration(
                labelText: 'Numero Telefonico',
                labelStyle: TextStyle(
                  color: Colors.green[900],
                  fontSize: 18.0,
                ),
              ),
              keyboardType: TextInputType.text,
              controller: _phoneNumberController,
              // focusNode: _focusNodePhoneNumberController,
              validator: _validateString,
              onSaved: (val) => _phoneNumber = val,
            ),

          // const SizedBox(
          //   height: 5.0,
          // ),

        ],),
      ),
    ),
  );
}

  String? _validateMinLength(String? value) {
      if (value!.isEmpty) {
        return "campo obbligatorio";
      }
     else if (value.length < 3) {{
        return "inserire almeno 4 caratteri";
       }
    } else {
      return null;
    }
  }
  String? _validateString(String? value) {
    if (value!.isEmpty) {
      return "campo obbligatorio";
    } else {
      return null;
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
      _obscureText
          ? _eyeIcon = UiIcons.eyeSlash
          : _eyeIcon = UiIcons.eye;
    });
  }

}
// class AvatarContainer extends StatefulWidget {
//   final String url;
//   final void Function() onUpdatePressed;
//   const AvatarContainer(
//       {required this.url, required this.onUpdatePressed, Key? key})
//       : super(key: key);
//
//   @override
//   _AvatarContainerState createState() => _AvatarContainerState();
// }
//
// class _AvatarContainerState extends State<AvatarContainer> {
//   _AvatarContainerState();
//
//   bool loadingImage = false;
//   Uint8List? image;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.url != '') {
//       downloadImage(widget.url);
//     }
//   }
//
//   Future<bool> downloadImage(String path) async {
//     setState(() {
//       loadingImage = true;
//     });
//
//     final response =
//     await Supabase.instance.client.storage.from('avatars').download(path);
//     if (response.error == null) {
//       setState(() {
//         image = response.data;
//         loadingImage = false;
//       });
//     } else {
//       debugPrint(response.error!.message);
//       setState(() {
//         loadingImage = false;
//       });
//     }
//     return true;
//   }
//
//   ImageProvider<Object> _getImage() {
//     if (image != null) {
//       return MemoryImage(image!);
//     } else {
//       return const AssetImage('assets/images/noavatar.jpeg');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loadingImage) {
//       return const CircleAvatar(
//         radius: 25,
//         child: Align(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     } else {
//       return CircleAvatar(
//         radius: 45,
//         backgroundImage: _getImage(),
//         child: Stack(children: [
//           Align(
//             alignment: Alignment.bottomRight,
//             child: IconButton(
//               icon: const CircleAvatar(
//                 radius: 25,
//                 backgroundColor: Colors.white70,
//                 child: Icon(
//                   CupertinoIcons.camera,
//                   size: 18,
//                 ),
//               ),
//               onPressed: () => widget.onUpdatePressed(),
//             ),
//           ),
//         ]),
//       );
//     }
//   }
// }