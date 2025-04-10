import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import '../widgets/police/Login.dart';
import '../widgets/police/policeinterface.dart';

class AuthServicep {


  Future<void> createpolices(data, context) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],




      );

      DatabaseReference _database = FirebaseDatabase.instance.reference();
      FirebaseAuth _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;
      String? userId = user?.uid;

      DatabaseEvent databaseEvent = await _database.child('police').once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      await _database.child('police').child(userId!).set({
        'email': data['email'],
        'password': data['password'],

        'stationno': data['station'],
        'locality': data['locality'],
        'city': data['city'],
        'lattitude': data['latitude'],
        'logitude': data['longitude'],

        'ukey':userId ,

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered Successfully')),

      );


      Navigator.push(context, MaterialPageRoute(builder: (context) =>  policelogin(),));
    } catch (e) {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text("Sign Up Failed"),
          content: Text(e.toString()),

        );
      });
    }
  }

  Future<void> policeLogin(data, context) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

          print("User is verified. Proceed with login.");
          // Perform the actions for a logged-in verified user.

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login  Successfully')),

          );

          Navigator.pushReplacement(
              context as BuildContext, MaterialPageRoute(builder: (context) => PoliceInterface(),));




          print("User is not verified. Please check your email for the verification link.");



      }





    } catch (e) {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text("Login Error"),
          content: Text(e.toString()),

        );
      });
    }
  }

  Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print("Verification email sent to ${user.email}");
    }
  }
}





















