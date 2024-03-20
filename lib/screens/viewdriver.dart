import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bus_uni/screens/updatedriverdetails.dart';
import 'package:bus_uni/widget/gradient.dart';

class ViewDriver extends StatefulWidget {
  final String driverName;
  final int busNumber;
  final String driverJobNumber;
  final String driverEmail;
  final String driverImageusers;
  final double latitude;
  final double longitude;
  final int numberChairs;
  final int numberStudents;
  final String driverId;

  const ViewDriver({
    required this.driverName,
    required this.busNumber,
    required this.driverJobNumber,
    required this.driverEmail,
    required this.driverImageusers,
    required this.latitude,
    required this.longitude,
    required this.numberChairs,
    required this.numberStudents,
    required this.driverId,
    Key? key,
  }) : super(key: key);

  @override
  State<ViewDriver> createState() => _ViewDriverState();
}

class _ViewDriverState extends State<ViewDriver> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  late BitmapDescriptor carIcon;

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
  }

  Future<void> _loadCarIcon() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/images/bus_icon.png');

    // إنشاء وإضافة العلامة المرئية إلى مجموعة العلامات markers
    final Marker marker = Marker(
      markerId: const MarkerId('carMarker'),
      position: LatLng(widget.latitude, widget.longitude),
      icon: carIcon,
    );
    setState(
      () {
        markers.add(marker);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${'bus_number'.tr()}: ${widget.busNumber}'),
        backgroundColor: const Color.fromARGB(255, 3, 100, 191),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateDriver(
                    driverName: widget.driverName,
                    busNumber: widget.busNumber,
                    driverJobNumber: widget.driverJobNumber,
                    driverEmail: widget.driverEmail,
                    driverImageusers: widget.driverImageusers,
                    numberChairs: widget.numberChairs,
                    driverId: widget.driverId,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradien(),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.driverImageusers),
                radius: 75,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withAlpha(180),
              ),
              Text('${'username_label'.tr()}: ${widget.driverName}'),
              Text('${'job_number'.tr()}: ${widget.driverJobNumber}'),
              Text('${'email_label'.tr()}: ${widget.driverEmail}'),
              SizedBox(
                height: 400,
                width: 375,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    setState(
                      () {
                        mapController = controller;
                      },
                    );
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      widget.latitude,
                      widget.longitude,
                    ),
                    zoom: 17,
                  ),
                  markers: markers,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      '${'number_chairs'.tr()} : ${widget.numberChairs}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${'number_students'.tr()} : ${widget.numberStudents}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
