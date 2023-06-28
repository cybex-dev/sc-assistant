import 'package:flutter/material.dart';

import 'core/app/app.dart';
import 'core/services/locator.dart' as sl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sl.init();

  runApp(const App());
}