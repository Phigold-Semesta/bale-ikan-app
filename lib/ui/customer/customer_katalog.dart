import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../service/realtime_sync_service.dart';
import 'customer_produk_detail.dart';

class ItemKatalogCustomer {
  final String nama;
  final String kategori;
  final String harga;
  final String stok;
  final IconData ikon;
  final String namaPenjual;
  final String alamatPenjual;
  final String rating;
  final String deskripsi;
  final int beratGram;
  final int panjangCm;
  final int lebarCm;
  final int tinggiCm;

  const ItemKatalogCustomer({
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.ikon,
    required this.namaPenjual,
    required this.alamatPenjual,
    required this.rating,
    required this.deskripsi,
    required this.beratGram,
    required this.panjangCm,
    required this.lebarCm,
    required this.tinggiCm,
  });
}

class CustomerKatalog extends StatefulWidget {
  final String kategoriAktif;
  final Set<String> favorit;
  final ValueChanged<String> onKategoriChanged;
  final ValueChanged<String> onToggleFavorit;
  final void Function(String namaIkan, {int qty, bool langsungKeKeranjang}) onTambahKeranjang;

  const CustomerKatalog({
    super.key,
    required this.kategoriAktif,
    required this.favorit,
    required this.onKategoriChanged,
    required this.onToggleFavorit,
    required this.onTambahKeranjang,
  });

  @override
  State<CustomerKatalog> createState() => _CustomerKatalogState();
}

class _CustomerKatalogState extends State<CustomerKatalog> {
  String _kataKunci = '';
  final TextEditingController _searchController = TextEditingController();

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  static const List<String> _daftarKategori = ['Semua', 'Air Tawar', 'Ikan Laut', 'Favorit'];

  static const List<ItemKatalogCustomer> _daftarIkan = [
    ItemKatalogCustomer(
      nama: 'Ikan Gabus Segar',
      kategori: 'Air Tawar',
      harga: 'Rp 45.000',
      stok: '15 kg',
      ikon: Icons.tsunami,
      namaPenjual: 'Tambak Persada Mandiri Farm',
      alamatPenjual: 'Desa Cibuaya, Kec. Cibuaya, Kabupaten Karawang, Jawa Barat',
      rating: '4.9 (128 ulasan)',
      deskripsi: 'Ikan gabus segar hasil budidaya air tawar alami Karawang. Kaya albumin tinggi, daging tebal, segar, dan dikirim menggunakan boks berpendingin es.',
      beratGram: 1000,
      panjangCm: 35,
      lebarCm: 20,
      tinggiCm: 15,
    ),
    ItemKatalogCustomer(
      nama: 'Ikan Patin Tambak',
      kategori: 'Air Tawar',
      harga: 'Rp 30.000',
      stok: '25 kg',
      ikon: Icons.water,
      namaPenjual: 'Kolam Berkah Tani Telukjambe',
      alamatPenjual: 'Jl. Raya Galuh Mas, Telukjambe Timur, Kabupaten Karawang',
      rating: '4.8 (96 ulasan)',
      deskripsi: 'Ikan patin tambak segar pilihan tanpa bau tanah. Sangat cocok untuk hidangan pindang patin, gulai, maupun bakar bumbu kuning.',
      beratGram: 1000,
      panjangCm: 32,
      lebarCm: 18,
      tinggiCm: 14,
    ),
    ItemKatalogCustomer(
      nama: 'Ikan Tuna Laut',
      kategori: 'Ikan Laut',
      harga: 'Rp 75.000',
      stok: '10 kg',
      ikon: Icons.set_meal,
      namaPenjual: 'TPI Ciparagejaya Samudra',
      alamatPenjual: 'Muara Ciparagejaya, Kec. Tempuran, Kabupaten Karawang',
      rating: '4.9 (210 ulasan)',
      deskripsi: 'Tuna laut segar tangkapan nelayan pesisir utara Karawang. Daging merah segar berkualitas tinggi kaya Omega-3.',
      beratGram: 1000,
      panjangCm: 40,
      lebarCm: 22,
      tinggiCm: 16,
    ),
    ItemKatalogCustomer(
      nama: 'Ikan Tongkol Asap',
      kategori: 'Ikan Laut',
      harga: 'Rp 35.000',
      stok: '20 kg',
      ikon: Icons.local_fire_department,
      namaPenjual: 'Nelayan Pakisjaya Bahari',
      alamatPenjual: 'Pesisir Tanjungpakis, Kec. Pakisjaya, Kabupaten Karawang',
      rating: '4.7 (84 ulasan)',
      deskripsi: 'Ikan tongkol laut segar yang diolah secara higienis. Tekstur daging padat, gurih, dan siap diolah menjadi balado atau suwir pedas.',
      beratGram: 1000,
      panjangCm: 30,
      lebarCm: 18,
      tinggiCm: 12,
    ),
    ItemKatalogCustomer(
      nama: 'Ikan Mujair Nila Segar',
      kategori: 'Air Tawar',
      harga: 'Rp 32.000',
      stok: '18 kg',
      ikon: Icons.waves,
      namaPenjual: 'Tambak Mandiri Rengasdengklok',
      alamatPenjual: 'Jl. Proklamasi, Kec. Rengasdengklok, Kabupaten Karawang',
      rating: '4.8 (112 ulasan)',
      deskripsi: 'Ikan mujair & nila air deras segar langsung dari kolam panen harian di Rengasdengklok Karawang.',
      beratGram: 1000,
      panjangCm: 28,
      lebarCm: 18,
      tinggiCm: 12,
    ),
    ItemKatalogCustomer(
      nama: 'Ikan Kakap Merah',
      kategori: 'Ikan Laut',
      harga: 'Rp 85.000',
      stok: '8 kg',
      ikon: Icons.phishing,
      namaPenjual: 'Koperasi Nelayan Cilamaya',
      alamatPenjual: 'TPI Pasirputih, Kec. Cilamaya Wetan, Kabupaten Karawang',
      rating: '5.0 (154 ulasan)',
      deskripsi: 'Ikan kakap merah segar kualitas restoran seafood, baru mendarat di pelelangan ikan Cilamaya Karawang.',
      beratGram: 1000,
      panjangCm: 38,
      lebarCm: 20,
      tinggiCm: 15,
    ),
  ];

