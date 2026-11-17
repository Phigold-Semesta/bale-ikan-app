import 'package:flutter/material.dart';

class ItemKatalogCustomer {
  final String nama;
  final String kategori;
  final String harga;
  final String stok;
  final IconData ikon;

  const ItemKatalogCustomer({
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.ikon,
  });
}

class CustomerKatalog extends StatefulWidget {
  final ValueChanged<String> onTambahKeranjang;

  const CustomerKatalog({super.key, required this.onTambahKeranjang});

  @override
  State<CustomerKatalog> createState() => _CustomerKatalogState();
}

class _CustomerKatalogState extends State<CustomerKatalog> {
  String _kategori = 'Semua';
  String _keyword = '';

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  static const List<ItemKatalogCustomer> _daftarIkan = [
    ItemKatalogCustomer(nama: 'Ikan Gabus Segar', kategori: 'Air Tawar', harga: 'Rp 45.000', stok: '15 kg', ikon: Icons.tsunami),
    ItemKatalogCustomer(nama: 'Ikan Patin Tambak', kategori: 'Air Tawar', harga: 'Rp 30.000', stok: '25 kg', ikon: Icons.water),
    ItemKatalogCustomer(nama: 'Ikan Tuna Laut', kategori: 'Ikan Laut', harga: 'Rp 75.000', stok: '10 kg', ikon: Icons.set_meal),
    ItemKatalogCustomer(nama: 'Ikan Tongkol Asap', kategori: 'Ikan Laut', harga: 'Rp 35.000', stok: '20 kg', ikon: Icons.local_fire_department),
    ItemKatalogCustomer(nama: 'Ikan Gurame Padat', kategori: 'Air Tawar', harga: 'Rp 55.000', stok: '12 kg', ikon: Icons.waves),
    ItemKatalogCustomer(nama: 'Ikan Kakap Merah', kategori: 'Ikan Laut', harga: 'Rp 85.000', stok: '8 kg', ikon: Icons.phishing),
  ];

  @override
  Widget build(BuildContext context) {
    final hasil = _daftarIkan.where((e) {
      final cocokKat = _kategori == 'Semua' || e.kategori == _kategori;
      final cocokKata = e.nama.toLowerCase().contains(_keyword.toLowerCase());
      return cocokKat && cocokKata;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: TextField(
              onChanged: (v) => setState(() => _keyword = v),
              decoration: const InputDecoration(
                hintText: 'Cari ikan segar untuk dimasak hari ini...',
                prefixIcon: Icon(Icons.search, color: primarySeafoam),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: primarySeafoam, borderRadius: BorderRadius.circular(18)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GARANSI SEGAR DARI KOLAM & LAUT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Diantar Kurir Berpendingin Es\nLangsung ke Rumah Anda!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Semua', 'Air Tawar', 'Ikan Laut'].map((kat) {
                final aktif = _kategori == kat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(kat),
                    selected: aktif,
                    selectedColor: primarySeafoam,
                    labelStyle: TextStyle(color: aktif ? Colors.white : darkText, fontWeight: FontWeight.bold),
                    onSelected: (_) => setState(() => _kategori = kat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemCount: hasil.length,
            itemBuilder: (context, index) {
              final item = hasil[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: lightBg,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(child: Icon(item.ikon, size: 48, color: primarySeafoam)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.kategori, style: const TextStyle(fontSize: 10, color: primarySeafoam, fontWeight: FontWeight.bold)),
                          Text(item.nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Stok: ${item.stok}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.harga, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentCoral)),
                              InkWell(
                                onTap: () => widget.onTambahKeranjang(item.nama),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: primarySeafoam, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('+ Beli', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
            },
          ),
        ],
      ),
    );
  }
}