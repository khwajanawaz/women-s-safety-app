import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class Homeage extends StatefulWidget {
  const Homeage({super.key});

  @override
  State<Homeage> createState() => _HomeageState();
}

class _HomeageState extends State<Homeage> {

  String contact1=" ";

  String contact2=" ";

  String contact3=" ";

  String contact4=" ";
  String locationMessage=" ";

  @override
  void initState() {
    super.initState();
    // Call your initialization functions here
    getnumber(); // Example: fetch user numbers from the database when the widget initializes
  }

  Future<void> getnumber() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    if (user == null) {
      print("No user logged in.");
      return;
    }

    String userId = user.uid;
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('womens').child(userId);

    // Use the onValue stream to listen for changes
    databaseReference.onValue.listen((event) async {
      print('Database event received: $event');

      // Check if the event contains the data you need
      if (event.snapshot.value != null) {
        var userData = event.snapshot.value;
        print('User data from database: $userData');

        // Check if userData is a Map
        if (userData is Map<Object?, Object?>) {
          // Cast the map to Map<String, dynamic>
          Map<String, dynamic> userDataMap = userData.cast<String, dynamic>();

          // Access data directly and handle null cases
          contact1 = userDataMap['contact1'] ?? '';
          contact2 = userDataMap['contact2'] ?? '';
          contact3 = userDataMap['contact3'] ?? '';
          contact4 = userDataMap['contact4'] ?? '';

          print('Contact 1: $contact1');
          print('Contact 2: $contact2');
          print('Contact 3: $contact3');
          print('Contact 4: $contact4');

          Position position = await _getCurrentLocation();
           locationMessage = 'I am at https://www.google.com/maps?q=${position.latitude},${position.longitude}';



        } else {
          print("Invalid data structure in the database");
        }
      } else {
        print("No data found in the database");
      }
    });
  }

  Future<Position> _getCurrentLocation() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Url Launcher"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            launchButton(
              title: 'Launch SMS / Message',
              icon: Icons.message,
              onPressed: () =>  senddSms(contact1, contact2, contact3, contact4, locationMessage)
            ),

          ],
        ),
      ),
    );
  }

  void senddSms(String c1, String c2, String c3, String c4, String locationMessage)  {
    // Replace with actual phone numbers
    List<String> recipients = [c1,c2,c3,c4];
    String message = locationMessage;

    String smsUri = 'sms:${recipients.join(',')}?body=${Uri.encodeComponent(message)}';

    launcher.launchUrl(Uri.parse(smsUri));
  }

  Widget launchButton({
    required String title,
    required IconData icon,
    required Function() onPressed,
  }) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Homeage(),
  ));
}
