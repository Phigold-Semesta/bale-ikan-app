import 'package:flutter/material.dart';
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
  final Map<String, int> _keranjang = {};

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  void _tambahKeKeranjang(String namaIkan) {
    setState(() {
      _keranjang[namaIkan] = (_keranjang[namaIkan] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$namaIkan (+1 kg) masuk keranjang!'),
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CustomerKatalog(onTambahKeranjang: _tambahKeKeranjang),
      CustomerKeranjang(
        keranjang: _keranjang,
        onHapusItem: _hapusDariKeranjang,
        onCheckoutSukses: _kosongkanKeranjangDanPindahKePesanan,
      ),
      const CustomerPesanan(),
      const CustomerProfil(),
    ];

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/logo/bale_ikan_logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.set_meal, color: primarySeafoam),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'BALE IKAN • PEMBELI',
              style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primarySeafoam,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Belanja'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _keranjang.isNotEmpty,
              backgroundColor: accentCoral,
              label: Text('${_keranjang.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Keranjang',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Lacak Pesanan'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}