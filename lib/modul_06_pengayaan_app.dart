import 'package:flutter/material.dart';

import 'modul_06/controllers/sesi_controller.dart';
import 'modul_06/models/sesi_pengguna.dart';
import 'modul_06/repositories/aman_sesi_repository.dart';
import 'modul_06/repositories/memori_sesi_repository.dart';
import 'modul_06/repositories/prefs_sesi_repository.dart';
import 'modul_06/repositories/sesi_repository.dart';
import 'modul_06/screens/beranda_pengayaan_screen.dart';
import 'modul_06/screens/login_pengayaan_screen.dart';
import 'modul_06/services/auth_api.dart';
import 'modul_06/services/sesi_memori.dart';
import 'modul_06/storage/penyimpanan_aman_platform.dart';
import 'modul_06/widgets/gerbang_sesi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Modul06PengayaanApp());
}

class Modul06PengayaanApp extends StatefulWidget {
  const Modul06PengayaanApp({super.key});

  @override
  State<Modul06PengayaanApp> createState() => _Modul06PengayaanAppState();
}

class _Modul06PengayaanAppState extends State<Modul06PengayaanApp> {
  late final List<SesiRepository> _daftarRepository;
  late SesiRepository _repositoryAktif;
  late SesiController _kendali;

  @override
  void initState() {
    super.initState();

    _daftarRepository = [
      AmanSesiRepository(const PenyimpananAmanPlatform()),
      PrefsSesiRepository(),
      MemoriSesiRepository(SesiMemori()),
    ];

    _repositoryAktif = _daftarRepository[0];

    _kendali = SesiController(
      repository: _repositoryAktif,
      api: const AuthApi(),
    );

    _kendali.pulihkan();
  }

  @override
  void dispose() {
    _kendali.dispose();
    super.dispose();
  }

  void _gantiRepository(SesiRepository repositoryBaru) {
    if (_repositoryAktif == repositoryBaru) return;
    setState(() {
      _repositoryAktif = repositoryBaru;
      _kendali.repository = repositoryBaru;
    });
    _kendali.pulihkan();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modul 06 Pengayaan - Keamanan Sesi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Modul 06 Pengayaan'),
          actions: [
            PopupMenuButton<SesiRepository>(
              icon: const Icon(Icons.storage),
              tooltip: 'Ganti Adapter Penyimpanan',
              onSelected: _gantiRepository,
              itemBuilder: (BuildContext context) {
                return _daftarRepository.map((SesiRepository repo) {
                  final bool terpilih = repo == _repositoryAktif;
                  return PopupMenuItem<SesiRepository>(
                    value: repo,
                    child: Row(
                      children: [
                        Icon(
                          terpilih
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: terpilih ? Colors.blue : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            repo.nama,
                            style: TextStyle(
                              fontWeight: terpilih
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: GerbangSesi(
          controller: _kendali,
          form: (BuildContext context) =>
              LoginPengayaanScreen(controller: _kendali),
          beranda: (BuildContext context, SesiPengguna sesi) =>
              BerandaPengayaanScreen(controller: _kendali, sesi: sesi),
        ),
      ),
    );
  }
}
