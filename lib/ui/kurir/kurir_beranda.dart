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

  void _tampilkanBantuan(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bantuan & Kontak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 12),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.phone_outlined, color: primarySeafoam),
              title: Text('+62 858-1132-5030'),
              subtitle: Text('Layanan pelanggan (08.00 - 17.00)'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.email_outlined, color: primarySeafoam),
              title: Text('admin@baleikan.com'),
              subtitle: Text('Email pertanyaan & pesanan'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on_outlined, color: primarySeafoam),
              title: Text('Karawang, Jawa Barat'),
              subtitle: Text('Lokasi toko Bale Ikan'),
            ),
          ],
        ),
      ),
    );
  }

  void _tampilkanTentang(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Bale Ikan',
      applicationVersion: '1.0.0',
      applicationIcon: ClipOval(
        child: Image.asset(
          'assets/logo/bale_ikan_logo.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.set_meal, color: primarySeafoam, size: 40),
        ),
      ),
      children: const [
        Text('Aplikasi katalog dan pemesanan ikan segar air tawar dan ikan laut.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      drawer: _buildSidebarKurir(context),
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
                errorBuilder: (_, __, ___) => const Icon(Icons.local_shipping_outlined, color: primarySeafoam, size: 28),
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

  Widget _buildSidebarKurir(BuildContext context) {
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
                      errorBuilder: (_, __, ___) => const Icon(Icons.local_shipping_outlined, size: 50, color: primarySeafoam),
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
                    'Mobil Box Pendingin Es',
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
                      fontSize: 14,
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
                      fontSize: 14,
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
                      fontSize: 14,
                      fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.w500,
                      color: _selectedIndex == 2 ? primarySeafoam : darkText,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 2);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'LAINNYA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined, color: primarySeafoam),
                  title: const Text('Bantuan & Kontak', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkText)),
                  onTap: () {
                    Navigator.pop(context);
                    _tampilkanBantuan(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: primarySeafoam),
                  title: const Text('Tentang Aplikasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkText)),
                  onTap: () {
                    Navigator.pop(context);
                    _tampilkanTentang(context);
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