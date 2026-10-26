import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:modul6/main.dart'; // Sesuaikan nama paket jika berbeda (misal: modul_06)

void main() {
  testWidgets('Memeriksa tampilan awal LoginScreen', (
    WidgetTester tester,
  ) async {
    // Bangun aplikasi kita menggunakan Modul06App dan picu sebuah frame.
    await tester.pumpWidget(const Modul06App());

    // Memverifikasi bahwa judul app bar atau teks di layar login muncul
    expect(find.text('Modul 06 — Login & Session Dasar'), findsOneWidget);
    expect(find.text('Masuk ke Portal Akademik'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Sandi
    expect(find.byType(FilledButton), findsOneWidget); // Tombol Masuk
  });
}
