// ignore_for_file: library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:bus_uni/screens/authscreen.dart';
import 'package:bus_uni/widget/gradient.dart';

// شاشة الانتظار
class SplashScreenWait extends StatefulWidget {
  const SplashScreenWait({super.key});

  @override
  _SplashScreenWaitState createState() => _SplashScreenWaitState();
}

class _SplashScreenWaitState extends State<SplashScreenWait> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 5),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Auth(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: StyleGradien(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logoBus.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'loading'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      letterSpacing: 1,
                      fontSize: 25,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 15, 7, 89),
                      decorationThickness: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
