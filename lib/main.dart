// ignore_for_file: unused_element

import 'package:bus_uni/firebase_options.dart';
import 'package:bus_uni/screens/splash.dart';
import 'package:bus_uni/screens/splash_wait.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _requestLocationPermission();

  await initNotifications();
  //اتصال التطبيق بقاعدة البيانات
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EasyLocalization.ensureInitialized();
  runApp(
    // اعدادات اللغات التي يدعمها التطبيق
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
      // امتداد ملفات الترجمة
      path: 'assets/translation',
      child: const MyApp(),
    ),
  );
}

//طلب الاذن بالسماح الوصول للموقع
Future<void> _requestLocationPermission() async {
  final PermissionStatus status = await Permission.location.request();
  if (status != PermissionStatus.granted) {
    Permission.location.request();
  }
}

// السماح للتطبيق بارسال اشعارات
Future<void> initNotifications() async {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await FlutterLocalNotificationsPlugin().initialize(
    initializationSettings,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // بنية التطبيق الاساسية
    return MaterialApp(
      // عنوان التطبيق
      title: 'app_title'.tr(),
      // لتغيير لغة التطبيق
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      //اللون الاساسي للتطبيق
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      // لازالة علامة البناء عن التطبيق
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreenWait();
            } else {
              return const Scaffold(
                body: SplashScreen(),
              );
            }
          },
        ),
      ),
    );
  }
}
