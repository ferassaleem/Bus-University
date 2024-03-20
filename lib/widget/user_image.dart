// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {super.key, required this.onPickImage, required this.imageCase});

  final void Function(File pickedImage) onPickImage;
  final String imageCase;
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickImageFile;

  void _pickImageCamera() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 300,
    );
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickImageFile!);
  }

  void _pickImageGalary() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
    );
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickImageFile!);
  }

  final String defaultImagePath = 'assets/default_user_image.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: const Color.fromARGB(255, 37, 51, 238),
          foregroundImage: _pickImageFile == null
              ? NetworkImage(widget.imageCase)
              : FileImage(File(_pickImageFile!.path)) as ImageProvider<Object>?,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickImageCamera,
              icon: const Icon(
                Icons.camera,
                color: Colors.white,
              ),
              label: Text(
                'camera'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _pickImageGalary,
              icon: const Icon(
                Icons.image,
                color: Colors.white,
              ),
              label: Text(
                'galarey'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
