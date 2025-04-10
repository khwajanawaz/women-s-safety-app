
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


import 'package:geolocator/geolocator.dart';
import 'package:womenss/widgets/user/LoginPage.dart';
import 'package:womenss/widgets/user/sms.dart';
import 'package:womenss/widgets/user/voice.dart';
import 'NeighborListPage.dart';

void main() => runApp(WomensInterface());

class WomensInterface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women\'s Safety App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLogoutLoading = false;

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    return Future.value(false);
  }

  Future<void> logout() async {
    setState(() {
      isLogoutLoading = true;
    });

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    setState(() {
      isLogoutLoading = false;
    });
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
          String contact1 = userDataMap['contact1'] ?? '';
          String contact2 = userDataMap['contact2'] ?? '';
          String contact3 = userDataMap['contact3'] ?? '';
          String contact4 = userDataMap['contact4'] ?? '';

          print('Contact 1: $contact1');
          print('Contact 2: $contact2');
          print('Contact 3: $contact3');
          print('Contact 4: $contact4');

          Position position = await _getCurrentLocation();
          String locationMessage = 'I am at https://www.google.com/maps?q=${position.latitude},${position.longitude}';

          sendSms(contact1, contact2, contact3, contact4, locationMessage);



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


  void sendSms(String c1, String c2, String c3, String c4, String locationMessage) async {
    // List<String> recipients = [c1, c2, c3, c4].where((number) => number.isNotEmpty).toList();
    //
    // if (recipients.isEmpty) {
    //   print('No valid recipients found.');
    //   return;
    // }
    //
    // String message = 'Help me, I am in danger. $locationMessage';
    //
    // try {
    //   await sendSMS(
    //     message: message,
    //     recipients: recipients,
    //   );
    //   print('SMS sent successfully.');
    // } catch (e) {
    //   print('Error sending SMS: $e');
    // }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Women\'s Safety App'),
          centerTitle: true,
          backgroundColor: Colors.pinkAccent,
          actions: [
            IconButton(
              onPressed: () {
                logout();
              },
              icon: isLogoutLoading
                  ? CircularProgressIndicator()
                  : Icon(Icons.exit_to_app, color: Colors.white),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.0),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent),
                ),
                SizedBox(height: 10.0),
                EmergencyContactsList(),
                SizedBox(height: 20.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SpeechToTextApp()),
                    ); // Handle voice command press
                  },
                  icon: Icon(Icons.mic),
                  label: Text('Voice Command'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    minimumSize: Size(double.infinity, 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle SMS alert button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Homeage()),
                    ); // Handle voice
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'SMS Alert!',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    minimumSize: Size(double.infinity, 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NeighborListPage()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'View Neighbor List',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pinkAccent,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    minimumSize: Size(double.infinity, 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Safety Tips',
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent),
                ),
                SizedBox(height: 10.0),
                SafetyTipsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmergencyContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmergencyContactCard(name: 'Police', number: '100'),
        SizedBox(height: 10.0),
        EmergencyContactCard(name: 'Emergency Services', number: '112'),
        SizedBox(height: 10.0),
        EmergencyContactCard(name: 'Family Member', number: '+91 XXXXXXXXXX'),
      ],
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  final String name;
  final String number;

  EmergencyContactCard({required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: ListTile(
        leading: Icon(Icons.contact_phone),
        title: Text(name),
        subtitle: Text(number),
      ),
    );
  }
}

class SafetyTipsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '1. Always be aware of your surroundings.',
          style: TextStyle(fontSize: 18.0),
        ),
        SizedBox(height: 10.0),
        Text(
          '2. Avoid walking alone at night.',
          style: TextStyle(fontSize: 18.0),
        ),
        SizedBox(height: 10.0),
        Text(
          '3. Keep your phone charged and with you at all times.',
          style: TextStyle(fontSize: 18.0),
        ),
        SizedBox(height: 10.0),
        Text(
          '4. Trust your instincts and avoid risky situations.',
          style: TextStyle(fontSize: 18.0),
        ),
      ],
    );
  }
}
