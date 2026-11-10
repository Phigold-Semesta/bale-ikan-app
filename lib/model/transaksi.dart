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

  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
        id: json["id"],
        kodeTrx: json["kode_trx"],
        pelangganId: json["pelanggan_id"],
        produkId: json["produk_id"],
        jumlahKg: json["jumlah_kg"],
        totalHarga: json["total_harga"],
        statusBayar: json["status_bayar"],
        tanggal: json["tanggal"],
      );

  Map<String, dynamic> toJson() => {
        "kode_trx": kodeTrx,
        "pelanggan_id": pelangganId,
        "produk_id": produkId,
        "jumlah_kg": jumlahKg,
        "total_harga": totalHarga,
        "status_bayar": statusBayar,
        "tanggal": tanggal,
      };
}