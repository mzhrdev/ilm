import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/home/data/dummy_data/dummy_categories.dart';
import 'package:riverpod/riverpod.dart';

final categoriesProvider = Provider<List<String>>((ref) {
  return mockCategories;
});
