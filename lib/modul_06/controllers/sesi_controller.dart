import 'package:flutter/foundation.dart';
import '../models/sesi_pengguna.dart';
import '../repositories/sesi_repository.dart';
// Sesuaikan impor servis ini ke file AuthApi Anda (misal: 'auth_api.dart')
import '../services/auth_api.dart';

enum StatusSesi { memeriksa, keluar, memproses, masuk, gagal, kedaluwarsa }

/// Pengendali alur sesi pengguna berbasis [ChangeNotifier].
class SesiController extends ChangeNotifier {
  SesiRepository repository;
  final AuthApi api; // Ubah dari OtentikasiApi menjadi AuthApi
  final DateTime Function() jam;

  StatusSesi _status = StatusSesi.memeriksa;
  SesiPengguna? _sesi;
  String? _pesan;

  SesiController({
    required this.repository,
    required this.api,
    DateTime Function()? jam,
  }) : jam = jam ?? DateTime.now;

  StatusSesi get status => _status;
  SesiPengguna? get sesi => _sesi;
  String? get pesan => _pesan;

  void _ubah(
    StatusSesi statusBaru, {
    SesiPengguna? sesi,
    String? pesan,
    bool bersihkanPesan = false,
  }) {
    _status = statusBaru;
    if (sesi != null || statusBaru == StatusSesi.keluar) {
      _sesi = sesi;
    }
    if (bersihkanPesan) {
      _pesan = null;
    } else if (pesan != null) {
      _pesan = pesan;
    }
    notifyListeners();
  }

  /// Memulihkan status sesi saat aplikasi dibuka.
  Future<void> pulihkan() async {
    _ubah(StatusSesi.memeriksa, bersihkanPesan: true);

    final SesiPengguna? tersimpan = await repository.baca();
    if (tersimpan == null) {
      _ubah(StatusSesi.keluar, sesi: null);
      return;
    }

    if (tersimpan.sudahKedaluwarsa(jam())) {
      await repository.hapus(); // Sesi mati dibuang, bukan dibiarkan.
      _sesi = null;
      _ubah(
        StatusSesi.kedaluwarsa,
        pesan: 'Sesi Anda sudah berakhir. Silakan masuk kembali.',
      );
      return;
    }

    _ubah(StatusSesi.masuk, sesi: tersimpan);
  }

  /// Memperbarui masa berlaku sesi jika belum kedaluwarsa.
  Future<void> perbaruiSesi({
    Duration masaBerlaku = const Duration(hours: 2),
  }) async {
    final SesiPengguna? sekarang = _sesi;
    if (sekarang == null) return;

    if (sekarang.sudahKedaluwarsa(jam())) {
      await repository.hapus();
      _sesi = null;
      _ubah(
        StatusSesi.kedaluwarsa,
        pesan: 'Sesi sudah berakhir dan tidak dapat diperbarui.',
      );
      return;
    }

    final SesiPengguna baru = await api.perbaruiSesi(
      sekarang,
      masaBerlaku: masaBerlaku,
    );
    await repository.simpan(baru);
    _ubah(StatusSesi.masuk, sesi: baru);
  }

  /// Proses masuk (login) pengguna.
  Future<void> masuk(String email, String kataLandi) async {
    _ubah(StatusSesi.memproses, bersihkanPesan: true);
    try {
      // Sesuaikan pemanggilan dengan named parameter 'email' dan 'sandi' pada AuthApi
      final SesiPengguna sesiBaru = await api.masuk(
        email: email,
        sandi: kataLandi,
      );
      await repository.simpan(sesiBaru);
      _ubah(StatusSesi.masuk, sesi: sesiBaru);
    } catch (e) {
      _ubah(StatusSesi.gagal, pesan: e.toString());
    }
  }

  /// Keluar (logout) dari sesi saat ini.
  Future<void> keluar() async {
    await repository.hapus();
    _ubah(StatusSesi.keluar, sesi: null);
  }
}
