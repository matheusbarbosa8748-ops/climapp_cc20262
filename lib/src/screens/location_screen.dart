import 'package:climapp_cc20262/src/screens/list_city_screen.dart';
import 'package:climapp_cc20262/src/services/location_service.dart';
import 'package:flutter/material.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({required this.locationService, super.key});

  final LocationService locationService;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

enum _LocationScreenStateKind {
  loading,
  permissionDenied,
  serviceDisabled,
  error,
  ready,
}

class _LocationScreenState extends State<LocationScreen> {
  _LocationScreenStateKind _state = _LocationScreenStateKind.loading;
  LocationDetails? _location;
  bool _permanentlyDenied = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _state = _LocationScreenStateKind.loading;
      _errorMessage = '';
    });

    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _location = location;
        _state = _LocationScreenStateKind.ready;
      });
    } on LocationPermissionDeniedException catch (error) {
      if (!mounted) return;
      setState(() {
        _permanentlyDenied = error.permanentlyDenied;
        _state = _LocationScreenStateKind.permissionDenied;
      });
    } on LocationServiceDisabledException {
      if (!mounted) return;
      setState(() => _state = _LocationScreenStateKind.serviceDisabled);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _state = _LocationScreenStateKind.error;
      });
    }
  }

  Future<void> _openLocationSettings() async {
    await widget.locationService.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await widget.locationService.openAppSettings();
  }

  void _continueToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ListCityScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF00457D), Color(0xFF05051F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_state) {
      _LocationScreenStateKind.loading => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Obtendo sua localização...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      _LocationScreenStateKind.permissionDenied => _buildMessage(
        icon: Icons.location_disabled,
        message:
            'A localização é necessária para identificar sua cidade e país.',
        actions: [
          if (_permanentlyDenied)
            OutlinedButton(
              onPressed: _openAppSettings,
              child: const Text('Abrir configurações do app'),
            ),
          ElevatedButton(
            onPressed: _loadLocation,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
      _LocationScreenStateKind.serviceDisabled => _buildMessage(
        icon: Icons.location_off,
        message: 'A localização está desativada no aparelho.',
        actions: [
          ElevatedButton(
            onPressed: _openLocationSettings,
            child: const Text('Abrir configurações de localização'),
          ),
          TextButton(
            onPressed: _loadLocation,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
      _LocationScreenStateKind.error => _buildMessage(
        icon: Icons.error_outline,
        message:
            'Não foi possível obter sua localização. Tente novamente.\n'
            '$_errorMessage',
        actions: [
          ElevatedButton(
            onPressed: _loadLocation,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
      _LocationScreenStateKind.ready => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 56),
          const SizedBox(height: 16),
          Text(
            '📍 ${_location!.city}, ${_location!.country}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Latitude: ${_location!.latitude}, '
            'Longitude: ${_location!.longitude}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _continueToApp,
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    };
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    required List<Widget> actions,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 56),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 20),
        ...actions.map(
          (action) =>
              Padding(padding: const EdgeInsets.only(top: 8), child: action),
        ),
      ],
    );
  }
}
