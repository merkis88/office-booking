import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpice/app/app.dart';
import 'package:wordpice/app/app_dependencies.dart';
import 'package:wordpice/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    final dependencies = await AppDependencies.create();
    await tester.pumpWidget(App(dependencies: dependencies));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
