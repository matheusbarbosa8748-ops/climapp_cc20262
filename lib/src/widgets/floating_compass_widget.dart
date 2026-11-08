import 'dart:math' as math;

import 'package:flutter/material.dart';

class FloatingCompassWidget extends StatelessWidget {
  const FloatingCompassWidget({
    required this.heading,
    super.key,
  });

  final double heading;

  @override
  Widget build(BuildContext context) {
    final double headingRadians = heading * (math.pi / 180);

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF00457D), Color(0xFF05051F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF7693FF).withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'N',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Transform.rotate(
            angle: -headingRadians,
            child: const Icon(
              Icons.explore,
              size: 44,
              color: Color(0xFF7693FF),
            ),
          ),
        ],
      ),
    );
  }
}
