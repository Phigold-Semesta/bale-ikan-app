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
  String _kurirDipilih = 'Kurir Internal Bale Ikan (Box Pendingin Es) - Rp 5.000';
  String _metodeBayar = 'QRIS Bale Ikan (Simulasi Lunas)';

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2B2D42);

  final Map<String, int> _hargaMap = {
    'Ikan Gabus Segar': 45000,
    'Ikan Patin Tambak': 30000,
    'Ikan Tuna Laut': 75000,
    'Ikan Tongkol Asap': 35000,
    'Ikan Gurame Padat': 55000,
    'Ikan Kakap Merah': 85000,
  };

  int get _totalBelanja {
    int total = 5000;
    widget.keranjang.forEach((nama, qty) {
      total += (_hargaMap[nama] ?? 40000) * qty;
    });
    return total;
  }

  Future<void> _prosesCheckout() async {
    final rincian = widget.keranjang.entries.map((e) => '${e.value} kg ${e.key}').join(', ');
    final pesananBaru = PesananModel(
      id: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      customerNama: 'Budi Santoso (Customer)',
      alamat: _alamatCtrl.text,
      items: rincian,
      totalHarga: 'Rp $_totalBelanja',
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
    widget.onCheckoutSukses();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.keranjang.isEmpty) {
      return const Center(
        child: Text('Keranjang belanja masih kosong.\nSilakan pilih ikan segar di menu Belanja!', textAlign: TextAlign.center),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daftar Ikan di Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
          const SizedBox(height: 12),
          ...widget.keranjang.entries.map((e) {
            final hargaSatuan = _hargaMap[e.key] ?? 40000;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.set_meal, color: primarySeafoam),
                title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${e.value} kg x Rp $hargaSatuan'),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _kurirDipilih,
            decoration: InputDecoration(
              labelText: 'Pilih Layanan Pengiriman Ikan',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Kurir Internal Bale Ikan (Box Pendingin Es) - Rp 5.000',
                child: Text('Kurir Pendingin Es - Rp 5.000'),
              ),
              DropdownMenuItem(
                value: 'Kurir Instan Oksigen Hidup - Rp 10.000',
                child: Text('Kurir Instan Oksigen Hidup - Rp 10.000'),
              ),
            ],
            onChanged: (v) => setState(() => _kurirDipilih = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _metodeBayar,
            decoration: InputDecoration(
              labelText: 'Metode Pembayaran (Simulasi Gratis)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(value: 'QRIS Bale Ikan (Simulasi Lunas)', child: Text('QRIS Bale Ikan (Simulasi Lunas)')),
              DropdownMenuItem(value: 'Transfer Bank Virtual Account', child: Text('Transfer Bank Virtual Account')),
              DropdownMenuItem(value: 'COD (Bayar Tunai ke Kurir)', child: Text('COD (Bayar Tunai ke Kurir)')),
            ],
            onChanged: (v) => setState(() => _metodeBayar = v!),
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
              ),
              onPressed: _prosesCheckout,
              icon: const Icon(Icons.payment),
              label: Text(
                'Bayar & Buat Pesanan (Rp $_totalBelanja)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}