import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myborderlink/loginscreen.dart';
import 'package:myborderlink/myconfig.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController officerIdController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController checkpointController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: officerIdController,
              decoration: const InputDecoration(
                labelText: 'Officer ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: checkpointController,
              decoration: const InputDecoration(
                labelText: 'Checkpoint Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: () => registerDialog(context),
                  child: const Text('Register'),
                ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }

  void registerDialog(BuildContext context) {
    String officerId = officerIdController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (officerId.isEmpty ||
        fullNameController.text.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        checkpointController.text.isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      showMessage('Please enter a valid email');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters');
      return;
    }

    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Confirm Registration'),
            content: Text('Register account for Officer ID: $officerId?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  registerOfficer();
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No'),
              ),
            ],
          ),
    );
  }

  void registerOfficer() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${MyConfig.apiUrl}register_user.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'officer_id': officerIdController.text.trim(),
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'checkpoint_location': checkpointController.text.trim(),
      }),
    );

    setState(() {
      isLoading = false;
    });

    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
      showMessage('Registration successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      showMessage(jsonResponse['message'] ?? 'Registration failed');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
