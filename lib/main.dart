import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/app.dart';

void main() {
  // Used for storing state of providers. A Must for Riverpod in Main
  runApp(const ProviderScope(child: MyApp()));
}
