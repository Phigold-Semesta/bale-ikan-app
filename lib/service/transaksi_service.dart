import '../model/transaksi.dart';

class TransaksiService {
  // Data dummy disesuaikan dengan Model Transaksi yang baru
  static final List<Transaksi> _dataTransaksi = [
    Transaksi(
      id: '1',
      kodeTrx: 'TRX-88901',
      pelangganId: 'PLG-001',
      // Sementara produkId diisi nama agar UI tidak rusak
      produkId: 'Ikan Gabus Segar', 
      jumlahKg: '2', // Sekarang tipe String
      totalHarga: '90000', // Sekarang tipe String
      tanggal: '03 Nov 2026',
      statusBayar: 'Lunas', // Menggantikan status
    ),
    Transaksi(
      id: '2',
      kodeTrx: 'TRX-88842',
      pelangganId: 'PLG-002',
      produkId: 'Ikan Patin Tambak',
      jumlahKg: '5',
      totalHarga: '150000',
      tanggal: '01 Nov 2026',
      statusBayar: 'Dikirim',
    ),
  ];

  // READ: Mengambil semua data transaksi
  Future<List<Transaksi>> getRiwayatTransaksi() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dataTransaksi;
  }

  // UPDATE: Fungsi Khusus Admin untuk mengubah status pesanan
  Future<void> updateStatusTransaksi(String kodeTrx, String statusBaru) async {
    await Future.delayed(const Duration(milliseconds: 300));
    int index = _dataTransaksi.indexWhere((t) => t.kodeTrx == kodeTrx);
    if (index != -1) {
      _dataTransaksi[index].statusBayar = statusBaru;
    }
  }
}