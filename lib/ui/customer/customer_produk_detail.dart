import 'package:flutter/material.dart';
import 'customer_katalog.dart';

class CustomerProdukDetail extends StatefulWidget {
  final ItemKatalogCustomer produk;
  final bool isFavorit;
  final VoidCallback onToggleFavorit;
  final void Function(String namaIkan, int jumlahKg, bool langsungKeKeranjang) onTambahKeranjang;

  const CustomerProdukDetail({
    super.key,
    required this.produk,
    required this.isFavorit,
    required this.onToggleFavorit,
    required this.onTambahKeranjang,
  });

  @override
  State<CustomerProdukDetail> createState() => _CustomerProdukDetailState();
}

class _CustomerProdukDetailState extends State<CustomerProdukDetail> {
  int _jumlahKg = 1;
  late bool _favoritStatus;

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  @override
  void initState() {
    super.initState();
    _favoritStatus = widget.isFavorit;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.produk;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: primarySeafoam,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Produk & Penjual',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _favoritStatus ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _favoritStatus = !_favoritStatus);
              widget.onToggleFavorit();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Utama Produk (Seragam dengan Detail Produk Admin)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F7F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.ikon, size: 56, color: primarySeafoam),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.kategori.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primarySeafoam,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.nama,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('Harga per Kg', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(
                              item.harga,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentCoral),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
                      Expanded(
                        child: Column(
                          children: [
                            Text('Sisa Stok Segar', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(
                              item.stok,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu Informasi Penjual & Alamat Lokasi Tambak/TPI Karawang
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F7F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront, color: primarySeafoam, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.namaPenjual,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: primarySeafoam, size: 16),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mitra Resmi Bale Ikan • Rating ★ ${item.rating}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: accentCoral, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alamat Penjual: ${item.alamatPenjual}',
                          style: const TextStyle(fontSize: 13, color: darkText, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi & Spesifikasi Dimensi Kemasan Produk
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi & Spesifikasi Kemasan Ikan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.deskripsi,
                    style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spesifikasi Boks Pendingin per Paket:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primarySeafoam),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Berat Bersih: ${item.beratGram} gram (1 Kg)\n'
                          '• Ukuran Boks: Panjang ${item.panjangCm} cm x Lebar ${item.lebarCm} cm x Tinggi${item.tinggiCm} cm',
                          style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pengatur Jumlah Kilogram (Qty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah Pembelian (Kg)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _jumlahKg > 1 ? () => setState(() => _jumlahKg--) : null,
                        icon: const Icon(Icons.remove_circle_outline, color: primarySeafoam),
                      ),
                      Text(
                        '$_jumlahKg kg',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _jumlahKg++),
                        icon: const Icon(Icons.add_circle_outline, color: primarySeafoam),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi Marketplace (+ Keranjang & Beli Sekarang)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primarySeafoam,
                      side: const BorderSide(color: primarySeafoam, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      widget.onTambahKeranjang(item.nama, _jumlahKg, false);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('+ Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentCoral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      widget.onTambahKeranjang(item.nama, _jumlahKg, true);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: const Text('Beli Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}