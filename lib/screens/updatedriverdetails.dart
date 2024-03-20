// ignore_for_file: avoid_print, unused_field, use_build_context_synchronously

import 'dart:io';

import 'package:bus_uni/widget/app_bar.dart';
import 'package:bus_uni/widget/gradient.dart';
import 'package:bus_uni/widget/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UpdateDriver extends StatefulWidget {
  final String driverName;
  final int busNumber;
  final String driverJobNumber;
  final String driverEmail;
  final String driverImageusers;
  final int numberChairs;
  final String driverId;

  const UpdateDriver({
    required this.driverName,
    required this.busNumber,
    required this.driverJobNumber,
    required this.driverEmail,
    required this.driverImageusers,
    required this.numberChairs,
    required this.driverId,
    Key? key,
  }) : super(key: key);

  @override
  State<UpdateDriver> createState() => _UpdateDriverState();
}

class _UpdateDriverState extends State<UpdateDriver> {
  final FirebaseAuth _firebase = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _numberchairsController = TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _jobNumberController = TextEditingController();
  bool _isUploading = false;
  File? _selectImage;

  @override
  void initState() {
    super.initState();

    _emailController.text = widget.driverEmail;
    _usernameController.text = widget.driverName;
    _numberchairsController.text = widget.numberChairs.toString();
    _busNumberController.text = widget.busNumber.toString();
    _jobNumberController.text = widget.driverJobNumber;
  }

  void _updateDriver() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      if (_selectImage != null) {
        // إذا كانت الصورة مختارة، قم بتحديث الصورة
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${widget.driverId}.jpg');
        await storageRef.putFile(_selectImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.driverId)
            .collection('information')
            .doc(widget.driverId)
            .set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'image': imageUrl,
          'numberchairsavailable':
              int.parse(_numberchairsController.text.trim()),
          'numberchairs': int.parse(_numberchairsController.text.trim()),
          'number': int.parse(_busNumberController.text.trim()),
          'JobNumber': _jobNumberController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        DocumentReference driverReference = FirebaseFirestore.instance
            .collection('drivers')
            .doc(widget.driverId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'image': imageUrl,
          'numberchairsavailable':
              int.parse(_numberchairsController.text.trim()),
          'numberchairs': int.parse(_numberchairsController.text.trim()),
          'number': int.parse(_busNumberController.text.trim()),
          'JobNumber': _jobNumberController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.driverId)
            .collection('information')
            .doc(widget.driverId)
            .set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'numberchairsavailable':
              int.parse(_numberchairsController.text.trim()),
          'numberchairs': int.parse(_numberchairsController.text.trim()),
          'number': int.parse(_busNumberController.text.trim()),
          'JobNumber': _jobNumberController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        DocumentReference driverReference = FirebaseFirestore.instance
            .collection('drivers')
            .doc(widget.driverId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'numberchairsavailable':
              int.parse(_numberchairsController.text.trim()),
          'numberchairs': int.parse(_numberchairsController.text.trim()),
          'number': int.parse(_busNumberController.text.trim()),
          'JobNumber': _jobNumberController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_add_driver'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text(e.message ?? 'Authentication failed'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
      appBar: StyleAppBar('${'bus_number'.tr()}: ${widget.busNumber}'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradien(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserImagePicker(
                      onPickImage: (File? pickedImage) {
                        setState(() {
                          _selectImage = pickedImage;
                        });
                      },
                      imageCase: widget.driverImageusers,
                    ),
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
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'username_message'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
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
                        labelText: 'bus_number'.tr(),
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
                      controller: _busNumberController,
                    ),
                    const SizedBox(height: 15),
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
                        labelText: 'number_chairs'.tr(),
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
                      keyboardType: TextInputType.number,
                      controller: _numberchairsController,
                      validator: (value) {
                        if (value == null) {
                          return 'number_chairs_message'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
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
                        labelText: 'job_number'.tr(),
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
                      controller: _jobNumberController,
                      validator: (value) {
                        if (value == null || value.trim().length < 5) {
                          return 'job_number_message'.tr();
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
                        onPressed: _updateDriver,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 0, 50, 189),
                        ),
                        child: Text(
                          'تحديث'.tr(),
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
      ),
    );
  }
}
