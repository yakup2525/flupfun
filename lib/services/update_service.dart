import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

const playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.kurtizi.flupfun';
const privacyPolicyUrl = 'https://wolftrailstudio.com/privacy/flup-fun/';
const updatePolicyUrl = 'https://wolftrailstudio.com/updates/flup-fun.json';

/// Strict numeric versions; malformed/untrusted configuration is ignored.
int compareVersions(String a, String b) {
  List<int> parse(String value) {
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
      throw const FormatException('Expected major.minor.patch');
    }
    return value.split('.').map(int.parse).toList();
  }

  final left = parse(a);
  final right = parse(b);
  for (var i = 0; i < 3; i++) {
    final difference = left[i].compareTo(right[i]);
    if (difference != 0) return difference;
  }
  return 0;
}

class UpdateService extends ChangeNotifier {
  String? minimumVersion;
  String? installedVersion;
  bool checking = false;
  bool get required =>
      installedVersion != null &&
      minimumVersion != null &&
      compareVersions(installedVersion!, minimumVersion!) < 0;

  Future<void> check() async {
    if (checking) return;
    checking = true;
    HttpClient? client;
    try {
      installedVersion ??= (await PackageInfo.fromPlatform()).version;
      final box = await Hive.openBox<String>('update-policy');
      final cached = box.get('minimumSupportedVersion');
      if (cached != null) {
        try {
          compareVersions(installedVersion!, cached);
          minimumVersion = cached;
          notifyListeners();
        } on FormatException {
          await box.delete('minimumSupportedVersion');
        }
      }
      client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      final request = await client
          .getUrl(Uri.parse(updatePolicyUrl))
          .timeout(const Duration(seconds: 5));
      request.followRedirects = false;
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode != HttpStatus.ok) return;
      final bytes = await response
          .fold<List<int>>(<int>[], (bytes, chunk) {
            if (bytes.length + chunk.length > 4096) {
              throw const FormatException('Policy too large');
            }
            return bytes..addAll(chunk);
          })
          .timeout(const Duration(seconds: 5));
      final policy = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final minimum = policy['minimumSupportedVersion'] as String;
      compareVersions(installedVersion!, minimum);
      // Store navigation is a fixed verified package URL, never remotely supplied.
      minimumVersion = minimum;
      await box.put('minimumSupportedVersion', minimum);
    } catch (_) {
      // With no known policy, offline startup remains usable. A cached mandatory
      // policy stays enforced offline; a store/network failure cannot bypass it.
    } finally {
      client?.close(force: true);
      checking = false;
      notifyListeners();
    }
  }
}
