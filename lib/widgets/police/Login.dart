import 'package:flutter/material.dart';
// Adjust path as per your project
import '../../main.dart';
import '../../services/auth_servicesp.dart'; // Adjust path as per your project
import 'Register.dart'; // Adjust path as per your project

class policelogin extends StatefulWidget {
  @override
  State<policelogin> createState() => _PoliceLoginState();
}

class _PoliceLoginState extends State<policelogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var authService = AuthServicep();

  Future<void> _submitForm() async {
    var data = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    await authService.policeLogin(data, context);
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Just pop the current page and go back to the previous one
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Police Login'),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with Overlay
            Image.asset(
              'assets/images/img_2.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.4), // Dark overlay
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20.0),
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(height: 20.0),
                              TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  primary: Colors.green,
                                ),
                                child: Text('Login'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpView()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
