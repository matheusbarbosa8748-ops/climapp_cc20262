class ForecastModel {
  final String date;
  final String weekday;
  final int max;
  final int min;
  final int humidity;
  final double cloudiness;
  final double rain;
  final int rainProbability;
  final String windSpeedy;
  final String sunrise;
  final String sunset;
  final String moonPhase;
  final String description;
  final String condition;

  ForecastModel({
    required this.date,
    required this.weekday,
    required this.max,
    required this.min,
    required this.humidity,
    required this.cloudiness,
    required this.rain,
    required this.rainProbability,
    required this.windSpeedy,
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
    required this.description,
    required this.condition,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'weekday': weekday,
      'max': max,
      'min': min,
      'humidity': humidity,
      'cloudiness': cloudiness,
      'rain': rain,
      'rain_probability': rainProbability,
      'wind_speedy': windSpeedy,
      'sunrise': sunrise,
      'sunset': sunset,
      'moon_phase': moonPhase,
      'description': description,
      'condition': condition,
    };
  }

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: json['date'] as String? ?? '',
      weekday: json['weekday'] as String? ?? '',
      max: (json['max'] as num?)?.toInt() ?? 0,
      min: (json['min'] as num?)?.toInt() ?? 0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      cloudiness: (json['cloudiness'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
      rainProbability: (json['rain_probability'] as num?)?.toInt() ?? 0,
      windSpeedy: json['wind_speedy'] as String? ?? '',
      sunrise: json['sunrise'] as String? ?? '',
      sunset: json['sunset'] as String? ?? '',
      moonPhase: json['moon_phase'] as String? ?? '',
      description: json['description'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
    );
  }
}
