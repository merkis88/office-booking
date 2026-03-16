import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wordpice/app/app_dependencies.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/theme/app_theme.dart';
import 'package:wordpice/features/profile/presentation/screens/profile_screen.dart';
import 'package:wordpice/features/rentals/presentation/screens/rentals_screen.dart';
import 'package:wordpice/features/splash/presentation/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    this.dependencies,
  });

  final AppDependencies? dependencies;

  @override
  Widget build(BuildContext context) {
    if (dependencies == null) {
      return FutureBuilder<AppDependencies>(
        future: AppDependencies.create(),
        builder: (context, snapshot) {
          final deps = snapshot.data;
          if (deps == null) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return _AppView(dependencies: deps);
        },
      );
    }

    return _AppView(dependencies: dependencies!);
  }
}

class _AppView extends StatelessWidget {
  const _AppView({required this.dependencies});

  final AppDependencies? dependencies;

  @override
  Widget build(BuildContext context) {
    final deps = dependencies;
    if (deps == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

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
