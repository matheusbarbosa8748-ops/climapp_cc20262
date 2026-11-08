import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';
import '../widgets/compass_info_panel_widget.dart';
import '../widgets/compass_status_widgets.dart';
import '../widgets/compass_user_marker_widget.dart';
import '../widgets/floating_compass_widget.dart';

class CompassMapScreen extends StatefulWidget {
  const CompassMapScreen({super.key});

  @override
  State<CompassMapScreen> createState() => _CompassMapScreenState();
}

class _CompassMapScreenState extends State<CompassMapScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(
          location.latitude,
          location.longitude,
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _recenterMap() {
    final position = _currentPosition;
    if (position != null) {
      _mapController.move(position, 16.0);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = _currentPosition;

    return Scaffold(
      backgroundColor: const Color(0xFF05051F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00457D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Navegação e Sensores',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (position != null && !_isLoading)
            IconButton(
              onPressed: _recenterMap,
              tooltip: 'Centralizar na minha localização',
              icon: const Icon(Icons.my_location, color: Colors.white),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF00457D), Color(0xFF05051F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const CompassLoadingWidget()
            : _errorMessage != null
            ? CompassErrorWidget(
          errorMessage: _errorMessage!,
          onRetry: _loadLocation,
        )
            : _CompassMapView(
          mapController: _mapController,
          currentPosition: position!,
        ),
      ),
    );
  }
}

class _CompassMapView extends StatelessWidget {
  const _CompassMapView({
    required this.mapController,
    required this.currentPosition,
  });

  final MapController mapController;
  final LatLng currentPosition;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final double heading = snapshot.data?.heading ?? 0.0;
        final double? accuracy = snapshot.data?.accuracy;

        return Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentPosition,
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.dev.yago.climapp_cc20262',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPosition,
                      width: 60,
                      height: 60,
                      child: CompassUserMarkerWidget(heading: heading),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingCompassWidget(heading: heading),
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: CompassInfoPanelWidget(
                position: currentPosition,
                heading: heading,
                accuracy: accuracy,
              ),
            ),
          ],
        );
      },
    );
  }
}