import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/log_model.dart';
import 'myconfig.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LogInsertionScreen extends StatefulWidget {
  final int officerId;
  final String location;

  const LogInsertionScreen({
    super.key,
    required this.officerId,
    required this.location,
  });

  @override
  State<LogInsertionScreen> createState() => _LogInsertionScreenState();
}

class _LogInsertionScreenState extends State<LogInsertionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _findingsController = TextEditingController();

  String? _selectedInspectionType;
  bool _isSubmitting = false;

  final List<String> _inspectionTypes = [
    'Routine',
    'Random',
    'Suspicious Vehicle',
    'Other',
  ];

  @override
  void dispose() {
    _dateController.dispose();
    _vehicleController.dispose();
    _findingsController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final logEntry = LogEntry(
      date: _dateController.text,
      vehiclePlate: _vehicleController.text,
      inspectionType: _selectedInspectionType!,
      findings: _findingsController.text,
      location: widget.location,
      officerId: widget.officerId,
    );

    final response = await insertLog(logEntry);

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? 'Unknown error')),
    );

    if (response['status'] == "success") {
      _formKey.currentState!.reset();
      _dateController.clear();
      _vehicleController.clear();
      _findingsController.clear();
      setState(() => _selectedInspectionType = null);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<Map<String, dynamic>> insertLog(LogEntry log) async {
    final url = Uri.parse('${MyConfig.apiUrl}insert_log.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(log.toJson()),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      return {'success': false, 'message': 'Server error'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insert Activity Log'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Date Picker
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _dateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(picked);
                  }
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please select a date'
                            : null,
              ),
              const SizedBox(height: 16),
              // Vehicle Plate Number
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Plate Number',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter vehicle plate number'
                            : null,
              ),
              const SizedBox(height: 16),
              // Inspection Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedInspectionType,
                items:
                    _inspectionTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged:
                    (val) => setState(() => _selectedInspectionType = val),
                decoration: const InputDecoration(
                  labelText: 'Type of Inspection',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null ? 'Please select inspection type' : null,
              ),
              const SizedBox(height: 16),
              // Findings
              TextFormField(
                controller: _findingsController,
                decoration: const InputDecoration(
                  labelText: 'Findings',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter findings'
                            : null,
              ),
              const SizedBox(height: 16),
              // Location (read-only)
              TextFormField(
                initialValue: widget.location,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLog,
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
