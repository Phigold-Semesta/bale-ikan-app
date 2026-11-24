import 'package:flutter/material.dart';
import '../../helpers/user_info.dart';
import '../login.dart';
import 'customer_katalog.dart';
import 'customer_keranjang.dart';
import 'customer_pesanan.dart';
import 'customer_profil.dart';

class CustomerBeranda extends StatefulWidget {
  const CustomerBeranda({super.key});

  @override
  State<CustomerBeranda> createState() => _CustomerBerandaState();
}

class _CustomerBerandaState extends State<CustomerBeranda> {
  int _selectedIndex = 0;
  String _kategoriAktif = 'Semua';
  final Set<String> _favorit = {};
  final Map<String, int> _keranjang = {};

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color deepOcean = Color(0xFF028090);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  void _toggleFavorit(String namaIkan) {
    setState(() {
      if (_favorit.contains(namaIkan)) {
        _favorit.remove(namaIkan);
      } else {
        _favorit.add(namaIkan);
      }
    });
  }

  void _tambahKeKeranjang(String namaIkan, {int qty = 1, bool langsungKeKeranjang = false}) {
    setState(() {
      _keranjang[namaIkan] = (_keranjang[namaIkan] ?? 0) + qty;
      if (langsungKeKeranjang) {
        _selectedIndex = 1;
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$namaIkan (+$qty kg) ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
        backgroundColor: primarySeafoam,
      ),
    );
  }

  void _hapusDariKeranjang(String namaIkan) {
    setState(() {
      _keranjang.remove(namaIkan);
    });
  }

  void _kosongkanKeranjangDanPindahKePesanan() {
    setState(() {
      _keranjang.clear();
      _selectedIndex = 2;
    });
  }

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
    final List<Widget> pages = [
      CustomerKatalog(
        kategoriAktif: _kategoriAktif,
        favorit: _favorit,
        onKategoriChanged: (kat) => setState(() => _kategoriAktif = kat),
        onToggleFavorit: _toggleFavorit,
        onTambahKeranjang: _tambahKeKeranjang,
      ),
      CustomerKeranjang(
        keranjang: _keranjang,
        onHapusItem: _hapusDariKeranjang,
        onCheckoutSukses: _kosongkanKeranjangDanPindahKePesanan,
      ),
      const CustomerPesanan(),
      const CustomerProfil(),
    ];

    return SelectionContainer.disabled(
      child: Scaffold(
        backgroundColor: lightBg,
        drawer: _buildSidebarCustomer(context),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
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
                  errorBuilder: (_, __, ___) => const Icon(Icons.set_meal, color: primarySeafoam, size: 28),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'BALE IKAN',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Favorit Saya',
              icon: Badge(
                isLabelVisible: _favorit.isNotEmpty,
                backgroundColor: accentCoral,
                label: Text('${_favorit.length}'),
                child: const Icon(Icons.favorite_border, color: accentCoral),
              ),
              onPressed: () {
                setState(() {
                  _kategoriAktif = 'Favorit';
                  _selectedIndex = 0;
                });
              },
            ),
            IconButton(
              tooltip: 'Keranjang Belanja',
              icon: Badge(
                isLabelVisible: _keranjang.isNotEmpty,
                backgroundColor: accentCoral,
                label: Text('${_keranjang.length}'),
                child: const Icon(Icons.shopping_cart_outlined, color: primarySeafoam),
              ),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          elevation: 8,
          selectedItemColor: primarySeafoam,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (idx) => setState(() => _selectedIndex = idx),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: _keranjang.isNotEmpty,
                backgroundColor: accentCoral,
                label: Text('${_keranjang.length}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              label: 'Keranjang',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Pesanan'),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarCustomer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
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
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50, color: primarySeafoam),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Budi Santoso',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                const Text(
                  'customer@baleikan.com',
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
                    'Customer Pembeli',
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
                    'KATEGORI IKAN',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                ),
                _itemSidebarKategori('Semua', 'Semua Ikan', Icons.grid_view_rounded),
                _itemSidebarKategori('Air Tawar', 'Ikan Air Tawar', Icons.waves),
                _itemSidebarKategori('Ikan Laut', 'Ikan Laut', Icons.set_meal_outlined),
                _itemSidebarKategori(
                  'Favorit',
                  'Ikan Favorit',
                  Icons.favorite_border,
                  badgeCount: _favorit.length,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'MENU PEMBELI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined, color: primarySeafoam),
                  title: const Text('Keranjang Belanja', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: _keranjang.isNotEmpty
                      ? CircleAvatar(
                          radius: 11,
                          backgroundColor: accentCoral,
                          child: Text('${_keranjang.length}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined, color: primarySeafoam),
                  title: const Text('Riwayat Pesanan & Peta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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

  Widget _itemSidebarKategori(String kode, String judul, IconData ikon, {int badgeCount = 0}) {
    final bool aktif = _selectedIndex == 0 && _kategoriAktif == kode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: aktif ? primarySeafoam.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(ikon, color: aktif ? primarySeafoam : Colors.grey[700]),
        title: Text(
          judul,
          style: TextStyle(
            fontSize: 14,
            fontWeight: aktif ? FontWeight.bold : FontWeight.w500,
            color: aktif ? primarySeafoam : darkText,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: accentCoral, borderRadius: BorderRadius.circular(10)),
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          setState(() {
            _kategoriAktif = kode;
            _selectedIndex = 0;
          });
        },
      ),
    );
  }
}