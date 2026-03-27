import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/features/auth/presentation/screens/auth_screen.dart';
import 'package:wordpice/features/profile/presentation/screens/profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _interval = Duration(seconds: 2);
  static const _letterInterval = Duration(milliseconds: 300);
  static const _startDelay = Duration(milliseconds: 900);
  static const _logoText = 'Рабочая точка.';
  static const _logoAsset = 'assets/images/logo/app_logo.png';

  final List<String> _allPhrases = const [
    'Вы красивы',
    'Всё получится',
    'Вы справитесь',
    'День удачный',
    'Мы рядом',
    'Смело вперёд',
    'Время действовать',
    'Дышите глубже',
  ];

  late final List<String> _selected3;
  int _index = 0;
  Timer? _timer;
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();

    _selected3 = _pick3RandomUnique(_allPhrases);
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: _logoText.length * _letterInterval.inMilliseconds,
      ),
    )..value = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Future.delayed(_startDelay, () {
        if (!mounted) {
          return;
        }
        _logoController.forward(from: 0);
      });
    });

    _timer = Timer.periodic(_interval, (_) {
      if (!mounted) {
        return;
      }
      setState(() => _index = (_index + 1) % _selected3.length);
    });

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _timer?.cancel();
        _goNext();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoController.dispose();
    super.dispose();
  }

  List<String> _pick3RandomUnique(List<String> source) {
    final copy = List<String>.from(source);
    copy.shuffle(Random());
    return copy.take(3).toList();
  }

  void _goNext() {
    final nextPage = AppScope.of(context).appSession.isAuthenticated
        ? const ProfileScreen()
        : const AuthScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        reverseTransitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (_, _, _) => nextPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _selected3[_index];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Hero(
                    tag: 'app_logo',
                    child: Material(
                      type: MaterialType.transparency,
                      child: _AnimatedLogo(
                        controller: _logoController,
                        text: _logoText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    phrase,
                    key: ValueKey(phrase),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.controller,
    required this.text,
  });

  final AnimationController controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    final letters = text.split('');
    final total = letters.length;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final imageProgress = Curves.easeOutCubic.transform(
          controller.value.clamp(0, 1).toDouble(),
        );
        final imageOffsetY = (1 - imageProgress) * 12;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: imageProgress,
              child: Transform.translate(
                offset: Offset(0, imageOffsetY),
                child: Image.asset(
                  _SplashScreenState._logoAsset,
                  width: 116,
                  height: 116,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(total, (index) {
                final start = index / total;
                final end = (index + 1) / total;
                final t = ((controller.value - start) / (end - start))
                    .clamp(0, 1)
                    .toDouble();
                final opacity = Curves.easeOut.transform(t);
                final dy = (1 - opacity) * 6;

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, dy),
                    child: Text(
                      letters[index],
                      style: const TextStyle(
                        fontFamily: 'SpectralSC',
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
