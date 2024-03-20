// ignore_for_file: use_build_context_synchronously

import 'package:bus_uni/screens/authscreen.dart';
import 'package:bus_uni/widget/gradient.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 3, 100, 191),
          foregroundColor: Colors.white,
          title: Text(
            'setting'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
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
                Icons.arrow_forward,
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
                  width: 150,
                ),
                Card(
                  color: const Color.fromARGB(255, 76, 100, 186),
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: 300,
                      height: 500,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: Container(
                                  color:
                                      const Color.fromARGB(255, 110, 159, 211),
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      await EasyLocalization.of(context)
                                          ?.setLocale(
                                        EasyLocalization.of(context)?.locale ==
                                                const Locale('en', 'US')
                                            ? const Locale('ar', 'SA')
                                            : const Locale('en', 'US'),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.translate,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    label: Text(
                                      'change_language'.tr(),
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 100),
                              SizedBox(
                                width: 200,
                                child: Container(
                                    color: const Color.fromARGB(
                                        255, 110, 159, 211),
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        // تسجيل الخروج من Firebase Auth
                                        await FirebaseAuth.instance.signOut();

                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const Auth(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.logout,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      label: Text(
                                        'sign_out'.tr(),
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
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
  }
}
