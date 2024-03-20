// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, prefer_collection_literals, unnecessary_null_comparison, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bus_uni/screens/detailsdriver.dart';
import 'package:bus_uni/screens/splash_wait.dart';
import 'package:bus_uni/widget/app_bar.dart';
import 'package:bus_uni/widget/drawer.dart';
import 'package:bus_uni/widget/error_operation.dart';
import 'package:bus_uni/widget/gradient.dart';

User users = FirebaseAuth.instance.currentUser!;

String userId = users.uid;

final usersRef = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('information');

class DriverScreen extends StatefulWidget {
  const DriverScreen({
    Key? key,
  }) : super(key: key);

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late BitmapDescriptor customIcon;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position? _position;
  int nearbyPeopleCount = 0;
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  late Future<QuerySnapshot<Map<String, dynamic>>> usernameFuture2;
  bool notificationSent = false;
  late Timer _timer;
  late Timer timer;
  String currentLocation = '';
  var _isUploading = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        setState(
          () {
            notificationSent = false;
          },
        );
      },
    );
    _loadCustomIcon();
    _getCurrentLocation();
    _getUpdateCurrentLocation();
    timer = Timer.periodic(
      const Duration(seconds: 10),
      (Timer timer) {
        _getUpdateCurrentLocation();
      },
    );
    usernameFuture = getUsers();
    usernameFuture2 = getUsers2();

    _initMessaging();

    // استدعاء الدالة للتحقق وحذف المستخدمين القريبين كل دقيقة
    Timer.periodic(
      const Duration(minutes: 1),
      (Timer timer) {
        _checkAndDeleteNearbyUsers();
      },
    );
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

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers2() async {
    User user = FirebaseAuth.instance.currentUser!;
    userId = user.uid;
    return await usersRef.where('email', isEqualTo: '${users.email}').get();
  }

  void _updateUserLocationdirect(double latitude, double longitude) async {
    User user = FirebaseAuth.instance.currentUser!;
    if (user != null) {
      String userId = user.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('locationDriver')
          .doc(userId)
          .set({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(userId)
          .update({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _getUpdateCurrentLocation() async {
    _position = await Geolocator.getCurrentPosition();
    _updateUserLocationdirect(_position!.latitude, _position!.longitude);
  }

  void _getCurrentLocation() {
    try {
      setState(
        () {
          _isUploading = true;
        },
      );
      Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      ).then(
        (Position position) {
          setState(
            () {
              _position = position;
              _isUploading = false;
            },
          );
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  position.latitude,
                  position.longitude,
                ),
                zoom: 19,
              ),
            ),
          );
        },
      ).catchError(
        (error) {
          ErrorOperator(
            errorMessage: '$error',
          );
        },
      );
    } catch (e) {
      ErrorOperator(
        errorMessage: '$e',
      );
      setState(
        () {
          _isUploading = false;
        },
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initMessaging() async {
    await Firebase.initializeApp();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then(
      (token) {
        ErrorOperator(errorMessage: '${'firebase_token'.tr()}: $token');
      },
    );
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        ErrorOperator(errorMessage: '${'error'.tr()}: $message');
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        ErrorOperator(errorMessage: '${'error'.tr()}: $message');
      },
    );
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    _geolocatorPlatform.getPositionStream().listen(
      (position) {
        _checkNearbyPeople(position);
      },
    );
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    ErrorOperator(errorMessage: '${'error'.tr()}: $message');
  }

  void _checkNearbyPeople(Position position) {
    const double proximityThreshold = 25; // المسافة بالأمتار

    nearbyPeopleCount = 0; // إعادة تهيئة العداد

    for (var marker in markers) {
      var personLat = marker.position.latitude;
      var personLon = marker.position.longitude;
      var distance = distanceBetweenPoints(
        position.latitude,
        position.longitude,
        personLat,
        personLon,
      );
      if (distance <= proximityThreshold) {
        if (notificationSent == false) {
          notificationSent = true;

          _sendNotification();
        }
        nearbyPeopleCount++; // زيادة العداد لكل شخص قريب
      }
    }
    // حدث واجهة المستخدم لعرض عدد الأشخاص القريبين
    setState(
      () {},
    );
  }

  void _sendNotification() async {
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      priority: Priority.high,
      importance: Importance.max,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );
    await FlutterLocalNotificationsPlugin().show(
      0,
      'worng'.tr(),
      'In_front_of_you_is_a_student_on_the_road'.tr(),
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> _loadCustomIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/images/Icon.png');
  }

  void _checkAndDeleteNearbyUsers() async {
    const double proximityThreshold = 3; // المسافة بالأمتار

    for (var marker in markers) {
      var personLat = marker.position.latitude;
      var personLon = marker.position.longitude;
      var distance = distanceBetweenPoints(
        _position!.latitude,
        _position!.longitude,
        personLat,
        personLon,
      );
      if (distance <= proximityThreshold) {
        // حذف المستخدم القريب من الداتابيس
        await FirebaseFirestore.instance
            .collection('students') // افترض هنا اسم الكولكشن للمستخدمين
            .where('latitude', isEqualTo: personLat)
            .where('longitude', isEqualTo: personLon)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });
      }
    }
  }

  void _incrementNumberStudentsAndDecrementNumberChairs() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;

    // تحديث قيمة numberstudents في وثيقة السائق
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(userId)
        .update({'numberstudents': FieldValue.increment(1)});

    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(userId)
        .update({'numberchairsavailable': FieldValue.increment(-1)});
  }

  void _updateChairsAvailable(int newChairsAvailable) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(userId)
          .update({'numberchairsavailable': newChairsAvailable});
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(userId)
          .update({'numberstudents': 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collectionGroup('students').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              markers.clear();
              for (var doc in snapshot.data!.docs) {
                final long = doc.get('longitude');
                final lat = doc.get('latitude');
                final username = doc.get('username');
                markers.add(
                  Marker(
                    markerId: MarkerId(doc.id),
                    position: LatLng(lat, long),
                    infoWindow: InfoWindow(title: username ?? 'User Name'),
                    icon: customIcon,
                  ),
                );
              }

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: usernameFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreenWait();
                  } else if (snapshot.hasError) {
                    return ErrorOperator(
                        errorMessage: '${'error'}: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    String username = snapshot.data!['username'];
                    String imageuser = snapshot.data!['image'];
                    String gender = snapshot.data!['gender'];
                    String phone = snapshot.data!['phonenumber'];
                    String living = snapshot.data!['living'];
                    String age = snapshot.data!['age'];

                    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: usernameFuture2,
                      builder: (context, snapshot) {
                        return Scaffold(
                          drawer: MyDrawer(
                            snapshot: snapshot,
                            drawemail:
                                '${FirebaseAuth.instance.currentUser?.email}',
                            drawusername: username,
                            imageusers: imageuser,
                            detailsUser: () {
                              Navigator.pop(context);
                              Navigator.of(context).pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsDriver(
                                    userName: username,
                                    userEmail:
                                        '${FirebaseAuth.instance.currentUser?.email}',
                                    imageUsers: imageuser,
                                    userId: userId,
                                    gender: gender,
                                    phone: phone,
                                    living: living,
                                    age: age,
                                  ),
                                ),
                              );
                            },
                          ),
                          appBar: StyleAppBar(username),
                          body: Container(
                            height: MediaQuery.of(context)
                                .size
                                .height, // تعيين ارتفاع الشاشة للـ Container
                            decoration: BoxDecoration(
                              gradient: StyleGradien(),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  child: Text(
                                    '${'number_of_students_near_you'.tr()} : $nearbyPeopleCount',
                                    style: const TextStyle(
                                      fontSize: 23,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                if (_isUploading)
                                  const CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                if (!_isUploading)
                                  SizedBox(
                                    height: 420,
                                    child: GoogleMap(
                                      onMapCreated: (controller) {
                                        setState(() {
                                          mapController = controller;
                                        });
                                      },
                                      myLocationEnabled: true,
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          _position!.latitude,
                                          _position!.longitude,
                                        ),
                                        zoom: 17,
                                      ),
                                      markers: markers,
                                    ),
                                  ),
                                const SizedBox(height: 30),
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('drivers')
                                      .doc(userId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return ErrorOperator(
                                          errorMessage:
                                              '${'error'}: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      int numberChairs = snapshot
                                              .data!['numberchairsavailable'] ??
                                          0;
                                      int numberStudents =
                                          snapshot.data!['numberstudents'] ?? 0;
                                      if (numberChairs <= 0) {
                                        return AlertDialog(
                                          backgroundColor: const Color.fromARGB(
                                              255, 251, 143, 143),
                                          title: Text(
                                            'warning'.tr(),
                                            style: const TextStyle(
                                              fontSize: 25,
                                              color: Color.fromARGB(
                                                  255, 136, 22, 22),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            'number_chairs_run_out'.tr(),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                _updateChairsAvailable(
                                                    snapshot.data![
                                                            'numberchairs'] ??
                                                        0);
                                              },
                                              child: Text(
                                                'evacuation'.tr(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed:
                                                  _incrementNumberStudentsAndDecrementNumberChairs,
                                              label:
                                                  Text('download_student'.tr()),
                                              icon: const Icon(
                                                  Icons.person_add_alt_sharp),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 147, 51, 51),
                                                foregroundColor: Colors.white,
                                                textStyle: const TextStyle(
                                                    color: Colors.white),
                                                padding:
                                                    const EdgeInsets.all(15),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${'number_chairs'.tr()} : $numberChairs',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    '${'number_students'.tr()} : $numberStudents',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                    } else {
                                      return Center(
                                        child: Text('no_data_available'.tr()),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: SplashScreenWait(),
                    );
                  }
                },
              );
            } else {
              return const Center(
                child: SplashScreenWait(),
              );
            }
          },
        );
      },
    );
  }

  double distanceBetweenPoints(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // نصف قطر الأرض بالكيلومترات
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    var a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c * 100;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
