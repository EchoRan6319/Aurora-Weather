import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pureweather/models/weather_models.dart';
import 'package:pureweather/providers/city_provider.dart';
import 'package:pureweather/providers/city_repository.dart';

Location _city(
  String id,
  String name, {
  String adm2 = 'District',
  bool isDefault = false,
  bool isLocated = false,
  int sortOrder = 0,
  double lat = 30.0,
  double lon = 120.0,
}) {
  return Location(
    id: id,
    name: name,
    adm1: 'Province',
    adm2: adm2,
    country: 'CN',
    lat: lat,
    lon: lon,
    tz: 'Asia/Shanghai',
    utcOffset: '+08:00',
    isDefault: isDefault,
    sortOrder: sortOrder,
    isLocated: isLocated,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('migrates legacy city data and normalizes duplicates/default/located', () async {
    final legacyCities = [
      _city('a', 'Alpha', adm2: 'A', sortOrder: 3).toJson(),
      _city('a', 'Alpha Dup', adm2: 'A2', sortOrder: 10).toJson(),
      _city('b', 'Beta', adm2: 'B', isDefault: true, isLocated: true, sortOrder: 9).toJson(),
      _city('c', 'Beta', adm2: 'B', sortOrder: 7).toJson(),
      _city('d', 'Delta', adm2: 'D', isDefault: true, isLocated: true, sortOrder: 1).toJson(),
    ];

    SharedPreferences.setMockInitialValues({
      'saved_cities': jsonEncode(legacyCities),
      'default_city_id': 'missing-id',
    });

    final repo = CityRepository();
    final store = await repo.loadStore();

    expect(store.cities.length, 3);
    expect(store.defaultCityId, 'b');

    final defaults = store.cities.where((c) => c.isDefault).toList();
    final located = store.cities.where((c) => c.isLocated).toList();
    expect(defaults.length, 1);
    expect(located.length, 1);
    expect(defaults.first.id, 'b');
    expect(located.first.id, 'b');
    expect(store.cities.first.id, 'b');

    expect(store.cities[0].sortOrder, 0);
    expect(store.cities[1].sortOrder, 1);
    expect(store.cities[2].sortOrder, 2);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('city_store_schema_version'), 2);
    expect(prefs.getString('city_store_v2'), isNotNull);
    expect(prefs.getString('saved_cities'), isNull);
    expect(prefs.getString('default_city_id'), isNull);
  });

  test('remove default city prefers located city as next default', () async {
    final cities = [
      _city('a', 'Alpha', adm2: 'A', isDefault: true, sortOrder: 0).toJson(),
      _city('b', 'Beta', adm2: 'B', isLocated: true, sortOrder: 1).toJson(),
      _city('c', 'Gamma', adm2: 'C', sortOrder: 2).toJson(),
    ];

    SharedPreferences.setMockInitialValues({
      'saved_cities': jsonEncode(cities),
      'default_city_id': 'a',
    });

    final controller = CityController(CityRepository());
    await controller.removeCity('a');

    expect(controller.state.length, 2);
    final nextDefault = controller.state.firstWhere((city) => city.isDefault);
    expect(nextDefault.id, 'b');
    expect(nextDefault.isLocated, isTrue);
  });

  test('addCityAndSetDefault deduplicates existing city and switches default', () async {
    final cities = [
      _city('a', 'Alpha', adm2: 'A', isDefault: true, sortOrder: 0).toJson(),
      _city('b', 'Beta', adm2: 'B', sortOrder: 1).toJson(),
    ];

    SharedPreferences.setMockInitialValues({
      'saved_cities': jsonEncode(cities),
      'default_city_id': 'a',
    });

    final controller = CityController(CityRepository());
    final duplicate = _city('b', 'Beta', adm2: 'B');
    await controller.addCityAndSetDefault(duplicate);

    expect(controller.state.length, 2);
    expect(controller.state.where((city) => city.id == 'b').length, 1);
    expect(controller.state.firstWhere((city) => city.isDefault).id, 'b');
  });

  test('normalize keeps at most one located city and keeps it at first item', () async {
    final repo = CityRepository();
    final snapshot = CityStoreSnapshot(
      cities: [
        _city('a', 'Alpha', adm2: 'A', isLocated: true, sortOrder: 0),
        _city('b', 'Beta', adm2: 'B', isDefault: true, isLocated: true, sortOrder: 1),
        _city('c', 'Gamma', adm2: 'C', isLocated: true, sortOrder: 2),
      ],
      defaultCityId: 'b',
    );

    final normalized = repo.normalize(snapshot);
    final located = normalized.cities.where((city) => city.isLocated).toList();

    expect(located.length, 1);
    expect(located.first.id, 'b');
    expect(normalized.cities.first.id, 'b');
  });

  test('remove last city is allowed and leaves an empty city list', () async {
    final cities = [
      _city('a', 'Alpha', adm2: 'A', isDefault: true, sortOrder: 0).toJson(),
    ];

    SharedPreferences.setMockInitialValues({
      'saved_cities': jsonEncode(cities),
      'default_city_id': 'a',
    });

    final controller = CityController(CityRepository());
    await controller.removeCity('a');

    expect(controller.state, isEmpty);

    final repo = CityRepository();
    final store = await repo.loadStore();
    expect(store.cities, isEmpty);
    expect(store.defaultCityId, isNull);
  });

  test('reorderCities persists and reindexes sortOrder', () async {
    final cities = [
      _city('a', 'Alpha', adm2: 'A', isDefault: true, sortOrder: 0).toJson(),
      _city('b', 'Beta', adm2: 'B', sortOrder: 1).toJson(),
      _city('c', 'Gamma', adm2: 'C', sortOrder: 2).toJson(),
    ];

    SharedPreferences.setMockInitialValues({
      'saved_cities': jsonEncode(cities),
      'default_city_id': 'a',
    });

    final controller = CityController(CityRepository());
    await controller.reorderCities(2, 0);

    expect(controller.state.map((city) => city.id).toList(), ['c', 'a', 'b']);
    expect(controller.state.map((city) => city.sortOrder).toList(), [0, 1, 2]);
  });
}
