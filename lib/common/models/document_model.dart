import 'package:assets_inventory_app_ghum/common/models/action.dart';
import 'package:assets_inventory_app_ghum/common/models/maintenance_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String uid;
  final String officeName;
  final String subOfficeName;
  final String operation;
  final String authenticator;
  final String report;
  final int quantity;
  final String? executor;
  final String? technician;
  final String? supplier;
  final Timestamp? timeStamp;
  final MaintenanceDetails? inventory;
  final String? price;
  final int? duration;
  final List<ActionItem>? action;
  final bool isCompleted;

  DocumentModel({
    required this.id,
    required this.uid,
    required this.officeName,
    required this.subOfficeName,
    required this.report,
    required this.operation,
    required this.authenticator,
    required this.quantity,
    this.executor,
    this.technician,
    this.supplier,
    this.timeStamp,
    this.inventory,
    this.price,
    this.duration,
    this.action,
    this.isCompleted = false,
  });

  DocumentModel copyWith({
    String? id,
    String? uid,
    String? officeName,
    String? subOfficeName,
    String? report,
    String? operation,
    String? authenticator,
    int? quantity,
    String? executor,
    String? technician,
    String? supplier,
    Timestamp? timeStamp,
    MaintenanceDetails? inventory,
    String? price,
    int? duration,
    List<ActionItem>? action,
    bool? isCompleted,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      officeName: officeName ?? this.officeName,
      subOfficeName: subOfficeName ?? this.subOfficeName,
      report: report ?? this.report,
      operation: operation ?? this.operation,
      authenticator: authenticator ?? this.authenticator,
      quantity: quantity ?? this.quantity,
      executor: executor ?? this.executor,
      technician: technician ?? this.technician,
      supplier: supplier ?? this.supplier,
      timeStamp: timeStamp ?? this.timeStamp,
      inventory: inventory ?? this.inventory,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      action: action ?? this.action,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'officeName': officeName,
      'report': report,
      'subOfficeName': subOfficeName,
      'operation': operation,
      'authenticator': authenticator,
      'quantity': quantity,
      'executor': executor,
      'technician': technician,
      'supplier': supplier,
      'price': price,
      'timeStamp': FieldValue.serverTimestamp(),
      'inventory': inventory?.toMap(),
      'duration': duration,
      'action': action?.map((x) => x.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      uid: map['uid'] as String,
      officeName: map['officeName'] as String,
      report: map['report'] as String,
      subOfficeName: map['subOfficeName'] as String,
      operation: map['operation'] as String,
      authenticator: map['authenticator'] as String,
      quantity: map['quantity'] as int,
      executor: map['executor'] != null ? map['executor'] as String : null,
      technician:
          map['technician'] != null ? map['technician'] as String : null,
      supplier: map['supplier'] != null ? map['supplier'] as String : null,
      price: map['price'] != null ? map['price'] as String : null,
      timeStamp: map['timeStamp'],
      duration: map['duration'] != null ? map['duration'] as int : null,
      isCompleted: map['isCompleted'] as bool,
      inventory: map['inventory'] != null
          ? MaintenanceDetails.fromMap(map['inventory'] as Map<String, dynamic>)
          : null,
      action: map['action'] != null
          ? List<ActionItem>.from(
              (map['action'] as List<dynamic>).map<ActionItem?>(
                (x) => ActionItem.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id uid: $uid, officeName: $officeName, subOfficeName: $subOfficeName, operation: $operation, authenticator: $authenticator, quantity: $quantity, executor: $executor, technician: $technician, supplier: $supplier, price: $price, time: $timeStamp, comment: $report, isCompleted: $isCompleted, action: $action, inventory: ${inventory.toString()})';
  }
}
