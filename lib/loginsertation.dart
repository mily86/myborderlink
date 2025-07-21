import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'MyConfig.dart';

class LogInsertionScreen extends StatefulWidget {
  const LogInsertionScreen({super.key});

  @override
  _LogInsertionScreenState createState() => _LogInsertionScreenState();
}

class _LogInsertionScreenState extends State<LogInsertionScreen> {
  final TextEditingController vehiclePlateController = TextEditingController();
  final TextEditingController findingsController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedInspectionType = 'Physical Examination'; // Default value
  String officerLocation = ''; // Variable to hold location
  String officerId = ''; // Officer ID will be auto-filled
  String officerCheckpoint = ''; // Officer's checkpoint
  bool _isSubmitting = false; // For showing loading indicator

  @override
  void initState() {
    super.initState();
    _getOfficerSession(); // Retrieve officer's details from SharedPreferences
  }

  // Retrieve the officer's checkpoint and location from SharedPreferences
  Future<void> _getOfficerSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      officerCheckpoint =
          prefs.getString('checkpoint') ?? ''; // Retrieve officer's checkpoint
      officerId = prefs.getString('officer_id') ?? ''; // Retrieve officer ID
      officerLocation =
          prefs.getString('location') ??
          'Unknown Location'; // Retrieve location based on checkpoint
    });

    // Debugging to ensure correct data retrieval
    print("Retrieved Checkpoint: $officerCheckpoint");
    print("Retrieved Location: $officerLocation");
  }

  // Submit log data to the server
  Future<void> _submitLog() async {
    setState(() {
      _isSubmitting = true; // Show loading indicator
    });

    if (vehiclePlateController.text.isEmpty ||
        findingsController.text.isEmpty) {
      _showMessage('Please fill in all fields.');
      setState(() {
        _isSubmitting = false; // Hide loading indicator
      });
      return;
    }

    try {
      // Debugging: Print the full API URL to ensure it's correct
      print("API URL: ${MyConfig.apiUrl}insert_log.php");

      final response = await http.post(
        Uri.parse(
          '${MyConfig.apiUrl}insert_log.php',
        ), // Using the API URL from MyConfig
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'date': selectedDate.toIso8601String(),
          'vehicle': vehiclePlateController.text,
          'inspection_type': selectedInspectionType,
          'findings': findingsController.text,
          'location': officerLocation,
          'officer_id': officerId,
        }),
      );

      // Debugging: Print the response from the server
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          _showMessage(result['message']);
        } else {
          _showMessage(result['message'] ?? "Failed to add log.");
        }
      } else {
        _showMessage("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e"); // Catch any error during the request
      _showMessage('Error: $e');
    } finally {
      setState(() {
        _isSubmitting = false; // Hide loading indicator
      });
    }
  }

  // Show message in a dialog box
  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Open date picker to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked =
        await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        selectedDate;

    setState(() {
      selectedDate = picked; // Update selected date
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Insert Log")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Date Picker Button
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text("Select Date: ${selectedDate.toLocal()}"),
            ),

            // Vehicle Plate Number Input
            TextField(
              controller: vehiclePlateController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Plate Number',
              ),
            ),

            // Inspection Type Dropdown
            DropdownButton<String>(
              value: selectedInspectionType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedInspectionType = newValue!;
                });
              },
              items:
                  <String>[
                    'Physical Examination',
                    'Full Inspection',
                    'Import Clearance',
                    'Export Clearance',
                    'Others',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),

            // Findings Text Area
            TextField(
              controller: findingsController,
              decoration: const InputDecoration(labelText: 'Findings'),
              maxLines: 4,
            ),

            // Display the officer's location (auto-filled based on checkpoint)
            Text(
              "Location: $officerLocation",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // Submit Log Button
            ElevatedButton(
              onPressed:
                  _isSubmitting
                      ? null
                      : _submitLog, // Disable the button while submitting
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Log"),
            ),
          ],
        ),
      ),
    );
  }
}
