import 'package:flutter/material.dart';
import 'package:wordpice/app/app.dart';
import 'package:wordpice/app/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(App(dependencies: dependencies));
}
