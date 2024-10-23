class Office {
  final String name;
  final String uid;
  final List<String> rooms;
  Office({
    required this.name,
    required this.uid,
    required this.rooms,
  });

  Office copyWith({
    String? name,
    String? uid,
    List<String>? rooms,
    int? count,
  }) {
    return Office(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      rooms: rooms ?? this.rooms,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'uid': uid,
      'rooms': rooms,
    };
  }

  factory Office.fromMap(Map<String, dynamic> map) {
    return Office(
      name: map['name'] as String,
      uid: map['uid'] as String,
      rooms: List<String>.from((map['rooms'] as List<dynamic>)),
    );
  }

  @override
  String toString() {
    return 'Office(name: $name, uid: $uid, rooms: $rooms)';
  }
}
