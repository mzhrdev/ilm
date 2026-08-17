import 'package:Edvance/features/home/data/dummy_data/dummy_categories.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesProvider = Provider<List<String>>((ref) {
  return mockCategories;
});
