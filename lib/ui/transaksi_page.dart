import 'package:flutter/material.dart';

/// Model sederhana untuk satu transaksi.
class Transaksi {
  final String kode;
  final String item;
  final int total; // dalam Rupiah
  final String status; // Lunas, Dikirim, Menunggu
  final String tanggal;

  const Transaksi({
    required this.kode,
    required this.item,
    required this.total,
    required this.status,
    required this.tanggal,
  });

  /// Contoh: 90000 -> "Rp 90.000"
  String get totalFormat {
    final s = total.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }
}

class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key});

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  static const List<Transaksi> _riwayatTransaksi = [
    Transaksi(
      kode: 'TRX-88901',
      item: '2 kg Ikan Gabus Segar',
      total: 90000,
      status: 'Lunas',
      tanggal: '03 Nov 2026',
    ),
    Transaksi(
      kode: 'TRX-88842',
      item: '5 kg Ikan Patin Tambak',
      total: 150000,
      status: 'Dikirim',
      tanggal: '01 Nov 2026',
    ),
  ];

  /// Warna utama berdasarkan status.
  static Color _warnaStatus(String status) {
    switch (status) {
      case 'Lunas':
        return primarySeafoam;
      case 'Dikirim':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Warna latar badge (transparan) berdasarkan status.
  static Color _latarStatus(String status) {
    switch (status) {
      case 'Lunas':
        return const Color(0x1A00A896);
      case 'Dikirim':
        return const Color(0x1AFF9800);
      default:
        return const Color(0x1A9E9E9E);
    }
  }

  static IconData _ikonStatus(String status) {
    switch (status) {
      case 'Lunas':
        return Icons.check_circle;
      case 'Dikirim':
        return Icons.local_shipping;
      default:
        return Icons.hourglass_bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBelanja = _riwayatTransaksi.fold<int>(0, (jumlah, t) => jumlah + t.total);
    final totalFormat = Transaksi(
      kode: '',
      item: '',
      total: totalBelanja,
      status: '',
      tanggal: '',
    ).totalFormat;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _riwayatTransaksi.isEmpty
          ? _buildKosong()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRingkasan(_riwayatTransaksi.length, totalFormat),
                const SizedBox(height: 16),
                for (final trx in _riwayatTransaksi) _buildKartuTransaksi(trx),
              ],
            ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Belum ada transaksi',
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasan(int jumlahTransaksi, String totalFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primarySeafoam,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Belanja',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  totalFormat,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Transaksi',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '$jumlahTransaksi',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKartuTransaksi(Transaksi trx) {
    final warna = _warnaStatus(trx.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trx.kode,
                style: const TextStyle(fontWeight: FontWeight.bold, color: darkText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _latarStatus(trx.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_ikonStatus(trx.status), size: 12, color: warna),
                    const SizedBox(width: 4),
                    Text(
                      trx.status,
                      style: TextStyle(color: warna, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            trx.item,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkText),
          ),
          const SizedBox(height: 4),
          Text(
            'Tanggal: ${trx.tanggal}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                trx.totalFormat,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentCoral),
              ),
            ],
          ),
        ],
      ),
    );
  }
}