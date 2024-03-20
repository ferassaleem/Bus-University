// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:bus_uni/screens/authscreen.dart';
import 'package:bus_uni/widget/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:bus_uni/widget/gradient.dart';

class DetailsDriver extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String imageUsers;
  final String userId;
  final String gender;
  final String phone;
  final String living;
  final String age;

  const DetailsDriver({
    required this.userName,
    required this.userEmail,
    required this.imageUsers,
    required this.userId,
    required this.gender,
    required this.phone,
    required this.living,
    required this.age,
    Key? key,
  }) : super(key: key);

  @override
  State<DetailsDriver> createState() => _DetailsDriverState();
}

class _DetailsDriverState extends State<DetailsDriver> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _livingController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isUploading = false;
  File? _selectImage;

  @override
  void initState() {
    super.initState();

    _emailController.text = widget.userEmail;
    _usernameController.text = widget.userName;
    _genderController.text = widget.gender;
    _phoneController.text = widget.phone;
    _livingController.text = widget.living;
    _ageController.text = widget.age;
  }

  void _updatUser() async {
    try {
      setState(() {
        _isUploading = true;
      });

      if (_selectImage != null) {
        // إذا كانت الصورة مختارة، قم بتحديث الصورة
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${widget.userId}.jpg');
        await storageRef.putFile(_selectImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('information')
            .doc(widget.userId)
            .set({
          'username': _usernameController.text.trim(),
          'image': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
        }, SetOptions(merge: true));
        DocumentReference driverReference =
            FirebaseFirestore.instance.collection('drivers').doc(widget.userId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'image': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
        }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('information')
            .doc(widget.userId)
            .set({
          'username': _usernameController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
        }, SetOptions(merge: true));
        DocumentReference driverReference =
            FirebaseFirestore.instance.collection('drivers').doc(widget.userId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
        }, SetOptions(merge: true));
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('update_data'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  Navigator.pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isUploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text(e.message ?? 'Authentication failed'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  Navigator.pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('my_profile'.tr()),
        backgroundColor: const Color.fromARGB(255, 3, 100, 191),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Auth(),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradien(),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // image
                  UserImagePicker(
                    onPickImage: (File? pickedImage) {
                      setState(() {
                        _selectImage = pickedImage;
                      });
                    },
                    imageCase: widget.imageUsers,
                  ),
                  const SizedBox(height: 15),
                  // email
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 114, 139, 164),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'email_label'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    readOnly: true,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 15),
                  //username
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 114, 139, 164),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'username_label'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.words,
                    controller: _usernameController,
                  ),

                  const SizedBox(height: 15),
                  // phone
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 114, 139, 164),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'phonenumber'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    autocorrect: false,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 15),
                  //living
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 114, 139, 164),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'living'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.words,
                    controller: _livingController,
                  ),
                  const SizedBox(height: 15),
                  //age
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 114, 139, 164),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'age'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    controller: _ageController,
                  ),

                  const SizedBox(height: 15),
                  if (_isUploading)
                    const CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  if (!_isUploading)
                    ElevatedButton(
                      onPressed: _updatUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 50, 189),
                      ),
                      child: Text(
                        'update'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
