class DummyOffice {
  String name;
  List<String> rooms;
  DummyOffice({
    required this.name,
    required this.rooms,
  });

  DummyOffice copyWith({
    String? name,
    List<String>? rooms,
  }) {
    return DummyOffice(
      name: name ?? this.name,
      rooms: rooms ?? this.rooms,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'rooms': rooms,
    };
  }

  factory DummyOffice.fromMap(Map<String, dynamic> map) {
    return DummyOffice(
        name: map['name'] as String,
        rooms: List<String>.from(
          (map['rooms'] as List<String>),
        ));
  }

  @override
  String toString() => 'Office(name: $name, rooms: $rooms)';
}
