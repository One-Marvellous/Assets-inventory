class MaintenanceDetails {
  final String name;
  final String inventoryId;
  final String subOfficeId;

  MaintenanceDetails({
    required this.name,
    required this.inventoryId,
    required this.subOfficeId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'inventoryId': inventoryId,
      'subOfficeId': subOfficeId,
    };
  }

  factory MaintenanceDetails.fromMap(Map<String, dynamic> map) {
    return MaintenanceDetails(
      name: map['name'] as String,
      inventoryId: map['inventoryId'] as String,
      subOfficeId: map['subOfficeId'] as String,
    );
  }

  @override
  String toString() {
    return "MaintenanceDetails(name: $name, inventoryId: $inventoryId, subOfficeId: $subOfficeId)";
  }
}
