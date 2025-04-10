import 'dart:async'; // Import for Timer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:womenss/widgets/neighbor/track.dart';
import 'package:womenss/widgets/neighbor/view.dart';
import '../user/seprated.dart';
import 'Loginn.dart'; // Assuming this is your login screen

void main() {
  runApp(NeighborInterface());
}

class NeighborInterface extends StatefulWidget {
  @override
  State<NeighborInterface> createState() => _NeighborInterfaceState();
}

var isLogoutLoading = false;

class _NeighborInterfaceState extends State<NeighborInterface> {
  late DatabaseReference _databaseReference;
  late StreamSubscription _subscription;
  Timer? _alertTimer; // Timer instance for alert listening
  Timer? _userKeyTimer; // Timer instance for user key fetching
  String womenkey = " ";
  String gukey = " ";
  bool _isDialogShown = false; // Flag to check if dialog is shown

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

    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('alertstatus').child(womenkey);

    databaseReference.onValue.listen((event) {
      print('Database event received: $event');

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        String status = userData['status'] ?? '';
        String wkey = userData['wkey'] ?? '';

        print('Womenkey: $wkey');
        print('Status: $status');

        if (status == 'alert' && wkey == womenkey) {
          if (mounted && !_isDialogShown) {
            _isDialogShown = true; // Set the flag to true
            _alertTimer?.cancel(); // Cancel the timer to stop periodic calls
            _showAlertDialog(wkey); // Show the alert dialog
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
                    builder: (context) => TrackUserPage(ukey: wkey),
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

  Future<void> checkPassUKey(String wkey, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    if (user == null) {
      print("No user logged in.");
      return;
    }

    DatabaseReference _database = FirebaseDatabase.instance.reference();
    String userId = user.uid;

    DatabaseReference databaseReference = _database.child('connectedauth').child(womenkey);

    DatabaseEvent event = await databaseReference.once();
    var userData = event.snapshot.value;

    if (userData != null) {
      Map<String, dynamic> userDataMap = Map<String, dynamic>.from(userData as Map);
      String ukey = userDataMap['ukey'] ?? 'No name';

      if (mounted && !_isDialogShown) {
        _showAlertDialog(ukey); // Ensure context is still valid and flag is not set
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successfully')),
        );
      }
    } else {
      print('No user data found.');
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NeighborLogin()),
    );
    return Future.value(false);
  }

  logout() async {
    setState(() {
      isLogoutLoading = true;
    });

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NeighborLogin()),
    );

    setState(() {
      isLogoutLoading = false;
    });
  }

  void _startPeriodicCalls() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    String? userId = user?.uid;

    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('womenskey').child(userId!);

    databaseReference.onValue.listen((event) {
      print('Database event received: $event');

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        String womenkey = userData['womenkey'] ?? '';
        String gukey = userData['ukey'] ?? '';
        String status = userData['status'] ?? '';
        String status2 = userData['status2'] ?? '';

        print('User data from database:');
        print('Womenkey: $womenkey');
        print('Gukey: $gukey');
        print('Status: $status');
        print('Status2: $status2');

        setState(() {
          this.womenkey = womenkey;
          this.gukey = gukey;
        });
      } else {
        print('No data found in the database.');
      }
    });
  }

  @override
  void dispose() {
    _alertTimer?.cancel(); // Cancel the alert timer to avoid memory leaks
    _userKeyTimer?.cancel(); // Cancel the user key timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neighbor Interface',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Neighbor Interface'),
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
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/img_4.png'), // Replace with your image path
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
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
                      'Welcome to the Neighbor Interface',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePageeeg()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
