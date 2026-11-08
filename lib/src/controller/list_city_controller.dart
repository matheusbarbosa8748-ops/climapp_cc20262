import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:climapp_cc20262/src/models/city_local_entity.dart';
import 'package:climapp_cc20262/src/models/weather_forecast_model.dart';
import 'package:climapp_cc20262/src/services/device_info_service.dart';
import 'package:climapp_cc20262/src/services/weather_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:climapp_cc20262/src/database/city_local_repository.dart';

class ListCityController extends ChangeNotifier {
  ListCityController({
    required this.deviceInfoService,
    required this.weatherService,
    required this.localRepository,
  }) {
    _initConnectivityListener();
  }

  final WeatherService weatherService;
  final DeviceInfoService deviceInfoService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final CityLocalRepository localRepository;
  // Flag opcional para a UI saber se está exibindo dados em cache/offline
  bool isOfflineMode = false;
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
    isOfflineMode = false;
    notifyListeners();

    _deviceCountry = await deviceInfoService.getDeviceCountry();

    try {
      // 1. Fluxo Online: Requisição à API remota
      allCities = await weatherService.getWeatherForecast(listCitySearch);
      filteredCities = List.from(allCities);
      // Após o sucesso do download, salvamos os dados localmente no SQLite
      final entities = allCities
          .map(
            (item) => CityLocalEntity(
              name: item.cityName,
              state: item.city.contains(',')
                  ? item.city.split(',').last.trim()
                  : '',
              temp: item.temp.toDouble(),
              description: item.description,
              updatedAt: DateTime.now().toIso8601String(),
            ),
          )
          .toList();

      await localRepository.saveAllCities(entities);
    } on TimeoutException catch (e) {
      errorMessage =
          e.message ?? 'Tempo limite de conexão excedido. Tente novamente.';
    } on SocketException catch (_) {
      errorMessage =
      'Sem conexão com a internet. Exibindo dados locais salvos.';
      await _tryLoadFromCache();
    } on http.ClientException catch (_) {
      errorMessage =
      'Falha de comunicação com a rede. Verifique sua internet.';
    } on HttpException catch (e) {
      debugPrint('====================================');
      errorMessage = e.message;
      debugPrint(errorMessage);
      debugPrint('====================================');
      await _tryLoadFromCache();
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados. Tente novamente.';
      debugPrint('Erro ao carregar cidades: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Tenta resgatar as previsões persistidas localmente caso a conexão falhe
  Future<void> _tryLoadFromCache() async {
    final cachedData = await localRepository.getAllCities();

    if (cachedData.isNotEmpty) {
      // Converte as entidades persistidas do banco para a lista consumida pela UI
      allCities = cachedData
          .map(
            (cached) => WeatherForecastModel(
              cityName: cached.name,
              city: '${cached.name}, ${cached.state}',
              temp: cached.temp?.toInt() ?? 0,
              description: cached.description ?? 'Sem dados',
              date: '',
              time: '',
              conditionCode: '',
              currently: '',
              imgId: '',
              humidity: 0,
              cloudiness: 0.0,
              rain: 0.0,
              windSpeedy: '',
              windDirection: 0,
              windCardinal: '',
              sunrise: '',
              sunset: '',
              moonPhase: '',
              conditionSlug: '',
              timezone: '',
              forecast: [],
            ),
          )
          .toList();

      filteredCities = List.from(allCities);
      isOfflineMode = true;
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
