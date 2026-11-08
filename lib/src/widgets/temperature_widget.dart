import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/list_city_controller.dart';
import '../models/weather_forecast_model.dart';
import '../services/weather_service.dart';

class AracajuTemperatureWidget extends StatefulWidget {
  const AracajuTemperatureWidget({super.key});

  @override
  State<AracajuTemperatureWidget> createState() =>
      _AracajuTemperatureWidgetState();
}

class _AracajuTemperatureWidgetState extends State<AracajuTemperatureWidget> {
  WeatherForecastModel? _aracajuWeather;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAracajuWeatherIfNeeded();
  }

  Future<void> _fetchAracajuWeatherIfNeeded() async {
    final controller = context.read<ListCityController>();
    final cached = _findAracaju(controller.allCities);
    if (cached != null) {
      setState(() => _aracajuWeather = cached);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final weatherService = context.read<WeatherService>();
      final weather = await weatherService.getWeatherByCoordinates(
        -10.9111,
        -37.0717,
      );
      if (mounted) {
        setState(() {
          _aracajuWeather = weather;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  WeatherForecastModel? _findAracaju(List<WeatherForecastModel> cities) {
    for (final city in cities) {
      if (city.cityName.toLowerCase().contains('aracaju') ||
          city.city.toLowerCase().contains('aracaju')) {
        return city;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListCityController>(
      builder: (context, controller, child) {
        final weather = _findAracaju(controller.allCities) ?? _aracajuWeather;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                const Color(0xFF00457D).withValues(alpha: 0.95),
                const Color(0xFF05051F).withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4463D5).withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.thermostat,
                color: Colors.redAccent,
                size: 22,
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aracaju',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isLoading && weather == null)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Text(
                      weather != null ? '${weather.temp}°C' : '--°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
