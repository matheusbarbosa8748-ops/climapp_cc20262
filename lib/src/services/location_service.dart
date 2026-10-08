import 'package:geocoding/geocoding.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationDetails {
  const LocationDetails({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String city;
  final String country;
  final double latitude;
  final double longitude;
}

class LocationServiceDisabledException implements Exception {}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException({required this.permanentlyDenied});

  final bool permanentlyDenied;
}

class LocationService {
  static const _cityKey = 'location_city';
  static const _countryKey = 'location_country';
  static const _latitudeKey = 'location_latitude';
  static const _longitudeKey = 'location_longitude';

  late final Geocoding _geocoding = Geocoding(
    locale: const Locale('pt', 'BR'),
  );

  Future<LocationDetails> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine ||
        permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedException(
        permanentlyDenied: permission == LocationPermission.deniedForever,
      );
    }

    final position = await Geolocator.getCurrentPosition();
    final placemarks = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) {
      throw StateError('Não foi possível identificar esta localização.');
    }

    final placemark = placemarks.first;
    final city = placemark.locality?.trim().isNotEmpty == true
        ? placemark.locality!.trim()
        : placemark.subAdministrativeArea?.trim().isNotEmpty == true
        ? placemark.subAdministrativeArea!.trim()
        : placemark.administrativeArea?.trim() ?? '';
    final country = placemark.country?.trim() ?? '';

    if (city.isEmpty || country.isEmpty) {
      throw StateError('Não foi possível identificar a cidade e o país.');
    }

    final details = LocationDetails(
      city: city,
      country: country,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    await _saveLocation(details);
    return details;
  }

  Future<LocationDetails?> getSavedLocation() async {
    final preferences = await SharedPreferences.getInstance();
    final city = preferences.getString(_cityKey);
    final country = preferences.getString(_countryKey);
    final latitude = preferences.getDouble(_latitudeKey);
    final longitude = preferences.getDouble(_longitudeKey);

    if (city == null ||
        country == null ||
        latitude == null ||
        longitude == null) {
      return null;
    }

    return LocationDetails(
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> _saveLocation(LocationDetails details) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cityKey, details.city);
    await preferences.setString(_countryKey, details.country);
    await preferences.setDouble(_latitudeKey, details.latitude);
    await preferences.setDouble(_longitudeKey, details.longitude);
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
