import '../model/produk_ikan.dart';

class ProdukService {
  // Database lokal sementara (In-Memory List)
  static final List<ProdukIkan> _dataProduk = [
    ProdukIkan(
        id: '1',
        namaIkan: 'Ikan Gabus Segar',
        kategori: 'Air Tawar',
        harga: '45000',
        stok: '15'),
    ProdukIkan(
        id: '2',
        namaIkan: 'Ikan Patin Tambak',
        kategori: 'Air Tawar',
        harga: '30000',
        stok: '25'),
    ProdukIkan(
        id: '3',
        namaIkan: 'Ikan Tuna Laut',
        kategori: 'Ikan Laut',
        harga: '75000',
        stok: '10'),
    ProdukIkan(
        id: '4',
        namaIkan: 'Ikan Tongkol Asap',
        kategori: 'Ikan Laut',
        harga: '35000',
        stok: '20'),
  ];

  // READ: Mengambil semua data
  Future<List<ProdukIkan>> listData() async {
    // Simulasi loading/delay jaringan selama 500 milidetik
    await Future.delayed(const Duration(milliseconds: 500));
    return _dataProduk;
  }

  // CREATE: Menambah data baru
  Future<ProdukIkan> simpan(ProdukIkan produk) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate ID otomatis (berdasarkan panjang list + 1)
    produk.id = (DateTime.now().millisecondsSinceEpoch).toString(); 
    _dataProduk.add(produk);
    
    return produk;
  }

  // UPDATE: Mengubah data yang ada
  Future<ProdukIkan> ubah(ProdukIkan produk, String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Cari index produk berdasarkan ID
    int index = _dataProduk.indexWhere((p) => p.id == id);
    if (index != -1) {
      // Pertahankan gambar lama jika tidak diubah via form update biasa
      produk.gambar = _dataProduk[index].gambar;
      produk.id = id;
      _dataProduk[index] = produk;
    }
    
    return produk;
  }

  // UPDATE GAMBAR KHUSUS (Dipanggil dari Modal)
  Future<void> updateGambar(String id, String? imagePath) async {
    await Future.delayed(const Duration(milliseconds: 300));
    int index = _dataProduk.indexWhere((p) => p.id == id);
    if (index != -1) {
      _dataProduk[index].gambar = imagePath;
    }
  }

  // READ DETAIL: Mengambil 1 data berdasarkan ID
  Future<ProdukIkan> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dataProduk.firstWhere((p) => p.id == id);
  }

  // DELETE: Menghapus data
  Future<ProdukIkan> hapus(ProdukIkan produk) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dataProduk.removeWhere((p) => p.id == produk.id);
    return produk;
  }
}