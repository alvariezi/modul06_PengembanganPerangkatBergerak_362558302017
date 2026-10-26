import 'package:flutter/material.dart';
import '../repositories/sesi_repository.dart';

/// Papan diagnostik untuk mengintip isi penyimpanan secara mentah (`intipMentah`).
class PapanDiagnostikPenyimpanan extends StatefulWidget {
  final SesiRepository repository;

  const PapanDiagnostikPenyimpanan({super.key, required this.repository});

  @override
  State<PapanDiagnostikPenyimpanan> createState() =>
      _PapanDiagnostikPenyimpananState();
}

class _PapanDiagnostikPenyimpananState
    extends State<PapanDiagnostikPenyimpanan> {
  bool _sedangMengintip = false;
  bool _sudahMengintip = false;
  String? _hasilIntip;

  Future<void> _intip() async {
    setState(() => _sedangMengintip = true);
    final String? hasil = await widget.repository.intipMentah();
    if (!mounted) return;
    setState(() {
      _hasilIntip = hasil;
      _sudahMengintip = true;
      _sedangMengintip = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Diagnostik: ${widget.repository.nama}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.repository.keterangan,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const Divider(height: 24),
            ElevatedButton.icon(
              onPressed: _sedangMengintip ? null : _intip,
              // PERBAIKAN DI SINI: menambahkan tanda tanya (?) yang sebelumnya terlewat
              icon: _sedangMengintip
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.visibility),
              label: Text(
                _sedangMengintip ? 'Mengintip...' : 'Intip Mentah Data Disket',
              ),
            ),
            const SizedBox(height: 12),
            if (_sudahMengintip) ...[
              const Text(
                'Hasil Pemeriksaan Intip Mentah:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Text(
                  _hasilIntip == null || _hasilIntip!.isEmpty
                      ? '[Tidak ada data / Data kosong atau terenkripsi ketat]'
                      : _hasilIntip!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: _hasilIntip == null
                        ? Colors.red[700]
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
