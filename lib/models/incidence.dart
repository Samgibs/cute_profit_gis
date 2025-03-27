import 'package:latlong2/latlong.dart';

class Incidence {
  final String id;
  final String title;
  final String description;
  final String severity;
  final String status;
  final String itemId;
  final String itemName;
  final String reportedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LatLng location;

  Incidence({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.itemId,
    required this.itemName,
    required this.reportedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
  });

  factory Incidence.fromJson(Map<String, dynamic> json) {
    return Incidence(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      severity: json['severity'],
      status: json['status'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      reportedBy: json['reported_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      location: LatLng(
        json['location']['latitude'],
        json['location']['longitude'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity,
      'status': status,
      'item_id': itemId,
      'item_name': itemName,
      'reported_by': reportedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    };
  }
}
