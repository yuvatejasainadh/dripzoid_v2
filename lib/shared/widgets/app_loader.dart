import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _dotSize = 6;
  static const double _spacing = 10;
  static const double _orbitRadius = 10;

  // Timeline
  static const double _shuffleEnd = 0.30;
  static const double _swingEnd = 0.60;
  static const double _orbitEnd = 0.90;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  Offset _shuffle(double p, int index) {
    final shift =
        math.sin(
          p * 2 * math.pi +
              index * (2 * math.pi / 3),
        ) *
            _spacing;

    return Offset(shift, 0);
  }

  Offset _swing(double p, int index) {
    final phase = index * 0.9;

    return Offset(
      math.sin(p * math.pi + phase) * 14,
      math.cos(p * math.pi * 2 + phase) * 6,
    );
  }

  Offset _orbit(double p, int index) {
    final angle =
        p * 2 * math.pi +
            index * (2 * math.pi / 3);

    return Offset(
      _orbitRadius * math.cos(angle),
      _orbitRadius * math.sin(angle),
    );
  }

  Offset _position(double t, int index) {
    // -----------------------
    // Shuffle
    // -----------------------
    if (t < _shuffleEnd) {
      final p = t / _shuffleEnd;
      return _shuffle(p, index);
    }

    // -----------------------
    // Blend Shuffle -> Swing
    // -----------------------
    if (t < _shuffleEnd + 0.05) {
      final blend = Curves.easeInOut.transform(
        (t - _shuffleEnd) / 0.05,
      );

      return Offset.lerp(
        _shuffle(1, index),
        _swing(0, index),
        blend,
      )!;
    }

    // -----------------------
    // Swing
    // -----------------------
    if (t < _swingEnd) {
      final p =
          (t - (_shuffleEnd + 0.05)) /
              (_swingEnd - (_shuffleEnd + 0.05));

      return _swing(p, index);
    }

    // -----------------------
    // Blend Swing -> Orbit
    // -----------------------
    if (t < _swingEnd + 0.05) {
      final blend = Curves.easeInOut.transform(
        (t - _swingEnd) / 0.05,
      );

      return Offset.lerp(
        _swing(1, index),
        _orbit(0, index),
        blend,
      )!;
    }

    // -----------------------
    // Orbit
    // -----------------------
    if (t < _orbitEnd) {
      final p =
          (t - (_swingEnd + 0.05)) /
              (_orbitEnd - (_swingEnd + 0.05));

      return _orbit(p, index);
    }

    // -----------------------
    // Blend Orbit -> Shuffle
    // -----------------------
    final blend = Curves.easeInOut.transform(
      (t - _orbitEnd) / (1 - _orbitEnd),
    );

    return Offset.lerp(
      _orbit(1, index),
      _shuffle(0, index),
      blend,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 44,
      height: 44,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_,_) {
          final t =
          Curves.easeInOutSine.transform(_controller.value);

          return Stack(
            children: List.generate(3, (index) {
              final pos = _position(t, index);

              return Positioned(
                left: 22 + pos.dx - _dotSize / 2,
                top: 22 + pos.dy - _dotSize / 2,
                child: Container(
                  width: _dotSize,
                  height: _dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}