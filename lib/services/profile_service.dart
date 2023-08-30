// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import '../model/profile.dart';
//
// class ProfileService {
//
//   Future<Profile?> loadProfileById(String userId) async {
//     Profile? profilo;
//     try {
//       final response = await Supabase.instance.client
//           .from('profiles')
//           .select(
//       )
//           .eq('id', userId)
//           .maybeSingle()
//           ;
//       if (response.error != null) {
//         throw "Load profile failed: ${response.error!.message}";
//       }
//
//       if(response.data!=null){
//
//       }else{
//
//       }
//       setState(() {
//         debugPrint(response.data);
//         username = response.data?['username'] as String? ?? '';
//         website = response.data?['website'] as String? ?? '';
//         avatarUrl = response.data?['avatar_url'] as String? ?? '';
//         final updatedAt = response.data?['updated_at'] as String? ?? '';
//         avatarKey = '$avatarUrl-$updatedAt';
//       });
//     } catch (e) {
//       showMessage(e.toString());
//     } finally {
//       setState(() {
//         loadingProfile = false;
//       });
//     }
//   }
//
// }