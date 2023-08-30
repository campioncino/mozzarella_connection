import 'package:bufalabuona/utils/app_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../utils/ui_icons.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
    required this.productCode,
    required this.isEnabled
  });

  final String? imageUrl;
  final String? productCode;
  final void Function(String) onUpload;
  final bool isEnabled;

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.imageUrl == null || widget.imageUrl!.isEmpty)
          Container(
            width: 150,
            height: 150,
            color: Colors.grey[50],
            child:  Center(
             child: Image.asset('assets/images/no_picture.png'),
            ),
          )
        else
          _sizedContainer(
             CachedNetworkImage(
              imageUrl: widget.imageUrl!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
              const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>  UiIcons.error,
            ),
          ),
          // Image.network(
          //   widget.imageUrl!,
          //   width: 150,
          //   height: 150,
          //   fit: BoxFit.cover,
          // ),
       if(this.widget.isEnabled) ElevatedButton(
          onPressed: _isLoading ? null : _upload,
          child: const Text('Upload'),
        ),
      ],
    );
  }

  Future<void> _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      // final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final fileName='${DateTime.now().toIso8601String()}.${this.widget.productCode}.$fileExt';
      final filePath = fileName;

      await supabase.storage.from('avatars').uploadBinary(
        filePath,
        // 'public/avatar1.png',
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false)
        // FileOptions(contentType: imageFile.mimeType),
      );
      final imageUrlResponse = await supabase.storage
          .from('avatars')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      widget.onUpload(imageUrlResponse);
    } on StorageException catch (error) {
      if (mounted) {
        AppUtils.errorSnackBar(_scaffoldKey, error.message);
        // context.showErrorSnackBar(message: error.message);
      }
    } catch (error) {
      if (mounted) {
        AppUtils.errorSnackBar(_scaffoldKey, 'Unexpected error occurred');
        // context.showErrorSnackBar(message: 'Unexpected error occurred');
      }
    }

    setState(() => _isLoading = false);
  }

  Widget _sizedContainer(Widget child) {
    return SizedBox(
      width: 300.0,
      height: 150.0,
      child: Center(child: child),
    );
  }
}
