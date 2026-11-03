import 'package:flutter/material.dart';
import '../widget/sidebar.dart';

/// Model data ikan (type-safe, menggantikan List<Map> dynamic)
class Ikan {
  final String nama;
  final String kategori;
  final String harga;
  final String stok;
  final IconData ikon;

  const Ikan({
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.ikon,
  });
}

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int _selectedIndex = 0;
  String _kategoriAktif = 'Semua';
  String _kataKunci = '';
  final Set<String> _favorit = {};
  final TextEditingController _searchController = TextEditingController();

  // Warna Tema Konsisten
  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  static const List<String> _daftarKategori = ['Semua', 'Air Tawar', 'Ikan Laut', 'Favorit'];

  // Data dummy katalog ikan Bale Ikan
  static const List<Ikan> _katalogIkan = [
    Ikan(nama: 'Ikan Gabus Segar', kategori: 'Air Tawar', harga: 'Rp 45.000', stok: '15 kg', ikon: Icons.tsunami),
    Ikan(nama: 'Ikan Patin Tambak', kategori: 'Air Tawar', harga: 'Rp 30.000', stok: '25 kg', ikon: Icons.water),
    Ikan(nama: 'Ikan Tuna Laut', kategori: 'Ikan Laut', harga: 'Rp 75.000', stok: '10 kg', ikon: Icons.set_meal),
    Ikan(nama: 'Ikan Tongkol Asap', kategori: 'Ikan Laut', harga: 'Rp 35.000', stok: '20 kg', ikon: Icons.local_fire_department),
  ];

  List<Ikan> get _hasilFilter {
    return _katalogIkan.where((ikan) {
      final bool cocokKategori;
      if (_kategoriAktif == 'Semua') {
        cocokKategori = true;
      } else if (_kategoriAktif == 'Favorit') {
        cocokKategori = _favorit.contains(ikan.nama);
      } else {
        cocokKategori = ikan.kategori == _kategoriAktif;
      }
      final cocokKata = ikan.nama.toLowerCase().contains(_kataKunci.toLowerCase());
      return cocokKategori && cocokKata;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _hasilFilter;

    return Scaffold(
      backgroundColor: lightBg,
      drawer: Sidebar(
        kategoriAktif: _kategoriAktif,
        jumlahFavorit: _favorit.length,
        onKategoriSelected: (kategori) {
          setState(() {
            _kategoriAktif = kategori;
            _selectedIndex = 0;
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Row(
          children: [
            Icon(Icons.set_meal, color: primarySeafoam, size: 28),
            SizedBox(width: 8),
            Text(
              'BALE IKAN',
              style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: darkText),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: primarySeafoam),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildBannerPromo(),
            const SizedBox(height: 24),
            _buildHeaderKatalog(),
            const SizedBox(height: 12),
            _buildFilterKategori(),
            const SizedBox(height: 16),
            if (daftar.isEmpty) _buildKosong() else _buildGrid(daftar),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primarySeafoam,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Katalog'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search Bar
  // ---------------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _kataKunci = value),
        decoration: InputDecoration(
          hintText: 'Cari ikan tawar atau ikan laut segar...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: primarySeafoam),
          suffixIcon: _kataKunci.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: accentCoral),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _kataKunci = '');
                  },
                )
              : const Icon(Icons.tune, color: accentCoral),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Banner Promo
  // ---------------------------------------------------------------------------
  Widget _buildBannerPromo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentCoral,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x4DFF6B6B), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PANEN RAYA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Diskon Hingga\n25% Hari Ini!',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkText,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Pesan Sekarang',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.phishing, size: 80, color: Colors.white24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header & Filter Kategori
  // ---------------------------------------------------------------------------
  Widget _buildHeaderKatalog() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Katalog Ikan Segar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
        ),
        Text(
          'Lihat Semua',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primarySeafoam),
        ),
      ],
    );
  }

  Widget _buildFilterKategori() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _daftarKategori.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final kategori = _daftarKategori[index];
          final aktif = kategori == _kategoriAktif;
          return ChoiceChip(
            label: Text(kategori),
            selected: aktif,
            showCheckmark: false,
            selectedColor: primarySeafoam,
            backgroundColor: Colors.white,
            side: BorderSide(color: aktif ? primarySeafoam : Colors.grey.shade300),
            labelStyle: TextStyle(
              color: aktif ? Colors.white : darkText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            onSelected: (_) => setState(() => _kategoriAktif = kategori),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid Katalog
  // ---------------------------------------------------------------------------
  Widget _buildKosong() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Ikan tidak ditemukan',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Ikan> daftar) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: daftar.length,
      itemBuilder: (context, index) => _buildKartuIkan(daftar[index]),
    );
  }

  Widget _buildKartuIkan(Ikan item) {
    final difavoritkan = _favorit.contains(item.nama);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian ikon produk + tombol favorit
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: lightBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(item.ikon, size: 50, color: primarySeafoam)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (difavoritkan) {
                            _favorit.remove(item.nama);
                          } else {
                            _favorit.add(item.nama);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          difavoritkan ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: accentCoral,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bagian deskripsi & harga
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.kategori,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primarySeafoam),
                ),
                const SizedBox(height: 2),
                Text(
                  item.nama,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok: ${item.stok}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.harga,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentCoral),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.nama} ditambahkan ke keranjang'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: primarySeafoam,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primarySeafoam,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}