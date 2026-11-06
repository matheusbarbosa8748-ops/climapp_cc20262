import 'dart:async';
import 'dart:io';

import 'package:climapp_cc20262/src/models/city_local_entity.dart';
import 'package:climapp_cc20262/src/models/weather_forecast_model.dart';
import 'package:climapp_cc20262/src/services/device_info_service.dart';
import 'package:climapp_cc20262/src/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:climapp_cc20262/src/database/city_local_repository.dart';

class ListCityController extends ChangeNotifier {
  ListCityController({
    required this.deviceInfoService,
    required this.weatherService,
    required this.localRepository,
  });

  final WeatherService weatherService;
  final DeviceInfoService deviceInfoService;

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
    'Salvador,BA',
    'Curitiba,PR',
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
          e.message ?? 'Deu ruim nas internet, vá botar crédito seu pobre';
      await _tryLoadFromCache();
    } on HttpException catch (e) {
      debugPrint('====================================');
      errorMessage = e.message;
      debugPrint(errorMessage);
      debugPrint('====================================');
      await _tryLoadFromCache();
    } on SocketException catch (_) {
      // Falha comum sem conexão de rede/Wi-Fi desativado
      errorMessage =
          'Sem conexão com a internet. Exibindo dados locais salvos.';
      await _tryLoadFromCache();
    } catch (e) {
      debugPrint(e.toString());
      await _tryLoadFromCache();
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
}
