class ProdukIkan {
  String? id;
  String namaIkan;
  String hargaPerKg;

  ProdukIkan({this.id, required this.namaIkan, required this.hargaPerKg});

  factory ProdukIkan.fromJson(Map<String, dynamic> json) =>
      ProdukIkan(id: json["id"], namaIkan: json["nama_ikan"], hargaPerKg: json["harga_per_kg"]);

  Map<String, dynamic> toJson() => {"nama_ikan": namaIkan, "harga_per_kg": hargaPerKg};
}