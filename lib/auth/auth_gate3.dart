import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/neighbor/Loginn.dart';
import '../widgets/neighbor/neighborinterface.dart';









void main() {
  runApp(new MaterialApp(
    home: new AuthGaten(),



  ));


}

class AuthGaten extends StatelessWidget {
  const AuthGaten({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(!snapshot.hasData) {
            return NeighborLogin();

          }
          return NeighborInterface();
        }

    );

  }
}








