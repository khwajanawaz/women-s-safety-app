import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../widgets/neighbor/view.dart';
import '../widgets/user/LoginPage.dart';
import '../widgets/user/seprated.dart';
import '../widgets/user/womensinterface.dart';

class AuthService {
  Future<void> createWomens(Map<String, String> data, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email']!,
        password: data['password']!,
      );

      DatabaseReference _database = FirebaseDatabase.instance.reference();
      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;

      if (userId != null) {
        await _database.child('womens').child(userId).set({
          'email': data['email'],
          'password': data['password'],
          'name': data['name'],
          'contact': data['contact'],
          'voice': data['voice'],
          'contact1': data['contact1'],
          'contact2': data['contact2'],
          'contact3': data['contact3'],
          'contact4': data['contact4'],
          'Address': data['Address'],
          'ukey': userId,
          'status': "request",
        });

        await sendVerificationEmail();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered Successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
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

  Future<void> womensLogin(Map<String, String> data, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email']!,
        password: data['password']!,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        if (user!.emailVerified) {
          DatabaseReference _database = FirebaseDatabase.instance.reference();
          String? userId = user.uid;

          DatabaseReference databaseReference = _database.child('womens').child(userId);

          DatabaseEvent event = await databaseReference.once();
          var userData = event.snapshot.value;

          if (userData is Map) {
            Map<String, dynamic> userDataMap = Map<String, dynamic>.from(userData);

            String? name = userDataMap['name'];
            String? email = userDataMap['email'];
            String? contact = userDataMap['contact'];
            String? Address = userDataMap['Address'];
            String? ukey = userDataMap['ukey'];

            // ... Extract other necessary fields

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successfully')),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WomensInterface(








              )),
            );
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Text("No user data found."),
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Email not verified"),
                content: Text("Please Verify Your Email"),
              );
            },
          );
        }
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

  Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print("Verification email sent to ${user.email}");
    }
  }
}
