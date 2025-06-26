import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File image) onImagePick;
  final double avatarRadius;
  final File? image;
  final bool isSignup;

  UserImagePicker({
    super.key,
    required this.avatarRadius,
    required this.onImagePick,
    required this.isSignup,
    this.image,
  });

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      widget.onImagePick(_image!);
    }
  }

  ImageProvider? getImage() {
    if (_image == null)
      return AssetImage(
        widget.isSignup
            ? "assets/images/addProfileImage.png"
            : "assets/images/addGroupImage.png",
      );
    if (_image != null) return FileImage(_image!);
    if (_image == null && widget.image != null) {
      final uri = Uri.tryParse(widget.image!.path);
      if (uri != null && uri.isAbsolute) {
        return NetworkImage(uri.toString());
      } else {
        return FileImage(widget.image!);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: widget.avatarRadius,
            backgroundColor: Colors.transparent,
            backgroundImage: getImage(),
          ),
        ),
        TextButton(
          onPressed: _pickImage,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Toque para escolher\n uma imagem',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryFixed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
