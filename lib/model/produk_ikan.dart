class ProdukIkan {
  String? id;
  String namaIkan;
  String kategori;
  String harga;
  String stok;
  String? gambar; // Ditambahkan: untuk menyimpan data gambar produk

  ProdukIkan({
    this.id,
    required this.namaIkan,
    required this.kategori,
    required this.harga,
    required this.stok,
    this.gambar, // Ditambahkan ke constructor
  });

  factory ProdukIkan.fromJson(Map<String, dynamic> json) => ProdukIkan(
        id: json["id"],
        namaIkan: json["nama_ikan"] ?? '',
        kategori: json["kategori"] ?? '',
        harga: json["harga"] ?? '',
        stok: json["stok"] ?? '',
        gambar: json["gambar"], // Mapping dari JSON
      );

  Map<String, dynamic> toJson() => {
        "nama_ikan": namaIkan,
        "kategori": kategori,
        "harga": harga,
        "stok": stok,
        "gambar": gambar, // Mapping ke JSON
      };
}