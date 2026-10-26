import 'dart:convert';
import '../models/sesi_pengguna.dart';
import '../storage/penyimpanan_aman.dart';
import 'sesi_repository.dart';

/// Repository sesi menggunakan [PenyimpananAman] (Secure Storage terenkripsi).
class AmanSesiRepository implements SesiRepository {
  static const String kunciSesi = 'sesi_pengguna_aman_key';
  final PenyimpananAman penyimpanan;

  AmanSesiRepository(this.penyimpanan);

  @override
  String get nama => 'Penyimpanan Aman (Secure Storage)';

  @override
  String get keterangan =>
      'Sesi terenkripsi di Keychain (iOS) / Keystore (Android).';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final String? jsonString = await penyimpanan.baca(kunciSesi);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return SesiPengguna.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final String jsonString = jsonEncode(sesi.toJson());
    await penyimpanan.tulis(kunciSesi, jsonString);
  }

  @override
  Future<void> hapus() async {
    await penyimpanan.hapus(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final String? data = await penyimpanan.baca(kunciSesi);
    return data != null;
  }

  @override
  Future<String?> intipMentah() => penyimpanan.bacaMentah(kunciSesi);
  // Adapter tidak menyediakan pembacaan mentah melalui API aplikasi.
}
