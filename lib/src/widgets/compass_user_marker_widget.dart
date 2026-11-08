import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompassUserMarkerWidget extends StatelessWidget {
  const CompassUserMarkerWidget({
    required this.heading,
    super.key,
  });

  final double heading;

  @override
  Widget build(BuildContext context) {
    final double headingRadians = heading * (math.pi / 180);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF4463D5).withValues(alpha: 0.25),
        border: Border.all(
          color: const Color(0xFF4463D5).withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF05051F),
            border: Border.all(
              color: const Color(0xFF7693FF),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: headingRadians,
            child: const Icon(
              Icons.navigation,
              color: Color(0xFF7693FF),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
