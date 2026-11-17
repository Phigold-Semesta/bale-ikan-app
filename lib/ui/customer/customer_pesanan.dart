import 'package:flutter/material.dart';
import '../../model/pesanan_model.dart';
import '../../service/realtime_sync_service.dart';
import '../live_map_page.dart';

class CustomerPesanan extends StatelessWidget {
  const CustomerPesanan({super.key});

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  int _ekstrakAngka(String teksHarga) {
    final bersih = teksHarga.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(bersih) ?? 0;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: ListenableBuilder(
        listenable: RealtimeSyncService.instance,
        builder: (context, _) {
          final daftar = RealtimeSyncService.instance.daftarPesanan;

          int totalBelanjaCustomer = 0;
          for (final p in daftar) {
            totalBelanjaCustomer += _ekstrakAngka(p.totalHarga);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat Pesanan & Pelacakan Kurir',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
                ),
                const SizedBox(height: 20),

                // Card Summary Customer (Seragam dengan halaman Transaksi Admin)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primarySeafoam,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x3300A896), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Belanja Saya', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${_formatRupiah(totalBelanjaCustomer)}',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Pesanan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${daftar.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daftar.length,
                  itemBuilder: (context, index) {
                    return _buildKartuPesananCustomer(context, daftar[index]);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKartuPesananCustomer(BuildContext context, PesananModel p) {
    Color bgColor = const Color(0xFFE8F5E9);
    Color textColor = primarySeafoam;
    IconData statusIcon = Icons.info_outline;
    String infoTahapan = 'Kurir sedang dalam perjalanan mengantar ikan segar ke lokasi Anda.';

    final statusLower = p.status.toLowerCase();
    final bool menungguPenjual = statusLower.contains('menunggu');

    if (menungguPenjual) {
      bgColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFEF6C00);
      statusIcon = Icons.hourglass_top_rounded;
      infoTahapan = 'Menunggu Penjual Ikan mengemas es & menugaskan Mobil Box Kurir.';
    } else if (statusLower.contains('siap')) {
      bgColor = const Color(0xFFE0F2F1);
      textColor = primarySeafoam;
      statusIcon = Icons.inventory_2_outlined;
      infoTahapan = 'Ikan sudah dikemas es oleh Penjual & siap dibawa oleh Kurir.';
    } else if (statusLower.contains('diantar') || statusLower.contains('dikirim')) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
      statusIcon = Icons.local_shipping_outlined;
      infoTahapan = 'Mobil Box Kurir sedang bergerak menuju alamat rumah Anda.';
    } else if (statusLower.contains('tiba') || statusLower.contains('selesai')) {
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1565C0);
      statusIcon = Icons.done_all;
      infoTahapan = 'Pesanan ikan segar telah tiba di lokasi tujuan.';
    }

    final int nominal = _ekstrakAngka(p.totalHarga);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.id,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: textColor),
                    const SizedBox(width: 4),
                    Text(
                      p.status,
                      style: TextStyle(color: textColor, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Text(
            p.items,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: primarySeafoam),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Alamat Tujuan: ${p.alamat}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.payment_outlined, size: 15, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Metode: ${p.metodeBayar} • ${p.waktu}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, size: 16, color: textColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    infoTahapan,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey[800], fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              Text(
                'Rp ${_formatRupiah(nominal)}',
                style: const TextStyle(color: accentCoral, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: menungguPenjual ? Colors.blueGrey : primarySeafoam,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveMapPage(pesananId: p.id, roleAktor: 'customer'),
                  ),
                );
              },
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: Text(
                menungguPenjual
                    ? 'Lihat Titik Lokasi Toko & Rumah di Peta'
                    : 'Lacak Mobil Box Kurir di Peta (Real-Time)',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}