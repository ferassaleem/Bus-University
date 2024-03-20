// ignore_for_file: must_be_immutable

import 'package:bus_uni/widget/email_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  bool _isUploading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });
      FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('worng'.tr()),
            content: Text(
              'message_password_recovery'.tr(),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'done_button'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
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
    return Form(
      key: _formKey,
      child: AlertDialog(
        backgroundColor: const Color.fromARGB(255, 107, 130, 147),
        title: Text('password_recovery'.tr()),
        scrollable: true,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
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
                          color: Color.fromARGB(255, 82, 177, 255),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploading)
                    const CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  if (!_isUploading)
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 96, 13),
                        textStyle: const TextStyle(color: Colors.white),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(
                        'send_password_reset_email'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 186, 7, 7),
                      textStyle: const TextStyle(color: Colors.white),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Text(
                      'cancel'.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
