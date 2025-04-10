import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


import '../widgets/neighbor/Loginn.dart';
import '../widgets/neighbor/neighborinterface.dart'; // Adjust path as per your project structure

class AuthServicen {
  Future<void> createneighbors(data, context) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );

      // Saving additional data to Firebase Realtime Database

      DatabaseReference _database = FirebaseDatabase.instance.reference();
      FirebaseAuth _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;
      String? userId = user?.uid;

      DatabaseEvent databaseEvent = await _database.child('neighbours').once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      await _database.child('neighbours').child(userId!).set({


        'name': data['name'],
        'email': data['email'],
        'password': data['password'],
        'contact': data['contact'],
        'ukey':userId ,
        'status':'request' ,
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered Successfully')),

      );



      Navigator.push(context, MaterialPageRoute(builder: (context) => NeighborLogin()));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Sign Up Failed"),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future<void> neighborlogin(data, context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;


          print("User is verified. Proceed with login.");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login  Successfully')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NeighborInterface()),
          );

      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Login Error"),
            content: Text(e.toString()),
          );
        },
      );
    }

  }
}

Future<void> sendVerificationEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && !user.emailVerified) {
    await user.sendEmailVerification();
    print("Verification email sent to ${user.email}");
  }
}


