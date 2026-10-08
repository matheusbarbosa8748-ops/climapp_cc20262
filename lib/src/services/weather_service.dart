import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:climapp_cc20262/src/enums/enviroments_enum.dart';
import 'package:climapp_cc20262/src/models/weather_forecast_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<List<WeatherForecastModel>> getWeatherForecast(
    List<String> listCitySearch,
  ) async {
    final enumEnv = EnvironmentEnum.constants;

    final requests = listCitySearch.map((city) async {
      final uri =
          '${enumEnv.apiBaseUrl}?key=${enumEnv.apiKey}&city_name=$city';
      final response = await http
          .get(Uri.parse(uri))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException(
                'Tempo limite de conexão excedido. Verifique sua internet.',
              );
            },
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonDecoded = jsonDecode(response.body)['results'];
        return WeatherForecastModel.fromJson(jsonDecoded);
      } else {
        throw HttpException(
          'Falha na consulta meteorológica (Código: ${response.statusCode}).',
        );
      }
    });

    return await Future.wait(requests);
  }
}
