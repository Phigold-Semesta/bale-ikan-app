import 'package:flutter/material.dart';
import 'package:bale_ikan_app/model/pesanan_model.dart';
import 'package:bale_ikan_app/model/transaksi.dart';
import 'package:bale_ikan_app/service/realtime_sync_service.dart';
import 'package:bale_ikan_app/service/transaksi_service.dart';
import 'package:bale_ikan_app/ui/live_map_page.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  // Mengambil data secara dinamis
  Stream<List<Transaksi>> _getTransaksiStream() async* {
    yield await TransaksiService().getRiwayatTransaksi();
  }

  // Helper untuk format Rupiah
  String _formatRupiah(int angka) {
    String result = angka.toString();
    if (result.length > 3) {
      result = result.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }
    return result;
  }

  // Helper mengekstrak angka dari string harga
  int _ekstrakAngkaHarga(String teksHarga) {
    final bersih = teksHarga.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(bersih) ?? 0;
  }

  // --- Fungsi Alert Sukses (SweetAlert Style) ---
  void _tampilkanAlertSukses(String pesan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: primarySeafoam.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline, color: primarySeafoam, size: 60),
              ),
              const SizedBox(height: 24),
              const Text("Berhasil!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 8),
              Text(pesan, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
                  onPressed: () {
                    Navigator.pop(dialogContext); // Tutup dialog
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Modal Update Status Transaksi (Khusus Admin) ---
  void _tampilkanModalUpdateStatus(Transaksi trx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext modalContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Status: ${trx.kodeTrx}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 8),
              Text('Ubah status pesanan ini kepada pelanggan & kurir.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 24),
              _buildOpsiStatus(modalContext, trx, 'Lunas', Icons.check_circle, Colors.green),
              const Divider(),
              _buildOpsiStatus(modalContext, trx, 'Siap Dijemput Kurir', Icons.inventory_2, primarySeafoam),
              const Divider(),
              _buildOpsiStatus(modalContext, trx, 'Dikirim', Icons.local_shipping, Colors.orange),
              const Divider(),
              _buildOpsiStatus(modalContext, trx, 'Selesai', Icons.done_all, Colors.blue),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpsiStatus(BuildContext modalContext, Transaksi trx, String status, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text('Tandai sebagai $status', style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () async {
        Navigator.pop(modalContext);
        await TransaksiService().updateStatusTransaksi(trx.kodeTrx, status);
        await RealtimeSyncService.instance.updateStatusPesanan(trx.kodeTrx, status);
        if (mounted) {
          setState(() {}); // Refresh UI
          _tampilkanAlertSukses("Status transaksi ${trx.kodeTrx} berhasil diubah menjadi $status.");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: ListenableBuilder(
        listenable: RealtimeSyncService.instance,
        builder: (context, _) {
          return StreamBuilder<List<Transaksi>>(
            stream: _getTransaksiStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  RealtimeSyncService.instance.daftarPesanan.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: primarySeafoam));
              }

              final List<Transaksi> daftarTransaksiApi = snapshot.data ?? [];
              final List<PesananModel> pesananRealtime = RealtimeSyncService.instance.daftarPesanan;

              // Menggabungkan pesanan real-time 3 aktor dengan daftar transaksi
              final List<Transaksi> daftarTransaksi = [
                ...pesananRealtime.map(
                  (p) => Transaksi(
                    id: p.id,
                    kodeTrx: p.id,
                    produkId: p.items,
                    pelangganId: p.customerNama,
                    jumlahKg: '1',
                    totalHarga: _ekstrakAngkaHarga(p.totalHarga).toString(),
                    statusBayar: p.status,
                    tanggal: p.waktu,
                  ),
                ),
                ...daftarTransaksiApi.where(
                  (apiTrx) => !pesananRealtime.any((p) => p.id == apiTrx.kodeTrx),
                ),
              ];

              // Kalkulasi dinamis untuk header (Menerjemahkan String totalHarga ke int)
              int totalPendapatan = 0;
              for (var trx in daftarTransaksi) {
                totalPendapatan += int.tryParse(trx.totalHarga) ?? 0;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Riwayat Transaksi & Pantauan Kurir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
                    const SizedBox(height: 20),

                    // Card Summary Admin
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primarySeafoam,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x3300A896), blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Belanja', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Rp ${_formatRupiah(totalPendapatan)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Transaksi', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('${daftarTransaksi.length}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // List Riwayat Transaksi
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daftarTransaksi.length,
                      itemBuilder: (context, index) {
                        final trx = daftarTransaksi[index];
                        return _buildKartuTransaksi(trx);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildKartuTransaksi(Transaksi trx) {
    // Menentukan UI Chip berdasarkan statusBayar
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey;
    IconData statusIcon = Icons.info_outline;

    final statusLower = trx.statusBayar.toLowerCase();
    if (statusLower == 'lunas' || statusLower.contains('siap')) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
      statusIcon = Icons.check_circle;
    } else if (statusLower == 'dikirim' || statusLower.contains('diantar')) {
      bgColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFEF6C00);
      statusIcon = Icons.local_shipping;
    } else if (statusLower == 'selesai' || statusLower.contains('tiba')) {
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1565C0);
      statusIcon = Icons.done_all;
    } else if (statusLower.contains('menunggu')) {
      bgColor = const Color(0xFFFFEBEE);
      textColor = accentCoral;
      statusIcon = Icons.notifications_active;
    }

    // Parsing total harga dari string ke int
    int totalPembayaran = int.tryParse(trx.totalHarga) ?? 0;

    // Cek apakah transaksi berasal dari sistem real-time 3 aktor
    PesananModel? pesananLive;
    for (final item in RealtimeSyncService.instance.daftarPesanan) {
      if (item.id == trx.kodeTrx) {
        pesananLive = item;
        break;
      }
    }

    return GestureDetector(
      // Admin bisa mengklik kartu untuk mengubah status pesanan
      onTap: () => _tampilkanModalUpdateStatus(trx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trx.kodeTrx, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: textColor),
                      const SizedBox(width: 4),
                      Text(trx.statusBayar, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
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
              pesananLive != null ? pesananLive.items : '${trx.jumlahKg} kg ${trx.produkId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText),
            ),
            if (pesananLive != null) ...[
              const SizedBox(height: 4),
              Text('Pembeli: ${pesananLive.customerNama}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primarySeafoam)),
              Text('Alamat: ${pesananLive.alamat}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
            const SizedBox(height: 6),
            Text('Tanggal: ${trx.tanggal}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                Text('Rp ${_formatRupiah(totalPembayaran)}', style: const TextStyle(color: accentCoral, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (trx.statusBayar == 'Menunggu Konfirmasi Penjual')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primarySeafoam,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      await RealtimeSyncService.instance.updateStatusPesanan(trx.kodeTrx, 'Siap Dijemput Kurir');
                      if (mounted) {
                        setState(() {});
                        _tampilkanAlertSukses('Pesanan ${trx.kodeTrx} berhasil dikonfirmasi & ditugaskan ke Kurir!');
                      }
                    },
                    icon: const Icon(Icons.local_shipping_outlined, size: 16),
                    label: const Text('Tugaskan Kurir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primarySeafoam),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveMapPage(
                          pesananId: trx.kodeTrx,
                          roleAktor: 'admin',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined, size: 16, color: primarySeafoam),
                  label: const Text('Lacak Peta Kurir (Live)', style: TextStyle(fontSize: 12, color: primarySeafoam, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}