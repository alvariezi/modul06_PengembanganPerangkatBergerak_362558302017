import '../models/sesi_pengguna.dart';
import '../services/sesi_memori.dart';
import 'sesi_repository.dart';

/// Repository sesi yang menyimpan data hanya di memori (in-memory).
class MemoriSesiRepository implements SesiRepository {
  final SesiMemori _sesiMemori;

  MemoriSesiRepository(this._sesiMemori);

  @override
  String get nama => 'Memori (Volatil)';

  @override
  String get keterangan =>
      'Sesi disimpan di memori RAM. Hilang saat aplikasi ditutup/direstart.';

  @override
  bool get bertahanSetelahRestart => false;

  @override
  Future<SesiPengguna?> baca() async => _sesiMemori.baca();

  @override
  Future<void> simpan(SesiPengguna sesi) async => _sesiMemori.simpan(sesi);

  @override
  Future<void> hapus() async => _sesiMemori.hapus();

  @override
  Future<bool> adaSesi() async => _sesiMemori.adaSesi;

  @override
  Future<String?> intipMentah() async {
    // Memori tidak menyimpan data terformat/string mentah di disk.
    return null;
  }
}
