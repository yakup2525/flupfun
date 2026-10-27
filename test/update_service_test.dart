import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flupfun/services/update_service.dart';

class OfflineHttp extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => throw const SocketException('Offline QA');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storage;
  setUp(() async {
    storage = await Directory.systemTemp.createTemp('flup-update-test');
    Hive.init(storage.path);
    HttpOverrides.global = OfflineHttp();
  });
  tearDown(() async {
    HttpOverrides.global = null;
    await Hive.close();
    await storage.delete(recursive: true);
  });
  test('cached mandatory policy stays enforced when offline', () async {
    final box = await Hive.openBox<String>('update-policy');
    await box.put('minimumSupportedVersion', '1.2.0');
    final service = UpdateService()..installedVersion = '1.1.8';
    await service.check();
    expect(service.required, isTrue);
    expect(service.checking, isFalse);
  });
  test('offline first launch remains usable with no policy', () async {
    final service = UpdateService()..installedVersion = '1.1.8';
    await service.check();
    expect(service.required, isFalse);
    expect(service.checking, isFalse);
  });
  test('corrupt cached policy cannot crash or block startup', () async {
    final box = await Hive.openBox<String>('update-policy');
    await box.put('minimumSupportedVersion', 'invalid');
    final service = UpdateService()..installedVersion = '1.1.8';
    await service.check();
    expect(service.required, isFalse);
    expect(box.get('minimumSupportedVersion'), isNull);
  });
  test('below minimum blocks; equal and above allow', () {
    final service = UpdateService()..minimumVersion = '1.1.8';
    service.installedVersion = '1.1.7';
    expect(service.required, isTrue);
    service.installedVersion = '1.1.8';
    expect(service.required, isFalse);
    service.installedVersion = '1.1.10';
    expect(service.required, isFalse);
    service.installedVersion = '2.0.0';
    expect(service.required, isFalse);
  });
  test('invalid remote versions cannot become policy', () {
    for (final value in ['1.2', 'bogus', '1.2.3-beta', '-1.2.3', '']) {
      expect(() => compareVersions('1.1.8', value), throwsFormatException);
    }
  });
  test('store link identifies the existing app', () {
    expect(
      Uri.parse(playStoreUrl).queryParameters['id'],
      'com.kurtizi.flupfun',
    );
  });
}
