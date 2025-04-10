import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



import '../../services/auth_services.dart';
import 'LoginPage.dart';

class SignUpView extends StatefulWidget {
  SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _usernamecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _phonecontroller = TextEditingController();
  final _voicecontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _contact1Controller = TextEditingController();
  final _contact2Controller = TextEditingController();
  final _contact3Controller = TextEditingController();
  final _contact4Controller = TextEditingController();

  final _addressController = TextEditingController();

  var isLoader = false;
  var authservice = AuthService();

  Future<void> _submitform() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      var data = {
        "email": _emailcontroller.text,
        "password": _passwordcontroller.text,
        "name": _usernamecontroller.text,
        "contact": _phonecontroller.text,
        "voice": _voicecontroller.text,
        "contact1": _contact1Controller.text,

        "contact2": _contact2Controller.text,
        "contact3": _contact3Controller.text,
        "contact4": _contact4Controller.text,

        "Address": _addressController.text,




      };

      await authservice.createWomens(data, context);

      setState(() {
        isLoader = false;
      });

      ScaffoldMessenger.of(_formkey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Register Successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        // Return false to prevent closing the current screen immediately
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
                  SizedBox(
                    width: 250,
                    child: Text(
                      'Create new Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailcontroller,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.blue,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration('Email', Icons.email),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordcontroller,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.blue,
                    keyboardType: TextInputType.visiblePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration('Password', Icons.lock),
                  ),
                  SizedBox(height: 40.0),
                  TextFormField(
                    controller: _usernamecontroller,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.blue,
                    keyboardType: TextInputType.visiblePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration('name', Icons.person),
                  ),
                  SizedBox(height: 40.0),
                  TextFormField(
                    controller: _phonecontroller,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.blue,
                    keyboardType: TextInputType.visiblePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration('contact', Icons.mobile_friendly_outlined),
                  ),
                  SizedBox(height: 40.0),
                  TextFormField(
                    controller: _voicecontroller,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.blue,
                    keyboardType: TextInputType.visiblePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration('voice', Icons.keyboard_voice),
                  ),
                  SizedBox(height: 40.0),
                  Card(
                    color: Color(0xFF494A59),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Emergency SMS Contacts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _contact1Controller,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.blue,
                            keyboardType: TextInputType.phone,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration('Contact 1', Icons.contact_emergency),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _contact2Controller,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.blue,
                            keyboardType: TextInputType.phone,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration('Contact 2', Icons.contact_emergency),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _contact3Controller,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.blue,
                            keyboardType: TextInputType.phone,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration('Contact 3', Icons.contact_emergency),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _contact4Controller,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.blue,
                            keyboardType: TextInputType.phone,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration('Contact 4', Icons.contact_emergency),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _addressController,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.blue,
                            keyboardType: TextInputType.text,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration('Address', Icons.contact_emergency),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        backgroundColor: Color.fromARGB(255, 245, 89, 0), // Background color
                        onPrimary: Colors.white, // Text color
                        elevation: 4, // Elevation (shadow)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // Border radius
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  TextButton(
                    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    );
    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 245, 89, 0),
                        fontSize: 25,
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


  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
      fillColor: Color(0xAA494A59),
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Color(0x35949494)),
      ),
      labelStyle: TextStyle(color: Color(0xFF949494)),
      labelText: label,
      suffixIcon: Icon(suffixIcon),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }
}

