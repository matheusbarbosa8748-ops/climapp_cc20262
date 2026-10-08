import 'dart:async';
import 'dart:io';

import 'package:climapp_cc20262/src/models/weather_forecast_model.dart';
import 'package:climapp_cc20262/src/services/device_info_service.dart';
import 'package:climapp_cc20262/src/services/weather_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListCityController extends ChangeNotifier {
  ListCityController({
    required this.deviceInfoService,
    required this.weatherService,
  }) {
    _initConnectivityListener();
  }

  final WeatherService weatherService;
  final DeviceInfoService deviceInfoService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  String _deviceCountry = '';
  String get deviceCountry => _deviceCountry;
  List<WeatherForecastModel> allCities = [];
  List<WeatherForecastModel> filteredCities = [];
  bool isLoading = true;
  String errorMessage = '';

  final listCitySearch = [
    'Aracaju,SE',
    'Itabaiana,SE',
    'Carira,SE',
    'Xique-Xique,BA',
  ];

  Future<void> loadCities() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    _deviceCountry = await deviceInfoService.getDeviceCountry();

    try {
      allCities = await weatherService.getWeatherForecast(listCitySearch);
      filteredCities = List.from(allCities);
    } on TimeoutException catch (e) {
      errorMessage =
          e.message ?? 'Tempo limite de conexão excedido. Tente novamente.';
    } on SocketException catch (_) {
      errorMessage = 'Sem conexão com a internet. Verifique sua rede.';
    } on http.ClientException catch (_) {
      errorMessage = 'Falha de comunicação com a rede. Verifique sua internet.';
    } on HttpException catch (e) {
      debugPrint('====================================');
      errorMessage = e.message;
      debugPrint(errorMessage);
      debugPrint('====================================');
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados. Tente novamente.';
      debugPrint('Erro ao carregar cidades: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterCities(String query) {
    if (query.isEmpty) {
      filteredCities = List.from(allCities);
    } else {
      filteredCities = allCities
          .where(
            (city) => city.cityName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final isOffline =
          results.contains(ConnectivityResult.none) || results.isEmpty;
      if (isOffline) {
        errorMessage = 'Sem conexão com a internet. Verifique sua rede.';
        notifyListeners();
      } else if (errorMessage.isNotEmpty && !isLoading) {
        loadCities();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