  List<ItemKatalogCustomer> get _hasilFilter {
    return _daftarIkan.where((ikan) {
      final bool cocokKategori;
      if (widget.kategoriAktif == 'Semua') {
        cocokKategori = true;
      } else if (widget.kategoriAktif == 'Favorit') {
        cocokKategori = widget.favorit.contains(ikan.nama);
      } else {
        cocokKategori = ikan.kategori == widget.kategoriAktif;
      }
      final cocokKata = ikan.nama.toLowerCase().contains(_kataKunci.toLowerCase()) ||
          ikan.namaPenjual.toLowerCase().contains(_kataKunci.toLowerCase());
      return cocokKategori && cocokKata;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _bukaDetailProduk(ItemKatalogCustomer item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerProdukDetail(
          produk: item,
          isFavorit: widget.favorit.contains(item.nama),
          onToggleFavorit: () => widget.onToggleFavorit(item.nama),
          onTambahKeranjang: (nama, qty, langsung) {
            widget.onTambahKeranjang(nama, qty: qty, langsungKeKeranjang: langsung);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _hasilFilter;

    return ListenableBuilder(
      listenable: RealtimeSyncService.instance,
      builder: (context, _) {
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
              if (daftar.isEmpty) _buildKosong() else _buildGrid(daftar),
            ],
          ),
        );
      },
    );
  }

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
          hintText: 'Cari ikan tawar, ikan laut, atau tambak Karawang...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.5),
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
                  'PANEN RAYA KARAWANG',
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
                  onPressed: () => widget.onKategoriChanged('Semua'),
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

  Widget _buildHeaderKatalog() {
    return GestureDetector(
      onTap: () => widget.onKategoriChanged('Semua'),
      child: const Row(
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
      ),
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
          final aktif = kategori == widget.kategoriAktif;
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
            onSelected: (_) => widget.onKategoriChanged(kategori),
          );
        },
      ),
    );
  }

  Widget _buildKosong() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              widget.kategoriAktif == 'Favorit'
                  ? 'Belum ada ikan favorit yang ditandai'
                  : 'Ikan tidak ditemukan',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<ItemKatalogCustomer> daftar) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.66,
      ),
      itemCount: daftar.length,
      itemBuilder: (context, index) => _buildKartuIkan(daftar[index]),
    );
  }

  Widget _buildKartuIkan(ItemKatalogCustomer item) {
    final difavoritkan = widget.favorit.contains(item.nama);
    final Uint8List? fotoProduk = RealtimeSyncService.instance.getFotoProduk(item.nama);

    return GestureDetector(
      onTap: () => _bukaDetailProduk(item),
      child: Container(
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
            // Menampilkan Gambar Katalog yang Diunggah Admin secara Otomatis
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: lightBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (fotoProduk != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.memory(fotoProduk, fit: BoxFit.cover),
                      )
                    else
                      Center(child: Icon(item.ikon, size: 50, color: primarySeafoam)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => widget.onToggleFavorit(item.nama),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 11, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          item.namaPenjual,
                          style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
                      Tooltip(
                        message: 'Tambah ke Keranjang',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => widget.onTambahKeranjang(item.nama),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: primarySeafoam,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}