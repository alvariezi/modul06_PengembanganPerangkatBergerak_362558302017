import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sesi_pengguna.dart';
import 'sesi_repository.dart';

/// Repository sesi menggunakan [SharedPreferences].
class PrefsSesiRepository implements SesiRepository {
  static const String kunciSesi = 'sesi_pengguna_key';
  final Future<SharedPreferences> _prefs;

  PrefsSesiRepository({Future<SharedPreferences>? prefs})
    : _prefs = prefs ?? SharedPreferences.getInstance();

  @override
  String get nama => 'SharedPreferences';

  @override
  String get keterangan =>
      'Sesi bertahan setelah restart, tetapi disimpan secara mentah/plain-text.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final SharedPreferences prefs = await _prefs;
    final String? jsonString = prefs.getString(kunciSesi);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return SesiPengguna.fromJson(map); // Diperbarui ke fromJson
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final SharedPreferences prefs = await _prefs;
    final String jsonString = jsonEncode(sesi.toJson()); // Diperbarui ke toJson
    await prefs.setString(kunciSesi, jsonString);
  }

  @override
  Future<void> hapus() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(kunciSesi);
  }

  @override
  Future<String?> intipMentah() async {
    final SharedPreferences prefs = await _prefs;
    // Demonstrasi ini memperlihatkan bahwa adapter preferensi dapat
    // mengembalikan nilai token/sesi melalui API biasa (plain-text).
    return prefs.getString(kunciSesi);
  }
}
