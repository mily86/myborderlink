import 'package:flutter/material.dart';
import 'models/log_model.dart';
import 'myconfig.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LogDisplayScreen extends StatefulWidget {
  final int officerId;

  const LogDisplayScreen({super.key, required this.officerId});

  @override
  State<LogDisplayScreen> createState() => _LogDisplayScreenState();
}

class _LogDisplayScreenState extends State<LogDisplayScreen> {
  late Future<List<LogEntry>> _logsFuture;
  List<LogEntry> _allLogs = [];
  List<LogEntry> _filteredLogs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logsFuture = fetchLogs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<LogEntry>> fetchLogs() async {
    try {
      final url = Uri.parse('${MyConfig.apiUrl}get_logs.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'officer_id': widget.officerId}),
      );
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          // Accept both 'status' and 'success' for compatibility
          final bool isSuccess =
              (data['status'] == 'success') || (data['success'] == true);
          if (isSuccess && data['logs'] != null) {
            final logs =
                (data['logs'] as List)
                    .map((log) => LogEntry.fromJson(log))
                    .toList();
            _allLogs = logs;
            _filteredLogs = logs;
            return logs;
          } else {
            throw Exception(data['message'] ?? 'Failed to load logs');
          }
        } catch (e) {
          throw Exception('Invalid server response.');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
        'Could not fetch logs. Please check your connection or try again later.\nError: $e',
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLogs = List.from(_allLogs);
      } else {
        _filteredLogs =
            _allLogs.where((log) {
              final date = (log.date ?? '').toLowerCase();
              return date.contains(query);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<LogEntry>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error:  ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs found.'));
          }
          // Only set _allLogs and _filteredLogs if they are empty (first build after fetch)
          if (_allLogs.isEmpty) {
            _allLogs = snapshot.data!;
            _filteredLogs = List.from(_allLogs);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by Date (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child:
                    _filteredLogs.isEmpty
                        ? const Center(
                          child: Text('No logs match your search.'),
                        )
                        : ListView.builder(
                          itemCount: _filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  '${log.inspectionType} - ${log.vehiclePlate}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: ${log.date}'),
                                    Text('Findings: ${log.findings}'),
                                    Text('Location: ${log.location}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
