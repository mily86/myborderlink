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

  // Move static session helpers here for global access
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('officer_id');
    await prefs.remove('full_name');
    await prefs.remove('checkpoint');
  }

  static Future<int?> getOfficerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('officer_id');
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('full_name');
  }

  static Future<String?> getCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('checkpoint');
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController officerIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
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
        int officerId = jsonResponse['data'][0]['officer_id'];
        String fullName = jsonResponse['data'][0]['officer_fullname'];
        String checkpoint = jsonResponse['data'][0]['officer_checkpoint'];

        if (isChecked) {
          storeCredentials(officerId, fullName, checkpoint);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful — credentials stored'),
              backgroundColor: Colors.green,
            ),
          );
        }

        await _onLoginSuccess(officerId, fullName, checkpoint);
      } else {
        showMessage(jsonResponse['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (mounted) showMessage('Error: ${e.toString()}');
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void storeCredentials(
    int officerId,
    String fullName,
    String checkpoint,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('officer_id', officerId);
    await prefs.setString('full_name', fullName);
    await prefs.setString('checkpoint', checkpoint);
    await prefs.setBool('isChecked', isChecked);
  }

  void removeCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('officer_id');
    await prefs.remove('full_name');
    await prefs.remove('checkpoint');
    await prefs.remove('isChecked');

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

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final officerId = prefs.getInt('officer_id');
    final fullName = prefs.getString('full_name');
    final checkpoint = prefs.getString('checkpoint');
    if (officerId != null && fullName != null && checkpoint != null) {
      // User is already logged in, go to MainScreen
      if (mounted) {
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
      }
    }
  }

  Future<void> _onLoginSuccess(
    int officerId,
    String fullName,
    String checkpoint,
  ) async {
    if (mounted) {
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
    }
  }
}
