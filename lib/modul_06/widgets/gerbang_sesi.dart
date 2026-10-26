import 'package:flutter/material.dart';
import '../controllers/sesi_controller.dart';
import '../models/sesi_pengguna.dart';

/// Widget pembatas/gerbang yang menentukan antarmuka berdasarkan [StatusSesi].
class GerbangSesi extends StatelessWidget {
  final SesiController controller;
  final WidgetBuilder form;
  final Widget Function(BuildContext context, SesiPengguna sesi) beranda;

  const GerbangSesi({
    super.key,
    required this.controller,
    required this.form,
    required this.beranda,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        switch (controller.status) {
          case StatusSesi.memeriksa:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          case StatusSesi.masuk:
            final SesiPengguna? sesi = controller.sesi;
            if (sesi != null) {
              return beranda(context, sesi);
            }
            // Jika status masuk tetapi objek sesi null, kembali ke form login
            return form(context);

          case StatusSesi.keluar:
          case StatusSesi.memproses:
          case StatusSesi.gagal:
          case StatusSesi.kedaluwarsa:
            return form(context);
        }
      },
    );
  }
}
