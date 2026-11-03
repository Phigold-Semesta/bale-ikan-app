import 'package:flutter/material.dart';
import 'helpers/user_info.dart';
import 'ui/beranda.dart';
import 'ui/login.dart';

Future<void> main() async {
  // Memastikan binding Flutter diinisialisasi sebelum menjalankan fungsi async
  WidgetsFlutterBinding.ensureInitialized();

  String? token;
  try {
    // Mengambil token sesi login dari SharedPreferences secara aman
    token = await UserInfo().getToken();
  } catch (e) {
    token = null;
  }

  runApp(MaterialApp(
    title: "Bale Ikan App",
    debugShowCheckedModeBanner: false,
    // Jika token kosong/null, arahkan ke Halaman Login, jika ada langsung ke Beranda Katalog
    home: token == null ? const Login() : const Beranda(),
  ));
}