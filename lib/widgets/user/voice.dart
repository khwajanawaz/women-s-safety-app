import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(SpeechToTextApp());

class SpeechToTextApp extends StatefulWidget {
  @override
  _SpeechToTextAppState createState() => _SpeechToTextAppState();
}

class _SpeechToTextAppState extends State<SpeechToTextApp> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";
  bool _isInitialized = false; // Track initialization status
  Timer? _locationTimer; // Timer for periodic location updates
  String? pkey;
  String? nearestStationNo = " ";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize();
      setState(() {
        _isInitialized = available;
      });
      if (!available) {
        print('Speech recognition is not available on this device');
      }
    } catch (e) {
      print('Error initializing speech recognition: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      print('SpeechToText is not initialized.');
      return;
    }

    var status = await Permission.microphone.request();
    if (status.isGranted) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      );

      // Stop listening after 3 seconds
      Timer(Duration(seconds: 3), _stopListening);
    } else {
      print("Microphone permission denied");
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
      _processVoiceData(_text);
    }
  }

  Future<void> _processVoiceData(String voiceData) async {
    print('Recognized Voice Data: $voiceData'); // Print the recognized data

    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    if (user == null) {
      print("No user logged in.");
      return;
    }
    String userId = user.uid;

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('womens').child(userId);

    databaseReference.onValue.listen(
          (event) {
        print('Database event received: ${event.snapshot.value}');

        if (event.snapshot.exists) {
          var userData = event.snapshot.value;
          print('User data from database: $userData');

          if (userData is Map<dynamic, dynamic>) {
            Map<String, dynamic> userDataMap = userData.cast<String, dynamic>();

            String? voice = userDataMap['voice'];
            String? contact = userDataMap['contact'];
            String? name = userDataMap['name'];
            String? ukey = userDataMap['ukey'];

            if (voice == voiceData) {
              print('Voice matches database entry: $voiceData');
              sendlive(voiceData, context);
            } else {
              print('No matching entry found in the database.');
            }
          } else {
            print('Database entry is not a map.');
          }
        } else {
          print('No data found at the database reference.');
        }
      },
      onError: (error) {
        print('Error while listening to database changes: $error');
      },
    );
  }

  Future<void> sendlive(String voiceData, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    if (user == null) {
      print("No user logged in.");
      return;
    }
    String userId = user.uid;

    var status = await Permission.location.request();
    if (!status.isGranted) {
      print('Location permission denied');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double currentLatitude = position.latitude;
      double currentLongitude = position.longitude;

      print('Current Latitude: $currentLatitude, Current Longitude: $currentLongitude');

      DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('police');

      DatabaseEvent event = await databaseReference.once();
      DataSnapshot snapshot = event.snapshot;
      print('Database snapshot received: ${snapshot.value}');

      if (snapshot.exists) {
        var policeData = snapshot.value;
        print('Police data from database: $policeData');

        if (policeData is Map<dynamic, dynamic>) {
          double? closestDistance;
          String? nearestLocality;

          for (var entry in policeData.entries) {
            var value = entry.value;
            if (value is Map<dynamic, dynamic>) {
              Map<String, dynamic> policeDataMap = value.cast<String, dynamic>();

              String? latitudeStr = policeDataMap['lattitude']; // Adjust field name if needed
              String? longitudeStr = policeDataMap['logitude']; // Adjust field name if needed
              String? stationno = policeDataMap['stationno'];
              String? locality = policeDataMap['locality'];
              String? ukey = policeDataMap['ukey'];
              if (latitudeStr != null && longitudeStr != null) {
                double policeLatitude = double.parse(latitudeStr);
                double policeLongitude = double.parse(longitudeStr);

                double distanceInMeters = Geolocator.distanceBetween(
                  currentLatitude,
                  currentLongitude,
                  policeLatitude,
                  policeLongitude,
                );

                if (closestDistance == null || distanceInMeters < closestDistance) {
                  closestDistance = distanceInMeters;
                  nearestStationNo = stationno;
                  nearestLocality = locality;
                  pkey = ukey;
                }
              }
            }
          }

          if (nearestStationNo != null && closestDistance != null) {
            print('Nearest Police Station:');
            print('Station No: $nearestStationNo');
            print('Locality: $nearestLocality');
            print('Distance: ${closestDistance.toStringAsFixed(2)} meters');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Nearest police station: $nearestStationNo')),
            );

            // Start periodic location updates
            _startLocationUpdates(nearestStationNo!);
          } else {
            print('No nearby police stations found.');
          }
        } else {
          print('Data from database is not in the expected format.');
        }
      } else {
        print('No data found at the database reference.');
      }
    } catch (error) {
      print('Error while fetching database data: $error');
    }
  }

  void _startLocationUpdates(String station) {
    // Cancel any existing timer
    _locationTimer?.cancel();

    // Start a new timer
    _locationTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) async {
      await _updateLocation(station);
    });
  }

  Future<void> _updateLocation(String station) async {
    await updatestatus();
    await updatepolice();
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    if (user == null) {
      print("No user logged in.");
      return;
    }
    String userId = user.uid;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;

    print('Updating location: Latitude: $latitude, Longitude: $longitude');

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('connectedauth').child(userId);

    await databaseReference.set({
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'ukey': userId,
      'stationno': station,
      'status': 'help',
    }).then((_) {
      print('Location updated successfully.');
    }).catchError((error) {
      print('Error updating location: $error');
    });
  }

  Future<void> updatestatus() async {
    DatabaseReference _database = FirebaseDatabase.instance.ref();
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    if (user == null) {
      print("No user logged in.");
      return;
    }
    String userId = user.uid;
    DatabaseReference userRef = _database.child('alertstatus').child(userId);
    await userRef.set({
      'status': 'alert',
      'wkey': user.uid,
      'timestamp': DateTime.now().toIso8601String(),
    }).then((_) {
      print('Status updated successfully.');
    }).catchError((error) {
      print('Error updating status: $error');
    });
  }

  Future<void> updatepolice() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    if (user == null) {
      print("No user logged in.");
      return;
    }
    String userId = user.uid;
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('alertpolice').child(pkey!);

    await userRef.update({
      'status': 'alert',
      'timestamp': DateTime.now().toIso8601String(),
      'wkey': user.uid,
      'sno': nearestStationNo,
    }).then((_) {
      print('Police status updated successfully.');
    }).catchError((error) {
      print('Error updating police status: $error');
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _locationTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Speech to Text'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _startListening,
                child: Text('Start Listening'),
              ),
              Text(
                _text,
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
