class CityLocalEntity {
  final int? id;
  final String name;
  final String state;
  final double? temp;
  final String? description;
  final String updatedAt;

  CityLocalEntity({
    this.id,
    required this.name,
    required this.state,
    this.temp,
    this.description,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'temp': temp,
      'description': description,
      'updated_at': updatedAt,
    };
  }

  factory CityLocalEntity.fromMap(Map<String, dynamic> map) {
    return CityLocalEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      state: map['state'] as String,
      temp: (map['temp'] as num?)?.toDouble(),
      description: map['description'] as String?,
      updatedAt: map['updated_at'] as String,
    );
  }
}
