import 'forecast_model.dart';

class WeatherForecastModel {
  final int temp;
  final String date;
  final String time;
  final String conditionCode;
  final String description;
  final String currently;
  final String city;
  final String imgId;
  final int humidity;
  final double cloudiness;
  final double rain;
  final String windSpeedy;
  final int windDirection;
  final String windCardinal;
  final String sunrise;
  final String sunset;
  final String moonPhase;
  final String conditionSlug;
  final String cityName;
  final String timezone;
  final List<ForecastModel> forecast;

  WeatherForecastModel({
    required this.temp,
    required this.date,
    required this.time,
    required this.conditionCode,
    required this.description,
    required this.currently,
    required this.city,
    required this.imgId,
    required this.humidity,
    required this.cloudiness,
    required this.rain,
    required this.windSpeedy,
    required this.windDirection,
    required this.windCardinal,
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
    required this.conditionSlug,
    required this.cityName,
    required this.timezone,
    required this.forecast,
  });

  Map<String, dynamic> toMap() {
    return {
      'temp': temp,
      'date': date,
      'time': time,
      'condition_code': conditionCode,
      'description': description,
      'currently': currently,
      'city': city,
      'img_id': imgId,
      'humidity': humidity,
      'cloudiness': cloudiness,
      'rain': rain,
      'wind_speedy': windSpeedy,
      'wind_direction': windDirection,
      'wind_cardinal': windCardinal,
      'sunrise': sunrise,
      'sunset': sunset,
      'moon_phase': moonPhase,
      'condition_slug': conditionSlug,
      'city_name': cityName,
      'timezone': timezone,
      'forecast': forecast.map((item) => item.toMap()).toList(),
    };
  }

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return WeatherForecastModel(
      temp: (json['temp'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      conditionCode: json['condition_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      currently: json['currently'] as String? ?? '',
      city: json['city'] as String? ?? '',
      imgId: json['img_id']?.toString() ?? '',
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      cloudiness: (json['cloudiness'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
      windSpeedy: json['wind_speedy'] as String? ?? '',
      windDirection: (json['wind_direction'] as num?)?.toInt() ?? 0,
      windCardinal: json['wind_cardinal'] as String? ?? '',
      sunrise: json['sunrise'] as String? ?? '',
      sunset: json['sunset'] as String? ?? '',
      moonPhase: json['moon_phase'] as String? ?? '',
      conditionSlug: json['condition_slug'] as String? ?? '',
      cityName: json['city_name'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      forecast: (json['forecast'] as List?)
              ?.map((item) => ForecastModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
