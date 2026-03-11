import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wordpice/app/app_dependencies.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/theme/app_theme.dart';
import 'package:wordpice/features/splash/presentation/screens/splash_screen.dart';
import 'package:wordpice/features/profile/presentation/screens/profile_screen.dart';
import 'package:wordpice/features/rentals/presentation/screens/rentals_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.create();

    return AppScope(
      dependencies: deps,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('ru', 'RU'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru', 'RU')],
        home: const SplashScreen(),
        routes: {
          '/profile': (_) => const ProfileScreen(),
          '/rentals': (_) => const RentalsScreen(),
        },
      ),
    );
  }
}
