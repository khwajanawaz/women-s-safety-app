import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'NeighborListPage.dart'; // Import your NeighborListPage here

class Seperated extends StatefulWidget {
  final String? nemail;
  final String? ncontact;
  final String? nname;
  final String? nkey;

  Seperated({
    Key? key,
    this.nemail,
    this.ncontact,
    this.nname,
    this.nkey,
  }) : super(key: key);

  @override
  _SeperatedState createState() => _SeperatedState();
}

class _SeperatedState extends State<Seperated> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _fetchData() async {
    User? user = _auth.currentUser;
    String? userId = user?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    int currentTimestamp = currentDate.millisecondsSinceEpoch;

    try {
      // Fetch data from 'womens'
      DatabaseEvent womensEvent = await _database.child('womens').child(userId).once();
      DataSnapshot womensSnapshot = womensEvent.snapshot;

      if (womensSnapshot.exists) {
        Map<String, dynamic> womensData = Map<String, dynamic>.from(womensSnapshot.value as Map);

        String? name = womensData['name'];
        String? email = womensData['email'];
        String? contact = womensData['contact'];
        String? ukey = womensData['ukey'];

        // Fetch data from 'neighbours' using widget.nkey
        if (widget.nkey != null) {
          DatabaseEvent neighboursEvent = await _database.child('neighbours').child(widget.nkey!).once();
          DataSnapshot neighboursSnapshot = neighboursEvent.snapshot;

          if (neighboursSnapshot.exists) {
            Map<String, dynamic> neighbourData = Map<String, dynamic>.from(neighboursSnapshot.value as Map);

            // Print the neighbour data to verify
            print('Selected Neighbour:');
            print('Name: ${neighbourData['name']}');
            print('Email: ${neighbourData['email']}');
            print('Contact: ${neighbourData['contact']}');
            print('Key: ${neighbourData['ukey']}');

            // Merge the data from both tables
            Map<String, dynamic> mergedData = {
              'name': name ?? widget.nname,
              'email': email ?? widget.nemail,
              'contact': contact ?? widget.ncontact,
              'nname': neighbourData['name'],
              'nemail': neighbourData['email'],
              'ncontact': neighbourData['contact'],
              'ukey': ukey,
              'nkey': widget.nkey,
              'starttime': currentTimestamp,
              'date': formattedDate,
              'status':'request',
            };

            // Debug print before writing to the database
            print('Merged Data: $mergedData');

            // Store the merged data in 'womens_neighbours'
            try {
              await _database.child('womens_neighbours').child(userId).set(mergedData);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text('Data Merged and Stored Successfully', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );

              // Wait for 5 seconds before redirecting
              await Future.delayed(Duration(seconds: 5));

              // Navigate to NeighborListPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NeighborListPage()),
              );
            } catch (e) {
              print('Error storing data: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to store data: $e', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } else {
            print('No data available for the specified neighbour.');
          }
        } else {
          print('Neighbour key (nkey) is null.');
        }
      } else {
        print('No data available for the specified user in womens.');
      }
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch data: $e', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Print the values of nemail, ncontact, nname, and nkey
    print('Widget values:');
    print('nemail: ${widget.nemail}');
    print('ncontact: ${widget.ncontact}');
    print('nname: ${widget.nname}');
    print('nkey: ${widget.nkey}');

    return WillPopScope(
      onWillPop: () async {
        // Prevent closing the current screen immediately and navigate to NeighborListPage
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NeighborListPage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Seperated'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('email: ${widget.nemail ?? 'Not available'}'),
              Text('contact: ${widget.ncontact ?? 'Not available'}'),
              Text('name: ${widget.nname ?? 'Not available'}'),
               Text('key: ${widget.nkey ?? 'Not available'}'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchData,
                child: Text('Okay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
