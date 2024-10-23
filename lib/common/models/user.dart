// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IUser {
  final String email;
  final String name;
  final String role;
  final String uid;

  IUser(
      {required this.email,
      required this.name,
      required this.role,
      required this.uid});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'role': role,
      'uid': uid,
    };
  }

  factory IUser.fromMap(Map<String, dynamic> map) {
    return IUser(
      email: map['email'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      uid: map['uid'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory IUser.fromJson(String source) =>
      IUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'IUser(email: $email, name: $name, role: $role, uid: $uid)';
  }
}
