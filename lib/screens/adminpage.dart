import 'package:bus_uni/screens/detailsadmin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bus_uni/screens/adddriver.dart';
import 'package:bus_uni/screens/viewdriver.dart';
import 'package:bus_uni/screens/splash_wait.dart';
import 'package:bus_uni/widget/drawer.dart';
import 'package:bus_uni/widget/error_operation.dart';
import 'package:bus_uni/widget/gradient.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Stream<List<DocumentSnapshot>> driversStream;
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  var _isUploading = false;

  @override
  void initState() {
    super.initState();
    _uploadData();
    usernameFuture = getUsers();
  }

  _uploadData() {
    setState(
      () {
        _isUploading = true;
      },
    );
    driversStream = FirebaseFirestore.instance
        .collection('drivers')
        .snapshots()
        .map((snapshot) => snapshot.docs);

    setState(
      () {
        _isUploading = false;
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: usernameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreenWait();
        } else if (snapshot.hasError) {
          return ErrorOperator(errorMessage: '${'error'}: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return ErrorOperator(errorMessage: 'no_loading_data'.tr());
        } else {
          String username = snapshot.data!['username'];
          String imageuser = snapshot.data!['image'];
          String gender = snapshot.data!['gender'];
          String phone = snapshot.data!['phonenumber'];
          String living = snapshot.data!['living'];
          String age = snapshot.data!['age'];
          String adminPassword = snapshot.data!['password'];

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
                    builder: (context) => DetailsAdmin(
                      userName: username,
                      userEmail: '${FirebaseAuth.instance.currentUser?.email}',
                      imageUsers: imageuser,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      gender: gender,
                      phone: phone,
                      living: living,
                      age: age,
                    ),
                  ),
                );
              },
            ),
            appBar: AppBar(
              centerTitle: true,
              title: Text('bus_routes_title'.tr()),
              backgroundColor: const Color.fromARGB(255, 3, 100, 191),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddDriver(
                          password: adminPassword,
                          userEmail:
                              '${FirebaseAuth.instance.currentUser?.email}',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.person_add_alt_1,
                  ),
                ),
              ],
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: StyleGradien(),
              ),
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: driversStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreenWait();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (_isUploading) {
                    return const CircularProgressIndicator(
                      color: Colors.blue,
                    );
                  } else if (snapshot.hasData || !_isUploading) {
                    List<DocumentSnapshot> drivers = snapshot.data!;
                    drivers.sort(
                      (a, b) => a['number'].compareTo(
                        b['number'],
                      ),
                    ); // ترتيب السائقين حسب رقم الباص
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1, // عدد الأعمدة
                          mainAxisSpacing: 5, // المسافة العمودية بين الصفوف
                          childAspectRatio: 5,
                        ),
                        itemCount: (drivers.length / 5).ceil(), // عدد الصفوف
                        itemBuilder: (context, index) {
                          return Row(
                            children: drivers
                                .sublist(
                              index * 5,
                              (index * 5) + 5 > drivers.length
                                  ? drivers.length
                                  : (index * 5) + 5,
                            )
                                .map(
                              (driver) {
                                String driverId = driver['userId'];
                                String driverName = driver['username'];
                                int busNumber = driver['number'].toInt();
                                String driverJobNumber = driver['JobNumber'];
                                String driverEmail = driver['email'];
                                double latitude = driver['latitude'];
                                double longitude = driver['longitude'];
                                String driverImageusers = driver['image'];
                                int numberChairs =
                                    driver['numberchairsavailable'].toInt();
                                int numberStudents =
                                    driver['numberstudents'].toInt();

                                return Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewDriver(
                                                driverName: driverName,
                                                busNumber: busNumber,
                                                driverJobNumber:
                                                    driverJobNumber,
                                                driverEmail: driverEmail,
                                                driverImageusers:
                                                    driverImageusers,
                                                latitude: latitude,
                                                longitude: longitude,
                                                numberChairs: numberChairs,
                                                numberStudents: numberStudents,
                                                driverId: driverId,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromARGB(
                                              255, 63, 116, 165),
                                          padding: const EdgeInsets.all(8),
                                          fixedSize: const Size(60, 60),
                                          shape: const CircleBorder(),
                                        ),
                                        child: Text(
                                          '$busNumber',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          );
                        },
                      ),
                    );
                  } else {
                    return ErrorOperator(
                        errorMessage: 'no_data_available'.tr());
                  }
                },
              ),
            ),
          );
        }
      },
    );
  }
}
