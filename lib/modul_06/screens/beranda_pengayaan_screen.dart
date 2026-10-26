import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/sesi_controller.dart';
import '../models/sesi_pengguna.dart';
import '../widgets/papan_diagnostik_penyimpanan.dart';

// 1. StatefulWidget BerandaPengayaanScreen
class BerandaPengayaanScreen extends StatefulWidget {
  final SesiController controller;
  final SesiPengguna sesi;

  const BerandaPengayaanScreen({
    super.key,
    required this.controller,
    required this.sesi,
  });

  @override
  State<BerandaPengayaanScreen> createState() => _BerandaPengayaanScreenState();
} // <--- Batas akhir kelas BerandaPengayaanScreen (PASTIKAN ADA DI SINI)

// 2. State kelas harus berada DI LUAR kelas di atas (sejajar)
class _BerandaPengayaanScreenState extends State<BerandaPengayaanScreen> {
  late Duration _sisaWaktu;
  Timer? _timerSesi;

  @override
  void initState() {
    super.initState();
    _hitungSisaWaktuAwal();
    _mulaiHitungMundur();
  }

  /// Menghitung selisih waktu antara waktu sekarang dengan kedaluwarsaPada
  void _hitungSisaWaktuAwal() {
    final DateTime waktuKedaluwarsa = DateTime.parse(
      widget.sesi.kedaluwarsaPada,
    );
    final DateTime sekarang = DateTime.now();
    _sisaWaktu = waktuKedaluwarsa.difference(sekarang);
    if (_sisaWaktu.isNegative) {
      _sisaWaktu = Duration.zero;
    }
  }

  void _mulaiHitungMundur() {
    _timerSesi = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_sisaWaktu.inSeconds > 0) {
          _sisaWaktu = _sisaWaktu - const Duration(seconds: 1);
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    // PENTING: Wajib membatalkan timer untuk mencegah memory leak
    _timerSesi?.cancel();
    super.dispose();
  }

  // Fungsi helper untuk memformat Duration menjadi string
  String _formatDurasi(Duration duration) {
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duration.inHours;
    final menit = duaDigit(duration.inMinutes.remainder(60));
    final detik = duaDigit(duration.inSeconds.remainder(60));

    if (jam > 0) {
      return "$jam:$menit:$detik";
    }
    return "$menit:$detik";
  }

  @override
  Widget build(BuildContext context) {
    // Logika pengecekan apakah sisa waktu kurang dari 5 menit
    final bool kurangDariLimaMenit = _sisaWaktu.inMinutes < 5;
    // Warna teks timer: Merah jika < 5 menit, Putih jika aman
    final Color warnaTimer = kurangDariLimaMenit
        ? Colors.redAccent
        : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda - Modul 06 Pengayaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => widget.controller.keluar(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Informasi Pengguna & Hitung Mundur Sesi
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blue.shade800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang Kembali,',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.sesi.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${widget.sesi.email}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    'Peran: ${SesiPengguna.labelPeran(widget.sesi.peran)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  // Bagian Hitung Mundur Sesi (Latihan 2)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kurangDariLimaMenit
                            ? Colors.redAccent
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sisa Waktu Sesi:',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          _formatDurasi(_sisaWaktu),
                          style: TextStyle(
                            color: warnaTimer,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (kurangDariLimaMenit) ...[
                    const SizedBox(height: 6),
                    const Text(
                      '⚠️ Perhatian: Sesi Anda akan segera berakhir!',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.controller.perbaruiSesi();
                          setState(() {
                            _hitungSisaWaktuAwal();
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Perbarui Sesi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                'Panel Diagnostik Penyimpanan Sesi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Uji integritas repository untuk melihat perbedaan perlindungan data.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),

            // Memasang Papan Diagnostik menggunakan repository aktif dari controller
            PapanDiagnostikPenyimpanan(
              repository: widget.controller.repository,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
