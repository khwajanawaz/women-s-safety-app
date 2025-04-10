import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/auth_servicesn.dart';
import 'Registern.dart'; // Import SignUpView if it's in the same directory

class NeighborLogin extends StatefulWidget {
  @override
  State<NeighborLogin> createState() => _NeighborLoginState();
}

class _NeighborLoginState extends State<NeighborLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var authService = AuthServicen();

  Future<void> _submitForm() async {
    var data = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    await authService.neighborlogin(data, context);
  }

  Future<bool> _onWillPop() async {
    // Navigate to MyApp and replace the current page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    // Return false to prevent the default back navigation
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Login'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Don\'t have an account?',
                style: TextStyle(
                  color: Colors.black, // Changed to black for better readability
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
    );
  }
}
