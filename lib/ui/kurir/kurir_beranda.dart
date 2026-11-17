import 'package:flutter/material.dart';
import '../../helpers/user_info.dart';
import '../login.dart';
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
  static const Color deepOcean = Color(0xFF028090);
  static const Color accentCoral = Color(0xFFFF6B6B);
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
      drawer: _buildSidebarKurir(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: darkText),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/logo/bale_ikan_logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.delivery_dining, color: primarySeafoam, size: 28),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'BALE IKAN • KURIR',
              style: TextStyle(color: darkText, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1),
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

  Widget _buildSidebarKurir() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primarySeafoam, deepOcean],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/bale_ikan_logo.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.delivery_dining, size: 50, color: primarySeafoam),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Kang Asep',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                const Text(
                  'kurir@baleikan.com • T 4581 KW',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Kurir Berpendingin Es',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'MENU LOGISTIK KURIR',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.local_shipping_outlined, color: _selectedIndex == 0 ? primarySeafoam : Colors.grey[700]),
                  title: Text(
                    'Tugas Pengantaran Aktif',
                    style: TextStyle(
                      fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.w500,
                      color: _selectedIndex == 0 ? primarySeafoam : darkText,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 0);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history, color: _selectedIndex == 1 ? primarySeafoam : Colors.grey[700]),
                  title: Text(
                    'Riwayat Selesai Diantar',
                    style: TextStyle(
                      fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.w500,
                      color: _selectedIndex == 1 ? primarySeafoam : darkText,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 1);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: _selectedIndex == 2 ? primarySeafoam : Colors.grey[700]),
                  title: Text(
                    'Profil & Armada Kurir',
                    style: TextStyle(
                      fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.w500,
                      color: _selectedIndex == 2 ? primarySeafoam : darkText,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 2);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: accentCoral),
            title: const Text('Keluar', style: TextStyle(color: accentCoral, fontWeight: FontWeight.bold)),
            onTap: () async {
              await UserInfo().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                  (route) => false,
                );
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Bale Ikan v1.0.0', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}