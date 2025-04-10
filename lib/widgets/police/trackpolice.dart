import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackpolicePage extends StatefulWidget {
  final String ukey;

  TrackpolicePage({required this.ukey});

  @override
  _TrackUserPageState createState() => _TrackUserPageState();
}

class _TrackUserPageState extends State<TrackpolicePage> {
  String selectedRadio = ''; // Variable to hold the selected radio value
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  Completer<GoogleMapController> _controllerCompleter = Completer<GoogleMapController>();

  DatabaseReference reference = FirebaseDatabase.instance.reference();
  StreamController<Map<String, dynamic>> _locationStreamController =
  StreamController<Map<String, dynamic>>();
  Uint8List? compressedBytes; // Declare compressedBytes here


  @override
  void initState() {
    super.initState();
    startLocationUpdates();
    loadCompressedBytes(); // Load compressed bytes when the widget initializes
  }

  @override
  void dispose() {
    _locationStreamController.close();
    super.dispose();
  }

  Future<void> loadCompressedBytes() async {
    // Load the image byte data
    ByteData data = await rootBundle.load('assets/images/warning.png');

    // Convert List<int> to Uint8List
    Uint8List originalBytes = Uint8List.fromList(data.buffer.asUint8List());

    // Compress the image to reduce size
    compressedBytes = await FlutterImageCompress.compressWithList(
      originalBytes,
      minHeight: 68, // Set your desired height
      minWidth: 68, // Set your desired width
      quality: 80, // Set your desired quality (0 to 100)
    );
  }

  void startLocationUpdates() {
    DatabaseReference reference =
    FirebaseDatabase.instance.reference().child('connectedauth').child(widget.ukey);

    reference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        var userData = event.snapshot.value;

        if (userData is Map<Object?, Object?>) {
          // Cast the map to Map<String, dynamic>
          Map<String, dynamic> userDataMap = userData.cast<String, dynamic>();

          // Parse latitude and longitude
          double? latitude = _parseToDouble(userDataMap['latitude']);
          double? longitude = _parseToDouble(userDataMap['longitude']);

          if (latitude != null && longitude != null) {
            // Add the data to the stream
            _locationStreamController.add(userDataMap);

            // Show location on the map continuously
            showLocationOnMap(latitude, longitude);
          } else {
            print("Invalid latitude or longitude value.");
          }
        } else {
          print("Invalid data structure in the database");
        }
      } else {
        print("No location data found in the database");
      }
    }, onError: (Object error) {
      print("Error fetching location data: $error");
    });
  }

  double? _parseToDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _locationStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Ensure data is available and correctly typed
            Map<String, dynamic> data = snapshot.data!;

            // Convert latitude and longitude to doubles if they are strings
            double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
            double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;

            return Container(
              height: double.infinity,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(latitude, longitude),
                  zoom: 14.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controllerCompleter.complete(controller);
                },
                markers: {
                  Marker(
                    markerId: MarkerId('locationMarker'),
                    position: LatLng(latitude, longitude),
                    icon: BitmapDescriptor.fromBytes(compressedBytes!),
                    infoWindow: InfoWindow(title: 'Women Location'),
                  ),
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Show loading or default map
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void showLocationOnMap(double latitude, double longitude) async {
    final GoogleMapController controller = await _controllerCompleter.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(latitude, longitude),
        14.0,
      ),
    );
  }
}
