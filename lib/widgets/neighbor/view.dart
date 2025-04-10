import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'neighborinterface.dart'; // Ensure this file exists

class EmList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase ListView Builder',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePageeeg(),
    );
  }
}

class MyHomePageeeg extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Da {
  final String email;
  final String name;
  final String contact;
  final String key;

  Da(this.email, this.name, this.contact, this.key);
}

class _MyHomePageState extends State<MyHomePageeeg> {
  String authh = " ";
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('womens_neighbours');
  List<Da> dataList = [];
  String wkey=" ";
  @override
  void initState() {
    super.initState();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    String? userId = user?.uid;
    authh = userId!;
    print(authh);
  }

  Future<void> _acceptRequest(String itemId,String key) async {
    DatabaseReference ref = _databaseReference.child(itemId);
    await ref.update({'status': 'accept'}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request accepted')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request')),
      );
    });

    DatabaseReference _database = FirebaseDatabase.instance.reference();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;


      await _database.child('womenskey').child(userId!).set({


        'ukey': authh,
        'womenkey': key,
        'status': "accept",
        'status2': "na",

      });
















  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Women\'s Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: _buildListViewWithDivider(),
    );
  }

  Widget _buildListViewWithDivider() {
    return StreamBuilder(
      stream: _databaseReference
          .orderByChild('status')
          .equalTo('request')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading requests.'));
        } else if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return Center(child: Text('No requests available.'));
        } else {
          Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          List<String> itemIds = data.keys.toList();

          return ListView.builder(
            itemCount: itemIds.length * 2 - 1,
            itemBuilder: (context, index) {
              if (index.isOdd) {
                return Divider();
              } else {
                int itemIndex = index ~/ 2;
                String itemId = itemIds[itemIndex];
                String email = data[itemId]['email']?.toString() ?? '';
                String name = data[itemId]['name']?.toString() ?? '';
                String contact = data[itemId]['contact']?.toString() ?? '';
                 wkey = data[itemId]['ukey']?.toString() ?? '';

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 2.0, end: 0.8),
                  duration: Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.green[700]),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Email: $email',
                                      style: TextStyle(fontSize: 18, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.green[700]),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Name: $name',
                                      style: TextStyle(fontSize: 18, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.green[700]),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Contact: $contact',
                                      style: TextStyle(fontSize: 18, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.key, color: Colors.green[700]),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Key: $wkey',
                                      style: TextStyle(fontSize: 18, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _acceptRequest(itemId,wkey);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                ),
                                child: Text(
                                  'Accept',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}
