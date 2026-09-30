class IncidentLog {
  int? id;
  String timestamp;
  String type; // e.g., 'Medical', 'Fire', 'Security', 'SOS'
  String status; // e.g., 'Resolved', 'Pending'
  String summary;
  double latitude;
  double longitude;

  IncidentLog({
    this.id,
    required this.timestamp,
    required this.type,
    required this.status,
    required this.summary,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'type': type,
      'status': status,
      'summary': summary,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory IncidentLog.fromMap(Map<String, dynamic> map) {
    return IncidentLog(
      id: map['id'] as int?,
      timestamp: map['timestamp'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      summary: map['summary'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }
}
