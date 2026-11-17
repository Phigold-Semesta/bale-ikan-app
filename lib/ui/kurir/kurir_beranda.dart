import 'package:flutter/material.dart';
import 'kurir_profil.dart';
import 'kurir_riwayat.dart';
import 'kurir_tugas.dart';

class KurirBeranda extends StatefulWidget {
  const KurirBeranda({super.key});

  @override
  State<KurirBeranda> createState() => _KurirBerandaState();
}

class _KurirBerandaState extends State<KurirBeranda> {
  int _selectedIndex = 0;

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  final List<Widget> _pages = const [
    KurirTugas(),
    KurirRiwayat(),
    KurirProfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.delivery_dining, color: primarySeafoam, size: 28),
            SizedBox(width: 8),
            Text(
              'BALE IKAN • KURIR LOGISTIK',
              style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primarySeafoam,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Tugas Aktif'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat Selesai'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil Kurir'),
        ],
      ),
    );
  }
}