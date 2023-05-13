import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
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
  String _appBarTitle = '';
  TextEditingController? _usernameController;
  TextEditingController? _phoneNumberController ;
  TextEditingController? _fullNameController ;
  String? _email;
  String? _username;
  String? _phoneNumber;
  String? _fullName;
  Map<String?, dynamic>? _options;

  var now = new DateTime.now();

  ScrollController? _scroll;
  FocusNode _focus = new FocusNode();


  // @override
  // void initState() {
  //   // TODO: implement initState
  //   final session = supabase.auth.currentSession;
  //   _user = session?.user;
  //   super.initState();
  //   initProfile();
  // }

  @override
  void initState() {
    super.initState();
    _options = this.widget.options;
    initUtente();
    // AppUtils.utente = _utente!;
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
        _utente = _options!['utente'];
        loadingProfile=false;
      }
      else{
        _loadProfile(_user!.id);
      }
    }else{
      debugPrint("qua non ci dovrei manco passare");
      // _utente= await _loadUtente(user!.id);
    }
    initProfile();
  }

  initProfile(){
    setState(() {
        _email = _utente!.email;
      _username = _utente!.username;
      _phoneNumber = _utente!.phoneNumber;
      _fullName = _utente!.name;
      _usernameController = new TextEditingController(text: _username  );
      _phoneNumberController = new TextEditingController(text: _phoneNumber);
      _fullNameController = new TextEditingController(text: _fullName);
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
        'id': _user?.id,
        'username': _username,
        'updated_at': DateTime.now().toString(),
        'phone_number': _phoneNumber,
        'full_name':_fullName,
        'email':_email
      };

      final response = await Supabase.instance.client
          .from('profiles')
          .upsert(updates)
          ;
      if (response.error != null) {
        throw "Update profile failed: ${response.error!.message}";
      }

      showMessage("Profile updated!");
      // Navigator.pushNamed(context, '/profile/changePassword');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      _updateProfileBtnController.reset();
    }
    }
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    if (loadingProfile) {
      return Scaffold(
        // appBar: AppBar(
        //   title: Text(_appBarTitle),
        // ),
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
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   title: Text(_appBarTitle),
        // ),
        body: Container(
          child: SingleChildScrollView(
            controller: _scroll ,
            child: Column(
              children: [
                SizedBox(height: 10,),
                // AvatarContainer(
                //   url: _avatarUrl ?? '',
                //   onUpdatePressed: (){},
                //   //onUpdatePressed: () => _updateAvatar(context),
                //   key: Key(_avatarKey ?? ''),
                // ),
                formFields(),
              ],
            ),
          ),
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
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
            TextFormField(
              enabled: false,
              initialValue: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
               TextFormField(
                 enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
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
                  decoration: InputDecoration(
                    labelText: 'Nome e Cognome',
                    labelStyle: TextStyle(
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
                      fontSize: 18.0,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  controller: _phoneNumberController,
                  // focusNode: _focusNodePhoneNumberController,
                  validator: _validateString,
                  onSaved: (val) => _phoneNumber = val,
                ),


              const SizedBox(
                height: 35.0,
              ),
              TextButton(onPressed: _validateInputs, child: Text('aggiorna')),
              RoundedLoadingButton(
                color: Colors.green,
                controller: _updateProfileBtnController,
                onPressed: () {
                  // _onUpdateProfilePress(context);
                  _validateInputs();
                },
                child: const Text('Aggiorna Profilo',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                   Navigator.pushNamed(context, '/profile/changePassword',arguments: _options);
                },
                child: const Text("Cambia password"),
              ),
              RoundedLoadingButton(
                color: Colors.red,
                controller: _signOutBtnController,
                onPressed: () {
                  _onSignOutPress(context);
                },
                child: const Text('Sign out',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ],),
          ),
        ),
      ],
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
//       print(response.error!.message);
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