import 'package:flutter/material.dart';
import 'package:water_reporter/components/my_button.dart';
import 'package:water_reporter/components/my_textfield.dart';
import 'package:water_reporter/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:water_reporter/pages/login_page.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  RegisterPage({super.key});

  void register(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _pwController.text.trim();
    final confirmPassword = _confirmpwController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        username.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Error'),
          content: Text('All fields are required.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Error"),
          content: Text("Passwords don't match!"),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.208.86:5000/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Registration successful!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                              email: '',
                              password: '',
                            )),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(responseData['error'] ?? 'Registration failed.'),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/rescue.png",
                        height: 60,
                        width: 60,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Let's create an account for you",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      MyTextfield(
                        hintText: "Email",
                        obscureText: false,
                        controller: _emailController,
                        textStyle: const TextStyle(color: Colors.black),
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyTextfield(
                        hintText: "Username",
                        obscureText: false,
                        controller: _usernameController,
                        textStyle: const TextStyle(color: Colors.black),
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyTextfield(
                        hintText: "Password",
                        obscureText: true,
                        controller: _pwController,
                        textStyle: const TextStyle(color: Colors.black),
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyTextfield(
                        hintText: "Confirm Password",
                        obscureText: true,
                        controller: _confirmpwController,
                        textStyle: const TextStyle(color: Colors.black),
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        text: "Register",
                        onTap: () => register(context),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LoginPage(onTap: null)),
                              );
                            },
                            child: Text(
                              " Login now",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
