import 'package:flutter/material.dart';
import 'helpers/user_info.dart';
import 'ui/beranda.dart';
import 'ui/customer/customer_beranda.dart';
import 'ui/kurir/kurir_beranda.dart';
import 'ui/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? token;
  String? role;
  try {
    token = await UserInfo().getToken();
    role = await UserInfo().getRole();
  } catch (e) {
    token = null;
  }

  Widget homePage = const Login();
  if (token != null) {
    if (role == 'customer') {
      homePage = const CustomerBeranda();
    } else if (role == 'kurir') {
      homePage = const KurirBeranda();
    } else {
      homePage = const Beranda();
    }
  }

  runApp(MaterialApp(
    title: "Bale Ikan App",
    debugShowCheckedModeBanner: false,
    home: homePage,
  ));
}