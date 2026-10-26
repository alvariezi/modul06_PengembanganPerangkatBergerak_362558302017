import '../models/sesi_pengguna.dart'; // Sesuaikan jalur impor model SesiPengguna jika diperlukan

class SesiMemori {
  SesiPengguna? _sesi;
  int jumlahPenulisan = 0;
  Future<SesiPengguna?> baca() async {
    return _sesi;
  }

  bool get adaSesi => _sesi != null;
  Future<void> simpan(SesiPengguna sesi) async {
    _sesi = sesi;
    jumlahPenulisan++;
  }

  Future<void> hapus() async {
    _sesi = null;
  }
}
