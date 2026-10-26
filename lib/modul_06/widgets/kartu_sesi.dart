import 'package:flutter/material.dart';
import '../models/sesi_pengguna.dart';

class KartuSesi extends StatelessWidget {
  final SesiPengguna sesi;

  /// Waktu acuan untuk menghitung sisa masa berlaku.
  final DateTime sekarang;

  final VoidCallback? onKeluar;
  final bool sedangKeluar;

  /// Menampilkan token asli jika true.
  /// Default false agar token tetap aman.
  final bool tampilkanToken;

  const KartuSesi({
    super.key,
    required this.sesi,
    required this.sekarang,
    this.onKeluar,
    this.sedangKeluar = false,
    this.tampilkanToken = false,
  });

  /// Menyamarkan token dengan menampilkan 6 karakter awal.
  static String samarkanToken(String token) {
    if (token.isEmpty) return '(kosong)';

    if (token.length <= 6) {
      return _titik(token.length);
    }

    return '${token.substring(0, 6)}${_titik(12)}';
  }

  static String _titik(int jumlah) {
    return List<String>.filled(jumlah, '\u2022').join();
  }

  /// Mengubah ISO-8601 menjadi format:
  /// 21 Sep 2026, 10:15
  static String formatWaktu(String iso) {
    const List<String> bulan = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final DateTime? waktu = DateTime.tryParse(iso);

    if (waktu == null) {
      return 'Tidak diketahui';
    }

    final String jam = waktu.hour.toString().padLeft(2, '0');
    final String menit = waktu.minute.toString().padLeft(2, '0');

    return '${waktu.day} ${bulan[waktu.month - 1]} '
        '${waktu.year}, $jam:$menit';
  }

  /// Mengubah sisa durasi menjadi teks yang mudah dibaca.
  static String formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) {
      return 'Sudah kedaluwarsa';
    }

    if (sisa.inMinutes < 1) {
      return '${sisa.inSeconds} detik';
    }

    if (sisa.inHours < 1) {
      final int menit = sisa.inMinutes;
      final int detik = sisa.inSeconds.remainder(60);

      if (detik == 0) {
        return '$menit menit';
      }

      return '$menit menit $detik detik';
    }

    final int jam = sisa.inHours;
    final int menit = sisa.inMinutes.remainder(60);

    if (menit == 0) {
      return '$jam jam';
    }

    return '$jam jam $menit menit';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    // Mengambil data masa berlaku dari model.
    final Duration sisaWaktu = sesi.sisaWaktu(sekarang);

    final bool sudahKedaluwarsa = sesi.sudahKedaluwarsa(sekarang);

    final String tokenTampilan = tampilkanToken
        ? sesi.token
        : samarkanToken(sesi.token);

    final Color warnaStatus = sudahKedaluwarsa
        ? warna.error
        : Colors.green.shade700;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Nama pengguna dan peran.
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    sesi.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(SesiPengguna.labelPeran(sesi.peran)),
                  backgroundColor: warna.secondaryContainer,
                  labelStyle: TextStyle(
                    color: warna.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Email pengguna.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.email_outlined,
                  size: 18,
                  color: warna.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sesi.email,
                    style: TextStyle(
                      color: warna.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 24),

            // Waktu masuk.
            _barisInfo(
              context,
              ikon: Icons.login_rounded,
              label: 'Waktu Masuk',
              nilai: formatWaktu(sesi.masukPada),
            ),

            const SizedBox(height: 12),

            // Waktu kedaluwarsa.
            _barisInfo(
              context,
              ikon: Icons.event_busy_outlined,
              label: 'Kedaluwarsa Pada',
              nilai: formatWaktu(sesi.kedaluwarsaPada),
            ),

            const SizedBox(height: 12),

            // Sisa masa berlaku.
            _barisInfo(
              context,
              ikon: Icons.timer_outlined,
              label: 'Sisa Masa Berlaku',
              nilai: formatSisa(sisaWaktu),
              warnaNilai: warnaStatus,
            ),

            const SizedBox(height: 12),

            // Status sesi.
            _barisInfo(
              context,
              ikon: sudahKedaluwarsa
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              label: 'Status Sesi',
              nilai: sudahKedaluwarsa ? 'Kedaluwarsa' : 'Aktif',
              warnaNilai: warnaStatus,
            ),

            const SizedBox(height: 12),

            // Token sesi.
            _barisInfo(
              context,
              ikon: Icons.key_rounded,
              label: 'Token',
              nilai: tokenTampilan,
              gunakanMonospace: true,
            ),

            const SizedBox(height: 20),

            // Tombol keluar sesi.
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: sedangKeluar ? null : onKeluar,
                icon: sedangKeluar
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded),
                label: Text(sedangKeluar ? 'Keluar...' : 'Keluar Sesi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: warna.error,
                  side: BorderSide(color: warna.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan satu baris informasi sesi.
  Widget _barisInfo(
    BuildContext context, {
    required IconData ikon,
    required String label,
    required String nilai,
    Color? warnaNilai,
    bool gunakanMonospace = false,
  }) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(ikon, size: 18, color: warna.onSurfaceVariant),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: warna.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                nilai,
                style: TextStyle(
                  fontSize: 14,
                  color: warnaNilai ?? warna.onSurface,
                  fontFamily: gunakanMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
