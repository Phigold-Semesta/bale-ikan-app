import 'package:flutter/material.dart';
import '../../model/pesanan_model.dart';
import '../../service/realtime_sync_service.dart';

class CustomerKeranjang extends StatefulWidget {
  final Map<String, int> keranjang;
  final ValueChanged<String> onHapusItem;
  final VoidCallback onCheckoutSukses;

  const CustomerKeranjang({
    super.key,
    required this.keranjang,
    required this.onHapusItem,
    required this.onCheckoutSukses,
  });

  @override
  State<CustomerKeranjang> createState() => _CustomerKeranjangState();
}

class _CustomerKeranjangState extends State<CustomerKeranjang> {
  final TextEditingController _alamatCtrl = TextEditingController(
    text: 'Perum Galuh Mas Blok B4, Telukjambe Timur, Karawang',
  );
  String _kurirDipilih = 'Kurir Internal Bale Ikan (Mobil Box Pendingin Es) - Rp 5.000';
  String _metodeBayar = 'QRIS Bale Ikan (Simulasi Lunas)';

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2B2D42);

  final Map<String, int> _hargaMap = {
    'Ikan Gabus Segar': 45000,
    'Ikan Patin Tambak': 30000,
    'Ikan Tuna Laut': 75000,
    'Ikan Tongkol Asap': 35000,
    'Ikan Mujair Nila Segar': 32000,
    'Ikan Gurame Padat': 55000,
    'Ikan Kakap Merah': 85000,
  };

  String _formatRupiah(int angka) {
    String result = angka.toString();
    if (result.length > 3) {
      result = result.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }
    return result;
  }

  int get _ongkir {
    return _kurirDipilih.contains('10.000') ? 10000 : 5000;
  }

  int get _totalBelanja {
    int total = _ongkir;
    widget.keranjang.forEach((nama, qty) {
      total += (_hargaMap[nama] ?? 40000) * qty;
    });
    return total;
  }

  Future<void> _prosesCheckout() async {
    final rincian = widget.keranjang.entries.map((e) => '${e.value} kg ${e.key}').join(', ');
    final kodeTrx = 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final totalFormatted = 'Rp ${_formatRupiah(_totalBelanja)}';

    final pesananBaru = PesananModel(
      id: kodeTrx,
      customerNama: 'Budi Santoso (Customer)',
      alamat: _alamatCtrl.text,
      items: rincian,
      totalHarga: totalFormatted,
      metodeBayar: _metodeBayar,
      jenisPengiriman: _kurirDipilih,
      status: 'Menunggu Konfirmasi Penjual',
      tokoLat: -6.3050,
      tokoLng: 107.2960,
      custLat: -6.3280,
      custLng: 107.2905,
      kurirLat: -6.3050,
      kurirLng: 107.2960,
      waktu: 'Baru saja',
    );

    await RealtimeSyncService.instance.buatPesananBaru(pesananBaru);

    if (!mounted) return;

    // Tampilkan dialog sukses bergaya SweetAlert sebelum pindah tab
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primarySeafoam.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: primarySeafoam, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pesanan Berhasil Dibuat!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 8),
            Text(
              'Kode Pesanan: $kodeTrx\nTotal: $totalFormatted\n\nNotifikasi pesanan telah dikirim ke Penjual Ikan untuk segera dikemas dan diserahkan ke Kurir.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarySeafoam,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Lihat Status & Lacak Pesanan',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    widget.onCheckoutSukses();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.keranjang.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Keranjang belanja masih kosong.\nSilakan pilih ikan segar di menu Beranda!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keranjang Belanja Ikan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
          ),
          const SizedBox(height: 16),
          ...widget.keranjang.entries.map((e) {
            final hargaSatuan = _hargaMap[e.key] ?? 40000;
            final subtotal = hargaSatuan * e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F7F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.set_meal, color: primarySeafoam),
                ),
                title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                subtitle: Text(
                  '${e.value} kg x Rp ${_formatRupiah(hargaSatuan)} = Rp ${_formatRupiah(subtotal)}',
                  style: const TextStyle(fontSize: 12.5, color: accentCoral, fontWeight: FontWeight.w600),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: accentCoral),
                  onPressed: () => widget.onHapusItem(e.key),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          TextField(
            controller: _alamatCtrl,
            decoration: InputDecoration(
              labelText: 'Alamat Rumah Pengantaran (Karawang)',
              prefixIcon: const Icon(Icons.location_on, color: primarySeafoam),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _kurirDipilih,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Pilih Armada Kurir Pengiriman Ikan',
              prefixIcon: const Icon(Icons.local_shipping_outlined, color: primarySeafoam),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Kurir Internal Bale Ikan (Mobil Box Pendingin Es) - Rp 5.000',
                child: Text('Mobil Box Pendingin Es - Rp 5.000', overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem(
                value: 'Kurir Instan Tangki Oksigen Hidup - Rp 10.000',
                child: Text('Mobil Tangki Oksigen Hidup - Rp 10.000', overflow: TextOverflow.ellipsis),
              ),
            ],
            onChanged: (v) => setState(() => _kurirDipilih = v!),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _metodeBayar,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Metode Pembayaran (Simulasi Gratis)',
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: primarySeafoam),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: const [
              DropdownMenuItem(value: 'QRIS Bale Ikan (Simulasi Lunas)', child: Text('QRIS Bale Ikan (Simulasi Lunas)')),
              DropdownMenuItem(value: 'Transfer Bank Virtual Account', child: Text('Transfer Bank Virtual Account')),
              DropdownMenuItem(value: 'COD (Bayar Tunai ke Kurir)', child: Text('COD (Bayar Tunai ke Kurir)')),
            ],
            onChanged: (v) => setState(() => _metodeBayar = v!),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ongkos Kirim Kurir Pendingin', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Text('Rp ${_formatRupiah(_ongkir)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                    Text(
                      'Rp ${_formatRupiah(_totalBelanja)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: accentCoral),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentCoral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _prosesCheckout,
              icon: const Icon(Icons.payment),
              label: Text(
                'Bayar & Buat Pesanan (Rp ${_formatRupiah(_totalBelanja)})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}