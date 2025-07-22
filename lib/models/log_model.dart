class LogEntry {
  final String? date;
  final String? vehiclePlate;
  final String? inspectionType;
  final String? findings;
  final String? location;
  final int? officerId;

  LogEntry({
    required this.date,
    required this.vehiclePlate,
    required this.inspectionType,
    required this.findings,
    required this.location,
    required this.officerId,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'vehicle_plate': vehiclePlate,
    'inspection_type': inspectionType,
    'findings': findings,
    'location': location,
    'officer_id': officerId,
  };

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      date: json['date'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      inspectionType: json['inspection_type'] ?? '',
      findings: json['findings'] ?? '',
      location: json['location'] ?? '',
      officerId: json['officer_id'],
    );
  }
}