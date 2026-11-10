class Transaksi {
  String? id;
  String kodeTrx;
  String pelangganId;
  String produkId;
  String jumlahKg;
  String totalHarga;
  String statusBayar;
  String tanggal;

  Transaksi({
    this.id,
    required this.kodeTrx,
    required this.pelangganId,
    required this.produkId,
    required this.jumlahKg,
    required this.totalHarga,
    required this.statusBayar,
    required this.tanggal,
  });

  // FUNGSI JENIUS: Parsing JSON yang kebal terhadap tipe data int/null dari Database
  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
        id: json["id"]?.toString(),
        kodeTrx: json["kode_trx"]?.toString() ?? '-',
        pelangganId: json["pelanggan_id"]?.toString() ?? '-',
        produkId: json["produk_id"]?.toString() ?? '-',
        jumlahKg: json["jumlah_kg"]?.toString() ?? '0',
        totalHarga: json["total_harga"]?.toString() ?? '0',
        statusBayar: json["status_bayar"]?.toString() ?? 'Pending',
        tanggal: json["tanggal"]?.toString() ?? '-',
      );

  // Mengubah object menjadi JSON untuk dikirim ke API / Database
  Map<String, dynamic> toJson() => {
        // id biasanya tidak disertakan saat create (insert) ke database, 
        // tapi jika butuh untuk update, bisa di-uncomment baris di bawah:
        // "id": id,
        "kode_trx": kodeTrx,
        "pelanggan_id": pelangganId,
        "produk_id": produkId,
        "jumlah_kg": jumlahKg,
        "total_harga": totalHarga,
        "status_bayar": statusBayar,
        "tanggal": tanggal,
      };
}