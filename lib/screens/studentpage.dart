// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:bus_uni/screens/detailsuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  late Future<QuerySnapshot<Map<String, dynamic>>> usernameFuture2;

  GoogleMapController? mapController;
  String currentLocation = '';
  Set<Marker> markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late BitmapDescriptor carIcon;
  late BitmapDescriptor boyIcon;

  String? selectedRegistrationPlace;
  late Timer _timer; // إنشاء متغير لتخزين العداد
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  Position? _position;
  var _isUploading = false;

  Future<void> _loadCarIcon() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        size: Size(40, 40),
      ),
      'assets/images/bus_icon.png',
    );
  }

  Future<void> _loadBoyIcon() async {
    boyIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        size: Size(40, 40),
      ),
      'assets/images/Icon.png', // Path to the boy icon image asset
    );
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

  void _subscribeToLocationUpdates() {
    _subscription =
        _firestore.collectionGroup('locationDriver').snapshots().listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        setState(
          () {
            markers.clear();
            for (final doc in snapshot.docs) {
              final lat = doc['latitude'] as double;
              final long = doc['longitude'] as double;
              final busNumber = doc['number'] as String;
              markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(lat, long),
                  infoWindow: InfoWindow(title: busNumber),
                  icon: carIcon,
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer.cancel(); // إلغاء تنفيذ العملية عندما يتم تجديد الشاشة أو إغلاقها
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
    _loadBoyIcon(); // Make sure this method is called to load the boy icon
    _getCurrentLocation();
    // إعداد تنفيذ العملية كل 10 ثواني
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (Timer timer) {
        _subscribeToLocationUpdates();
        // تحديث الموقع كل 10 ثواني
      },
    );

    usernameFuture = getUsers();
    usernameFuture2 = getUsers2();
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
    userId = user.uid; // Update userId
    return await usersRef
        .where(
          'email',
          isEqualTo: '${users.email}',
        )
        .get();
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
// عرض مواقع السائقين
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collectionGroup('drivers').snapshots(),
      builder: (context, snapshot) {
        markers.clear();
        if (snapshot.hasData && snapshot.data != null) {
          for (var doc in snapshot.data!.docs) {
            final long = doc.get('longitude');
            final lat = doc.get('latitude');
            final busNumber = doc.get('number');
            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(lat, long),
                infoWindow: InfoWindow(title: '$busNumber'),
                icon: carIcon,
              ),
            );
          }
        }
        //عرض بيانات المستخدم
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: usernameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreenWait();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              String username = snapshot.data!['username'];
              String imageuser = snapshot.data!['image'];
              String gender = snapshot.data!['gender'];
              String phone = snapshot.data!['phonenumber'];
              String living = snapshot.data!['living'];
              String age = snapshot.data!['age'];
              String college = snapshot.data!['college'];
              String specialization = snapshot.data!['specialization'];
              String academicYear = snapshot.data!['academic_year'];

              return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: usernameFuture2,
                builder: (context, snapshot) {
                  return Scaffold(
                    drawer: MyDrawer(
                      snapshot: snapshot,
                      drawemail: '${FirebaseAuth.instance.currentUser?.email}',
                      drawusername: username,
                      imageusers: imageuser,
                      detailsUser: () {
                        Navigator.pop(context);
                        Navigator.of(context).pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsUser(
                              userName: username,
                              userEmail:
                                  '${FirebaseAuth.instance.currentUser?.email}',
                              imageUsers: imageuser,
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              gender: gender,
                              phone: phone,
                              living: living,
                              age: age,
                              college: college,
                              specialization: specialization,
                              academicYear: academicYear,
                            ),
                          ),
                        );
                      },
                    ),
                    appBar: StyleAppBar(username),
                    body: Container(
                      decoration: BoxDecoration(
                        gradient: StyleGradien(),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isUploading)
                              const CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            if (!_isUploading)
                              SizedBox(
                                height: 500,
                                child: GoogleMap(
                                  onMapCreated: (controller) {
                                    setState(
                                      () {
                                        mapController = controller;
                                      },
                                    );
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
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    if (mapController != null) {
                                      mapController!.dispose();
                                    }

                                    var status =
                                        await Permission.location.request();

                                    if (status == PermissionStatus.granted) {
                                      Position position =
                                          await Geolocator.getCurrentPosition();
                                      setState(
                                        () {
                                          _updateUserLocation(
                                            position.latitude,
                                            position.longitude,
                                            username,
                                          );

                                          mapController!.animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                              LatLng(
                                                position.latitude,
                                                position.longitude,
                                              ),
                                              17.0,
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      ErrorOperator(
                                        errorMessage:
                                            'location_permission_denied'.tr(),
                                      );
                                    }
                                  },
                                  label: Text('share_location'.tr()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey,
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(15),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.share),
                                ),
                                const SizedBox(width: 30),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    markers.clear();
                                    QuerySnapshot querySnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .collection('location')
                                            .get();

                                    for (QueryDocumentSnapshot doc
                                        in querySnapshot.docs) {
                                      await doc.reference.delete();
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('sucessfully'.tr()),
                                            content: Text(
                                                'delete_location_sucessfully'
                                                    .tr()),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('done_button'.tr()),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  label: Text('delete_location'.tr()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 147, 51, 51),
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(15),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
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
      },
    );
  }

// أسفل الصفحة
  void _updateUserLocation(
      double latitude, double longitude, String username) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      // إضافة الموقع لقاعدة البيانات
      await _addUserLocationToFirestore(userId, latitude, longitude);
      // تحديث الموقع للمستخدم في قاعدة البيانات
      await _updateUserLocationInDatabase(
        userId,
        latitude,
        longitude,
        username,
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('share_location_sucessfully'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
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

  Future<void> _addUserLocationToFirestore(
      String userId, double latitude, double longitude) async {
    DocumentReference locationReference = _firestore
        .collection('users')
        .doc(userId)
        .collection('location')
        .doc(userId);

    await locationReference.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateUserLocationInDatabase(
      String userId, double latitude, double longitude, String username) async {
    DocumentReference locationReference2 =
        _firestore.collection('students').doc(userId);
    await locationReference2.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'username': username
    }, SetOptions(merge: true));
  }
}
