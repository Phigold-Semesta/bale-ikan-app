import 'package:flutter/material.dart';
import '../widget/sidebar.dart';
import '../service/produk_service.dart';
import '../model/produk_ikan.dart';
import 'produk_page.dart';
import 'transaksi_page.dart';
import 'profil_page.dart';
import 'produk_item.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mengambil data dinamis dari Service Lokal
  Stream<List<ProdukIkan>> getList() async* {
    List<ProdukIkan> data = await ProdukService().listData();
    yield data;
  }

  // Fungsi Global untuk Toggle Favorit
  void _toggleFavorit(String idIkan) {
    setState(() {
      if (_favorit.contains(idIkan)) {
        _favorit.remove(idIkan);
      } else {
        _favorit.add(idIkan);
      }
    });
  }

  // Daftar Halaman yang dihubungkan dengan BottomNavigationBar
  List<Widget> get _pages => [
        _buildHalamanBerandaUtama(),
        // Kirim state favorit ke ProdukPage agar sinkron
        ProdukPage(favoritItemIds: _favorit, onToggleFavorit: _toggleFavorit),
        const TransaksiPage(),
        const ProfilPage(),
      ];

  Widget _buildHalamanBerandaUtama() {
    return SingleChildScrollView(
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
          // Memanggil StreamBuilder untuk menyinkronkan data katalog secara dinamis
          StreamBuilder<List<ProdukIkan>>(
            stream: getList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primarySeafoam)),
                );
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Gagal memuat data katalog.'));
              }
              
              // Terapkan logika filter
              List<ProdukIkan> daftarKatalog = snapshot.data ?? [];
              List<ProdukIkan> daftarFilter = daftarKatalog.where((ikan) {
                final bool cocokKategori;
                if (_kategoriAktif == 'Semua') {
                  cocokKategori = true;
                } else if (_kategoriAktif == 'Favorit') {
                  cocokKategori = _favorit.contains(ikan.id.toString());
                } else {
                  cocokKategori = ikan.kategori == _kategoriAktif;
                }
                final cocokKata = ikan.namaIkan.toLowerCase().contains(_kataKunci.toLowerCase());
                return cocokKategori && cocokKata;
              }).toList();

              if (daftarFilter.isEmpty) {
                return _buildKosong();
              }
              
              return _buildGrid(daftarFilter);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        titleSpacing: 0,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/logo/bale_ikan_logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.set_meal, color: primarySeafoam, size: 28),
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
        iconTheme: const IconThemeData(color: darkText),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: primarySeafoam),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_selectedIndex],
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

  // Diperbarui: Memanggil komponen ProdukItem agar fungsionalitas UI seragam
  Widget _buildGrid(List<ProdukIkan> daftar) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: daftar.length,
      itemBuilder: (context, index) {
        final ikan = daftar[index];
        final id = ikan.id.toString();
        
        return ProdukItem(
          produk: ikan,
          isFavorit: _favorit.contains(id),
          onToggleFavorit: () => _toggleFavorit(id),
        );
      },
    );
  }
}