import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_models.dart';

@immutable
class CityStoreSnapshot {
  final List<Location> cities;
  final String? defaultCityId;
  final int schemaVersion;

  const CityStoreSnapshot({
    required this.cities,
    required this.defaultCityId,
    this.schemaVersion = CityRepository.currentSchemaVersion,
  });
}

class CityRepository {
  static const int currentSchemaVersion = 2;

  static const String _storeKey = 'city_store_v2';
  static const String _schemaKey = 'city_store_schema_version';
  static const String _legacyCitiesKey = 'saved_cities';
  static const String _legacyDefaultCityKey = 'default_city_id';

  Future<CityStoreSnapshot> loadStore() async {
    final prefs = await SharedPreferences.getInstance();
    final schemaVersion = prefs.getInt(_schemaKey);

    if (schemaVersion == currentSchemaVersion) {
      final fromNewStore = _readNewStore(prefs);
      if (fromNewStore != null) {
        final normalized = normalize(fromNewStore);
        if (!_sameCities(normalized.cities, fromNewStore.cities) ||
            normalized.defaultCityId != fromNewStore.defaultCityId) {
          await saveStore(normalized);
        }
        return normalized;
      }
    }

    final migrated = normalize(_readLegacyStore(prefs));
    await saveStore(migrated);
    await _cleanupLegacyKeys(prefs);
    return migrated;
  }

  Future<void> saveStore(CityStoreSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = normalize(snapshot);

    final payload = jsonEncode({
      'version': currentSchemaVersion,
      'defaultCityId': normalized.defaultCityId,
      'cities': normalized.cities.map((e) => e.toJson()).toList(),
    });

    await prefs.setString(_storeKey, payload);
    await prefs.setInt(_schemaKey, currentSchemaVersion);
  }

  CityStoreSnapshot normalize(CityStoreSnapshot snapshot) {
    final deduped = <Location>[];
    final seenIds = <String>{};
    final seenNameAdmin = <String>{};

    for (final city in snapshot.cities) {
      final idKey = city.id.trim();
      final compositeKey = '${city.name.toLowerCase()}|${city.adm2.toLowerCase()}|${city.adm1.toLowerCase()}';
      if (seenIds.contains(idKey) || seenNameAdmin.contains(compositeKey)) {
        continue;
      }
      seenIds.add(idKey);
      seenNameAdmin.add(compositeKey);
      deduped.add(city);
    }

    if (deduped.isEmpty) {
      return const CityStoreSnapshot(cities: [], defaultCityId: null);
    }

    String? defaultCityId = snapshot.defaultCityId;
    if (defaultCityId == null || !deduped.any((c) => c.id == defaultCityId)) {
      final flaggedDefault = deduped.where((c) => c.isDefault).toList();
      if (flaggedDefault.isNotEmpty) {
        defaultCityId = flaggedDefault.first.id;
      }
    }

    final locatedCities = deduped.where((c) => c.isLocated).toList();
    String? locatedCityId;
    if (locatedCities.isNotEmpty) {
      if (defaultCityId != null &&
          locatedCities.any((city) => city.id == defaultCityId)) {
        locatedCityId = defaultCityId;
      } else {
        locatedCityId = locatedCities.first.id;
      }
    }

    if (defaultCityId == null || !deduped.any((c) => c.id == defaultCityId)) {
      defaultCityId = locatedCityId ?? deduped.first.id;
    }

    var normalized = deduped
        .map(
          (city) => city.copyWith(
            isDefault: city.id == defaultCityId,
            isLocated: locatedCityId != null && city.id == locatedCityId,
          ),
        )
        .toList();

    if (locatedCityId != null) {
      final locatedIndex = normalized.indexWhere((city) => city.id == locatedCityId);
      if (locatedIndex > 0) {
        final located = normalized.removeAt(locatedIndex);
        normalized.insert(0, located);
      }
    }

    normalized = normalized
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(sortOrder: entry.key))
        .toList();

    return CityStoreSnapshot(
      cities: normalized,
      defaultCityId: defaultCityId,
      schemaVersion: currentSchemaVersion,
    );
  }

  Future<List<Location>> loadCities() async {
    final store = await loadStore();
    return store.cities;
  }

  CityStoreSnapshot? _readNewStore(SharedPreferences prefs) {
    final raw = prefs.getString(_storeKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final citiesRaw = (decoded['cities'] as List<dynamic>? ?? const <dynamic>[]);
      final cities = citiesRaw
          .whereType<Map<String, dynamic>>()
          .map(Location.fromJson)
          .toList();
      final defaultCityId = decoded['defaultCityId'] as String?;
      final version = (decoded['version'] as int?) ?? currentSchemaVersion;
      return CityStoreSnapshot(
        cities: cities,
        defaultCityId: defaultCityId,
        schemaVersion: version,
      );
    } catch (_) {
      return null;
    }
  }

  CityStoreSnapshot _readLegacyStore(SharedPreferences prefs) {
    final citiesJson = prefs.getString(_legacyCitiesKey);
    if (citiesJson == null || citiesJson.isEmpty) {
      return const CityStoreSnapshot(cities: [], defaultCityId: null);
    }

    try {
      final decoded = jsonDecode(citiesJson) as List<dynamic>;
      final cities = decoded
          .whereType<Map<String, dynamic>>()
          .map(Location.fromJson)
          .toList();
      final defaultCityId = prefs.getString(_legacyDefaultCityKey);
      return CityStoreSnapshot(
        cities: cities,
        defaultCityId: defaultCityId,
        schemaVersion: 1,
      );
    } catch (_) {
      return const CityStoreSnapshot(cities: [], defaultCityId: null);
    }
  }

  Future<void> _cleanupLegacyKeys(SharedPreferences prefs) async {
    await prefs.remove(_legacyCitiesKey);
    await prefs.remove(_legacyDefaultCityKey);
  }

  bool _sameCities(List<Location> a, List<Location> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
