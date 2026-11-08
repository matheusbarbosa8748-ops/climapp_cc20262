import 'package:climapp_cc20262/src/models/city_local_entity.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class CityLocalRepository {
  final AppDatabase _dbProvider;

  CityLocalRepository({AppDatabase? dbProvider})
    : _dbProvider = dbProvider ?? AppDatabase.instance;

  // Inserção ou atualização em caso de conflito (Upsert)
  Future<void> saveCity(CityLocalEntity city) async {
    final db = await _dbProvider.database;
    await db.insert(
      'cached_cities',
      city.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Batch insert para persistir listas com alto desempenho
  Future<void> saveAllCities(List<CityLocalEntity> cities) async {
    final db = await _dbProvider.database;
    final batch = db.batch();
    for (final city in cities) {
      batch.insert(
        'cached_cities',
        city.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Busca todas as cidades salvas para renderização offline
  Future<List<CityLocalEntity>> getAllCities() async {
    final db = await _dbProvider.database;
    final result = await db.query('cached_cities', orderBy: 'name ASC');
    return result.map((map) => CityLocalEntity.fromMap(map)).toList();
  }

  // Deleta registros inválidos ou fallbacks indesejados (como 'São Paulo' ou 'não definida')
  Future<int> deleteInvalidCities() async {
    final db = await _dbProvider.database;
    return await db.delete(
      'cached_cities',
      where: "LOWER(name) = ? OR LOWER(name) LIKE ? OR LOWER(state) LIKE ?",
      whereArgs: ['são paulo', '%não definida%', '%não definida%'],
    );
  }

  // Limpeza de cache antigo se necessário
  Future<int> clearCache() async {
    final db = await _dbProvider.database;
    return await db.delete('cached_cities');
  }
}
