import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myborderlink/myconfig.dart';

class LogsDisplayPage extends StatefulWidget {
  const LogsDisplayPage({super.key});

  @override
  _LogsDisplayPageState createState() => _LogsDisplayPageState();
}

class _LogsDisplayPageState extends State<LogsDisplayPage> {
  List<Log> logs = [];
  String officerId = '';
  String searchDate = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOfficerId();
    _fetchLogs();
  }

  // Load officer ID from SharedPreferences
  Future<void> _loadOfficerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      officerId = prefs.getString('officer_id') ?? '';
    });
  }

  // Fetch logs from the server
  Future<void> _fetchLogs() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${MyConfig.apiUrl}get_logs.php'), // Using MyConfig here
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'officer_id': officerId}),
    );

    if (response.statusCode == 200) {
      final List logsData = jsonDecode(response.body);
      setState(() {
        logs = logsData.map((log) => Log.fromJson(log)).toList();
      });
    } else {
      _showErrorMessage("Failed to load logs");
    }

    setState(() {
      isLoading = false;
    });
  }

  // Show an error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Search/filter logs by date
  void _searchLogs(String query) {
    setState(() {
      searchDate = query;
      logs = logs.where((log) => log.date.contains(searchDate)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logs Display")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Search Bar
            TextField(
              decoration: const InputDecoration(
                labelText: "Search by Date (YYYY-MM-DD)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchLogs,
            ),
            const SizedBox(height: 10),

            // Loading Indicator
            if (isLoading) const Center(child: CircularProgressIndicator()),

            // Logs List
            if (!isLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ListTile(
                      title: Text('Inspection: ${log.inspectionType}'),
                      subtitle: Text(
                        'Date: ${log.date}, Vehicle: ${log.vehiclePlateNumber}',
                      ),
                      onTap: () {
                        // You can navigate to a detailed log screen if needed
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Log {
  final String inspectionType;
  final String date;
  final String vehiclePlateNumber;

  Log({
    required this.inspectionType,
    required this.date,
    required this.vehiclePlateNumber,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      inspectionType: json['inspection_type'],
      date: json['date'],
      vehiclePlateNumber: json['vehicle_plate'],
    );
  }
}
