// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:bus_uni/widget/app_bar.dart';
import 'package:bus_uni/widget/email_message.dart';
import 'package:bus_uni/widget/gradient.dart';
import 'package:bus_uni/widget/user_image.dart';

class AddDriver extends StatefulWidget {
  final String password;
  final String userEmail;

  const AddDriver({super.key, required this.password, required this.userEmail});

  @override
  State<AddDriver> createState() => _AddDriverState();
}

class _AddDriverState extends State<AddDriver> {
  final FirebaseAuth _firebase = FirebaseAuth.instance;

  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _numberchairsController = TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _jobNumberController = TextEditingController();
  bool _isUploading = false;

  File? _selectImage;
  @override
  void initState() {
    super.initState();
    usernameFuture = getUsers();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUsers() async {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .doc(userId)
        .get();

    return snapshot;
  }

  void _addDriver() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    if (_selectImage == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('message_error_photo'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
      return;
    }
    try {
      setState(() {
        _isUploading = true;
      });
      final UserCredential userCredential =
          await _firebase.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child('${userCredential.user!.uid}.jpg');
      await storageRef.putFile(_selectImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .collection('locationDriver')
          .doc(userCredential.user!.uid)
          .set({
        'latitude': 31.788938,
        'longitude': 35.928986,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .collection('information')
          .doc(userCredential.user!.uid)
          .set({
        'driverId': userCredential.user!.uid,
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'userType': 'driver',
        'image': imageUrl,
        'numberstudents': 0,
        'numberchairsavailable': int.parse(_numberchairsController.text.trim()),
        'numberchairs': int.parse(_numberchairsController.text.trim()),
        'number': int.parse(_busNumberController.text.trim()),
        'JobNumber': _jobNumberController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'gender': '',
        'phonenumber': '',
        'living': '',
        'age': '',
      });
      DocumentReference driverReference = FirebaseFirestore.instance
          .collection('drivers')
          .doc(userCredential.user!.uid);

      await driverReference.set(
        {
          'userId': userCredential.user!.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'userType': 'driver',
          'image': imageUrl,
          'numberstudents': 0,
          'numberchairsavailable':
              int.parse(_numberchairsController.text.trim()),
          'numberchairs': int.parse(_numberchairsController.text.trim()),
          'number': int.parse(_busNumberController.text.trim()),
          'JobNumber': _jobNumberController.text.trim(),
          'latitude': 31.788938,
          'longitude': 35.928986,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': '',
          'phonenumber': '',
          'living': '',
          'age': '',
        },
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_add_driver'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: widget.userEmail, password: widget.password);
                  Navigator.pop(context);
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: StyleAppBar('add_driver'.tr()),
          body: Container(
            decoration: BoxDecoration(
              gradient: StyleGradien(),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logoBus.png',
                      width: 250,
                    ),
                    Card(
                      color: const Color.fromARGB(255, 76, 100, 186),
                      margin: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                //image
                                UserImagePicker(
                                  onPickImage: (File pickedImage) {
                                    _selectImage = pickedImage;
                                  },
                                  imageCase: '',
                                ),
                                const SizedBox(height: 20),
                                //email
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    labelText: 'email_label'.tr(),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    suffixIcon: SizedBox(
                                      width: 24.0,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          iconSize: 15,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const EmailMessage();
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.help,
                                            color: Color.fromARGB(
                                                255, 82, 177, 255),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  controller: _emailController,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !value.contains('@iu.edu.jo')) {
                                      return 'email_message'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                //username
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'username_label'.tr(),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  controller: _usernameController,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 3) {
                                      return 'username_message'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                // bus number
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'bus_number'.tr(),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: _busNumberController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'bus_number_message'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                //number chairs
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'number_chairs'.tr(),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: _numberchairsController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'number_chairs_message'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                //job number
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'job_number'.tr(),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  controller: _jobNumberController,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 5) {
                                      return 'job_number_message'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                //password
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'password_label'.tr(),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: SizedBox(
                                      width: 24.0, // Adjust the width as needed
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          iconSize: 15,
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: _isPasswordVisible
                                                ? const Color.fromARGB(
                                                    255, 82, 177, 255)
                                                : const Color.fromARGB(
                                                    255, 126, 126, 132),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  obscureText: !_isPasswordVisible,
                                  controller: _passwordController,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 5) {
                                      return 'password_message'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                if (_isUploading)
                                  const CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                if (!_isUploading)
                                  ElevatedButton(
                                    onPressed: _addDriver,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 50, 189),
                                    ),
                                    child: Text(
                                      'add_driver'.tr(),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
