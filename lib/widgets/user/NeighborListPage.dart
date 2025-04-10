import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:womenss/widgets/user/LoginPage.dart';
import 'package:womenss/widgets/user/seprated.dart';
import 'package:womenss/widgets/user/womensinterface.dart';

import 'neww.dart'; // Ensure this file exists and is correctly referenced

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'Neighbor List',
    home: NeighborListPage(),
  ));
}

class NeighborListPage extends StatelessWidget {


  const NeighborListPage({
    Key? key,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WomensInterface()),
        );
        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white60,
          automaticallyImplyLeading: false, // Remove the back arrow
          title: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WomensInterface()),
                  ); // Handle button press
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[200],
                ),
                child: Row(
                  children: [
                    Icon(Icons.emergency_sharp, color: Colors.redAccent),
                    SizedBox(width: 8.0),
                    Text('Neighbour list'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: MyHomePageeeg(

        ),
      ),
    );
  }
}

class MyHomePageeeg extends StatefulWidget {


  MyHomePageeeg({
    Key? key,

  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePageeeg> {
  String authh = " ";
  String? contact=" ";
  String? email=" ";
  String? name=" ";
  String? Address=" ";
  String? ukey=" ";





  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('neighbours');
  void _sendRequest(String itemId, String nkey, String nname, String ncontact, String nemail) async {
    DatabaseReference requestRef = FirebaseDatabase.instance.reference().child('womens_neighbours').child(nkey);

    // Example data for the request
    Map<String, dynamic> requestData = {

      'contact': contact,
      'email': email,
      'name': name,
      'ncontact': ncontact,
      'nemail': nemail,
      'nkey': nkey,
      'ukey': authh,
      'nname': nname,


      'status': 'request',

      'timestamp': ServerValue.timestamp,

    };

    await requestRef.set(requestData);
    print('Request sent');


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent Successfully')),

    );








  }


  @override
  void initState() {
    super.initState();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    String? userId = user?.uid;
    authh = userId ?? " ";
    print(authh);


    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('womens').child(authh);

// Use the onValue stream to listen for changes
    databaseReference.onValue.listen((event) {
      print('Database event received: $event');

      // Check if the event contains the data you need
      if (event.snapshot.value != null) {
        // Cast the value to a Map<String, dynamic>
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        print('User data from database: $userData');

        // Access fields directly
         contact = userData['contact'];
        email = userData['email'];
        name = userData['name'];
        Address = userData['Address'];
        ukey = userData['ukey'];


        // Print the values or do something with them
        print('Address: $contact');
        print('Ambulance Number: $email');


      }
    });

































  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _databaseReference
          .orderByChild('status')
          .equalTo('request')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading requests.'),
          );
        } else if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return Center(
            child: Text('No accepted requests available.'),
          );
        } else {
          Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          List<String> itemIds = data.keys.toList();

          return ListView.builder(
            itemCount: itemIds.length * 2 - 1, // Add dividers
            itemBuilder: (context, index) {
              if (index.isOdd) {
                // Divider
                return Divider();
              } else {
                // Item
                int itemIndex = index ~/ 2;
                String itemId = itemIds[itemIndex];
                String nname = data[itemId]['name']?.toString() ?? '';
                String nemail = data[itemId]['email']?.toString() ?? '';
                String ncontact = data[itemId]['contact']?.toString() ?? '';
                String nkey = data[itemId]['ukey']?.toString() ?? '';

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            nname,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                              color: Colors.blue,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Neighbour name: $nname'),
                              Text('Mobile number: $ncontact'),
                              Text('Email: $nemail'),
                              Text('Status: "Active"'),
                            ],
                          ),
                          trailing: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _sendRequest(
                              itemId,
                              nkey,

                              nname,
                              ncontact,
                              nemail,
                            );
                            // Handle request button press
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue, // Set the background color
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                          ),
                          child: Text(
                            'Request',
                            style: TextStyle(fontSize: 16.0), // Adjusted font size
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
