import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchProvider = StateProvider<List<String>>((ref) {
  return [];
});