class Pelanggan {
  String? id;
  String namaPelanggan;
  String noHp;
  String alamat;

  Pelanggan({
    this.id,
    required this.namaPelanggan,
    required this.noHp,
    required this.alamat,
  });

  factory Pelanggan.fromJson(Map<String, dynamic> json) => Pelanggan(
        id: json["id"],
        namaPelanggan: json["nama_pelanggan"],
        noHp: json["no_hp"],
        alamat: json["alamat"],
      );

  Map<String, dynamic> toJson() => {
        "nama_pelanggan": namaPelanggan,
        "no_hp": noHp,
        "alamat": alamat,
      };
}