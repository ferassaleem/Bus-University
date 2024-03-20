// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';

import 'package:bus_uni/screens/forgot_your_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:bus_uni/widget/email_message.dart';
import 'package:bus_uni/widget/gradient.dart';
import 'package:bus_uni/widget/user_image.dart';

class LoginAndSignup extends StatefulWidget {
  const LoginAndSignup({super.key});

  @override
  State<LoginAndSignup> createState() => _LoginAndSignupState();
}

class _LoginAndSignupState extends State<LoginAndSignup> {
  String imagepersonal =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShB7IwN9gr4q2Tn-1CRfbgANRN-8SWlYMMy9iq467T1A&s';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firebase = FirebaseAuth.instance;
  var _islogin = true;
  var _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _selectImage;
  var _isUploading = false;

  void _submit() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    if (!_islogin && _selectImage == null) {
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
      if (_islogin) {
        final UserCredential userCredential =
            await _firebase.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
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
            .collection('information')
            .doc(userCredential.user!.uid)
            .set({
          'userId': userCredential.user!.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'userType': 'student',
          'image': imageUrl,
          'latitude': 31.788938,
          'longitude': 35.928986,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': '',
          'phonenumber': '',
          'living': '',
          'age': '',
          'college': '',
          'specialization': '',
          'academic_year': '',
        });
        DocumentReference locationReference2 = FirebaseFirestore.instance
            .collection('students')
            .doc(userCredential.user!.uid);
        await locationReference2.set({
          'userId': userCredential.user!.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'userType': 'student',
          'image': imageUrl,
          'latitude': 31.788938,
          'longitude': 35.928986,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': '',
          'phonenumber': '',
          'living': '',
          'age': '',
          'college': '',
          'specialization': '',
          'academic_year': '',
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
        ),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 3, 100, 191),
              foregroundColor: Colors.white,
              title: _islogin
                  ? Text(
                      'login_button'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    )
                  : Text(
                      'create_account_button'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
              actions: [
                IconButton(
                  onPressed: () async {
                    await EasyLocalization.of(context)?.setLocale(
                      EasyLocalization.of(context)?.locale ==
                              const Locale('en', 'US')
                          ? const Locale('ar', 'SA')
                          : const Locale('en', 'US'),
                    );
                  },
                  icon: const Icon(
                    Icons.translate,
                  ),
                )
              ]),
          body: Container(
            decoration: BoxDecoration(
              gradient: StyleGradien(),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                                if (!_islogin)
                                  UserImagePicker(
                                    onPickImage: (File pickedImage) {
                                      _selectImage = pickedImage;
                                    },
                                    imageCase: imagepersonal,
                                  ),
                                const SizedBox(height: 20),
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
                                if (!_islogin)
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
                                      width: 24.0,
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
                                const SizedBox(height: 10),
                                if (_islogin)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPassword(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'forgot_password'.tr(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color:
                                            Color.fromARGB(255, 124, 174, 244),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 15),
                                if (_isUploading)
                                  const CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                if (!_isUploading)
                                  ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 50, 189),
                                    ),
                                    child: Text(
                                      _islogin
                                          ? 'login_button'.tr()
                                          : 'sign_up'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                if (!_isUploading)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _islogin = !_islogin;
                                      });
                                    },
                                    child: Text(
                                      _islogin
                                          ? 'create_account_button'.tr()
                                          : 'already_have_account'.tr(),
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 216, 154, 154)),
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
