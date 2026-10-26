import 'package:flutter/material.dart';
import '../controllers/sesi_controller.dart';
import '../services/auth_api.dart';

class LoginPengayaanScreen extends StatefulWidget {
  final SesiController controller;

  const LoginPengayaanScreen({super.key, required this.controller});

  @override
  State<LoginPengayaanScreen> createState() => _LoginPengayaanScreenState();
}

class _LoginPengayaanScreenState extends State<LoginPengayaanScreen> {
  // 1. GlobalKey untuk mengelola state Form dan validasi
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController(
    text: AuthApi.emailDemo,
  );
  final TextEditingController _sandiController = TextEditingController(
    text: AuthApi.sandiDemo,
  );

  bool _sembunyikanSandi = true;

  @override
  void dispose() {
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  void _prosesMasuk() {
    // 2. Lakukan pengecekan validasi form terlebih dahulu
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String sandi = _sandiController.text;
      widget.controller.masuk(email, sandi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Modul 6 Pengayaan')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              final bool sedangMemproses =
                  widget.controller.status == StatusSesi.memproses;
              final String? pesanError = widget.controller.pesan;

              // 3. Bungkus Column dengan widget Form dan pasang _formKey
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Autentikasi & Keamanan Sesi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gunakan kredensial demo atau uji penanganan error di bawah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    if (pesanError != null && pesanError.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          pesanError,
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4. Ubah TextField Email menjadi TextFormField dengan validator
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong.';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Format email tidak valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. Ubah TextField Kata Sandi menjadi TextFormField dengan validator
                    TextFormField(
                      controller: _sandiController,
                      obscureText: _sembunyikanSandi,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _sembunyikanSandi
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _sembunyikanSandi = !_sembunyikanSandi;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kata sandi tidak boleh kosong.';
                        }
                        if (value.length < 6) {
                          return 'Kata sandi minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: sedangMemproses ? null : _prosesMasuk,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: sedangMemproses
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Masuk', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 24),

                    // Kotak Informasi Kredensial Demo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kredensial Demo Cepat:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Valid: ${AuthApi.emailDemo} / ${AuthApi.sandiDemo}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            '• Terkunci: ${AuthApi.emailTerkunci}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            '• Gangguan Server: ${AuthApi.emailServerGangguan}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
