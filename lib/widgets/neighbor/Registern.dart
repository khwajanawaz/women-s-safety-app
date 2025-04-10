// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
// import '../../services/auth_servicesn.dart';
// import 'Loginn.dart';
//
//
// class SignUpView extends StatefulWidget {
//   SignUpView({super.key});
//
//   @override
//   State<SignUpView> createState() => _SignUpViewState();
// }
//
// class _SignUpViewState extends State<SignUpView> {
//   final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _cityController = TextEditingController();
//
//   var isLoader = false;
//   var authservice = AuthServicen();
//
//   Future<void> _submitform() async {
//     if (_formkey.currentState!.validate()) {
//       setState(() {
//         isLoader = true;
//       });
//
//       var data = {
//         "email": _emailController.text,
//         "password": _passwordController.text,
//         "name": _usernameController.text,
//         "contact": _phoneController.text,
//         "city": _cityController.text,
//       };
//
//       await authservice.createneighbors(data, context);
//
//       setState(() {
//         isLoader = false;
//       });
//
//       ScaffoldMessenger.of(_formkey.currentContext!).showSnackBar(
//         const SnackBar(content: Text('Register Successfully')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => NeighborLogin()),
//         );
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Color(0xFF252634),
//         body: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formkey,
//               child: Column(
//                 children: [
//                   SizedBox(height: 50.0),
//                   Text(
//                     'Create new Account',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 16.0),
//                   _buildTextField(_emailController, 'Email', Icons.email, TextInputType.emailAddress),
//                   SizedBox(height: 16.0),
//                   _buildTextField(_passwordController, 'Password', Icons.lock, TextInputType.visiblePassword, obscureText: true),
//                   SizedBox(height: 16.0),
//                   _buildTextField(_usernameController, 'Name', Icons.person, TextInputType.name),
//                   SizedBox(height: 16.0),
//                   _buildTextField(_phoneController, 'Contact', Icons.phone, TextInputType.phone),
//                   SizedBox(height: 16.0),
//                   _buildTextField(_cityController, 'City', Icons.location_city, TextInputType.text),
//                   SizedBox(height: 40.0),
//                   SizedBox(
//                     height: 50.0,
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         isLoader ? print("Loading") : _submitform();
//                       },
//                       child: isLoader
//                           ? Center(child: CircularProgressIndicator())
//                           : Text(
//                         'Create',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color.fromARGB(255, 245, 89, 0),
//                         onPrimary: Colors.white,
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5.0),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 30.0),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => NeighborLogin()),
//                       );
//                     },
//                     child: Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Color.fromARGB(255, 245, 89, 0),
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType inputType, {bool obscureText = false}) {
//     return TextFormField(
//       controller: controller,
//       style: TextStyle(color: Colors.white),
//       cursorColor: Colors.blue,
//       keyboardType: inputType,
//       obscureText: obscureText,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       decoration: InputDecoration(
//         fillColor: Color(0xAA494A59),
//         filled: true,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: Color(0x35949494)),
//         ),
//         labelStyle: TextStyle(color: Color(0xFF949494)),
//         labelText: label,
//         suffixIcon: Icon(icon, color: Colors.white),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:womenss/widgets/neighbor/view.dart';
import 'package:womenss/widgets/user/womensinterface.dart';

import '../../services/auth_servicesn.dart';
import '../user/seprated.dart';
import 'Loginn.dart';

class SignUpView extends StatefulWidget {
  SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();

  var isLoader = false;
  var authservice = AuthServicen();

  Future<void> _submitform() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      var data = {
        "email": _emailController.text,
        "password": _passwordController.text,
        "name": _usernameController.text,
        "contact": _phoneController.text,
        "city": _cityController.text,
        "status": "pending"
      };

      await authservice.createneighbors(data, context);

      setState(() {
        isLoader = false;
      });

      ScaffoldMessenger.of(_formkey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Register Successfully')),
      );

      // Start monitoring the user's status
      _monitorUserStatus();
    }
  }

  void _monitorUserStatus() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(user.uid);
      userRef.onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.exists) {
          var userData = snapshot.value as Map?;
          if (userData != null && userData['status'] == 'approved') {
            // Move to womensinterface page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePageeeg()),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NeighborLogin()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF252634),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  SizedBox(height: 50.0),
                  Text(
                    'Create new Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _buildTextField(_emailController, 'Email', Icons.email, TextInputType.emailAddress),
                  SizedBox(height: 16.0),
                  _buildTextField(_passwordController, 'Password', Icons.lock, TextInputType.visiblePassword, obscureText: true),
                  SizedBox(height: 16.0),
                  _buildTextField(_usernameController, 'Name', Icons.person, TextInputType.name),
                  SizedBox(height: 16.0),
                  _buildTextField(_phoneController, 'Contact', Icons.phone, TextInputType.phone),
                  SizedBox(height: 16.0),
                  _buildTextField(_cityController, 'City', Icons.location_city, TextInputType.text),
                  SizedBox(height: 40.0),
                  SizedBox(
                    height: 50.0,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        isLoader ? print("Loading") : _submitform();
                      },
                      child: isLoader
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                        'Create',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 245, 89, 0),
                        onPrimary: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NeighborLogin()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 245, 89, 0),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType inputType, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.blue,
      keyboardType: inputType,
      obscureText: obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        fillColor: Color(0xAA494A59),
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0x35949494)),
        ),
        labelStyle: TextStyle(color: Color(0xFF949494)),
        labelText: label,
        suffixIcon: Icon(icon, color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
