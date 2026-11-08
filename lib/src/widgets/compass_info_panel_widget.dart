import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CompassInfoPanelWidget extends StatelessWidget {
  const CompassInfoPanelWidget({
    required this.position,
    required this.heading,
    required this.accuracy,
    super.key,
  });

  final LatLng position;
  final double heading;
  final double? accuracy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            const Color(0xFF00457D).withValues(alpha: 0.95),
            const Color(0xFF05051F).withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: const Color(0xFF4463D5).withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _HeadingBadge(heading: heading),
              const SizedBox(width: 12),
              Expanded(child: _CoordinatesCard(position: position)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeadingBadge extends StatelessWidget {
  const _HeadingBadge({required this.heading});

  final double heading;

  static const List<String> _directions = [
    'N',
    'NE',
    'L',
    'SE',
    'S',
    'SO',
    'O',
    'NO',
  ];

  @override
  Widget build(BuildContext context) {
    final double normalizedHeading = (heading % 360 + 360) % 360;
    final int directionIndex = ((normalizedHeading + 22.5) ~/ 45) % 8;
    final String cardinal = _directions[directionIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4463D5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_outlined, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            '${normalizedHeading.toStringAsFixed(0)}° $cardinal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinatesCard extends StatelessWidget {
  const _CoordinatesCard({required this.position});

  final LatLng position;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x15FFFFFF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coordenadas',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            '${position.latitude.toStringAsFixed(4)}, '
            '${position.longitude.toStringAsFixed(4)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}