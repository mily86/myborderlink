import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myborderlink/mainscreen.dart';
import 'package:myborderlink/registerscreen.dart';
import 'package:myborderlink/myconfig.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController officerIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Login'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: officerIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Officer ID (Numeric)',
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
              Row(
                children: [
                  const Text('Remember Me'),
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                      isChecked ? storeCredentials() : removeCredentials();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : loginOfficer,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginOfficer() async {
    final String officerIdText = officerIdController.text.trim();
    final String password = passwordController.text.trim();
    final int? officerId = int.tryParse(officerIdText);

    if (officerId == null || password.isEmpty) {
      if (mounted) {
        showMessage('Please enter a valid numeric Officer ID and password');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${MyConfig.apiUrl}login_user.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'officer_id': officerId, 'password': password}),
      );

      if (!mounted) return;

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        if (isChecked) {
          storeCredentials();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful — credentials stored'),
              backgroundColor: Colors.green,
            ),
          );
        }

        String officerId = jsonResponse['data']['officer_id'].toString();
        String fullName = jsonResponse['data']['officer_fullname'];
        String checkpoint = jsonResponse['data']['officer_checkpoint'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => MainScreen(
                  officerId: officerId,
                  fullName: fullName,
                  checkpoint: checkpoint,
                ),
          ),
        );
      } else {
        showMessage(jsonResponse['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (mounted) showMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void storeCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('officer_id', officerIdController.text);
    await prefs.setString('password', passwordController.text);
    await prefs.setBool('ischecked', isChecked);
  }

  void removeCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('officer_id');
    await prefs.remove('password');
    await prefs.remove('ischecked');

    if (!mounted) return;

    officerIdController.clear();
    passwordController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Credentials removed')));
  }

  void loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      officerIdController.text = prefs.getString('officer_id') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      isChecked = prefs.getBool('ischecked') ?? false;
    });
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
