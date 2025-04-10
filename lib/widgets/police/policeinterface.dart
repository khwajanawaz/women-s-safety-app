import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:womenss/widgets/police/trackpolice.dart';
import 'Login.dart'; // Assuming this is your login screen

void main() {
  runApp(PoliceInterface());
}

class PoliceInterface extends StatefulWidget {
  @override
  State<PoliceInterface> createState() => _PoliceInterfaceState();
}

var isLogoutLoading = false;

class _PoliceInterfaceState extends State<PoliceInterface> {
  late DatabaseReference _databaseReference;
  late StreamSubscription _subscription;

  Timer? _alertTimer; // Timer instance for alert listening
  Timer? _userKeyTimer; // Timer instance for user key fetching
  String womenkey = " ";
  String gukey = " ";
  String station = '';
  bool _isDialogShown = false;
  @override
  void initState() {
    super.initState();
    _startPeriodicCalls();
    _databaseReference = FirebaseDatabase.instance.ref().child('alertstatus').child(womenkey);
    _alertTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (!_isDialogShown) {
        _startListeningToAlerts();
      }
    });
  }

  void _startListeningToAlerts() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    String? userId = user?.uid;

    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('alertpolice').child(userId!);

    databaseReference.onValue.listen((event) {
      print('Database event received: $event');

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        String status = userData['status'] ?? '';
        String wkey = userData['wkey'] ?? '';
        String sno = userData['sno'] ?? '';
        print('Womenkey: $wkey');
        print('Status: $status');

        if (status == 'alert' && sno == station) {
          if (mounted && !_isDialogShown) {
            _isDialogShown = true; // Set the flag to true
            _alertTimer?.cancel(); // Cancel the timer to stop periodic calls
            call(context,wkey); // Show the alert dialog
          }
          print('Alert detected: $userData');
        }
      } else {
        print('No data found in the database.');
      }
    });
  }
  void _showAlertDialog(String wkey) {
    // Stop the timer to prevent it from running while the dialog is shown
    _alertTimer?.cancel();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Track User'),
          content: Text('Do you want to track this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShown = false; // Reset the flag
                // Restart the timer after the dialog is dismissed
                _alertTimer = Timer.periodic(Duration(seconds: 35), (timer) {
                  if (!_isDialogShown) {
                    _startListeningToAlerts();
                  }
                });
              },
            ),
            TextButton(
              child: Text('Track'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackpolicePage(ukey: wkey),
                  ),
                );
                _isDialogShown = false; // Reset the flag
                // Restart the timer after navigating to the new screen
                _alertTimer = Timer.periodic(Duration(seconds: 35), (timer) {
                  if (!_isDialogShown) {
                    _startListeningToAlerts();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Future<void> checkPassUKey(String wkey, BuildContext context) async {
  //   FirebaseAuth _auth = FirebaseAuth.instance;
  //   User? user = _auth.currentUser;
  //
  //   if (user == null) {
  //     print("No user logged in.");
  //     return;
  //   }
  //
  //   DatabaseReference _database = FirebaseDatabase.instance.reference();
  //   String userId = user.uid;
  //
  //   DatabaseReference databaseReference = _database.child('connectedauth').child(womenkey);
  //
  //   DatabaseEvent event = await databaseReference.once();
  //   var userData = event.snapshot.value;
  //
  //   if (userData != null) {
  //     Map<String, dynamic> userDataMap = Map<String, dynamic>.from(userData as Map);
  //     String ukey = userDataMap['ukey'] ?? 'No name';
  //
  //     if (mounted && !_isDialogShown) {
  //       _showAlertDialog(ukey); // Ensure context is still valid and flag is not set
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Login Successfully')),
  //       );
  //     }
  //   } else {
  //     print('No user data found.');
  //   }
  // }

  Future<void> _startPeriodicCalls() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    if (user == null) {
      print("No user logged in.");
      return;
    }
    String userId = user.uid;
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('police').child(userId);

    // Use the onValue stream to listen for changes
    databaseReference.onValue.listen((event) {
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
          station = userDataMap['stationno'];

          print('Status: $station');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successfully')),
          );
        } else {
          print("Invalid data structure in the database");
        }
      } else {
        print("No data found in the database");
      }
    });
  }

  void call(BuildContext context, String ukey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Track User'),
          content: Text('Do you want to track this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Track'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackpolicePage(ukey: ukey),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => policelogin()),
    );
    return Future.value(false);
  }

  Future<void> _logout(BuildContext context) async {
    setState(() {
      isLogoutLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    setState(() {
      isLogoutLoading = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => policelogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Police Interface'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          actions: [
            if (isLogoutLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => _logout(context),
              ),
          ],
        ),
        /*drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Police Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('Dashboard'),
                onTap: () {
                  // Navigate to dashboard or relevant page
                },
              ),
              ListTile(
                title: Text('Reports'),
                onTap: () {
                  // Navigate to reports page
                },
              ),
              ListTile(
                title: Text('Manage Officers'),
                onTap: () {
                  // Navigate to manage officers page
                },
              ),
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  // Navigate to settings page
                },
              ),
            ],
          ),
        ),*/
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/img_3.png'), // Replace with your image path
                  fit: BoxFit.cover,
                  alignment: Alignment.center, // Align the image to center
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.4), // Dark overlay
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome to the Police Interface',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Implement functionality for the main action button
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Main Action',
                      style: TextStyle(fontSize: 18),
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
