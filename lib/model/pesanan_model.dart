class PesananModel {
  String id;
  String customerNama;
  String alamat;
  String items;
  String totalHarga;
  String metodeBayar;
  String jenisPengiriman;
  String status;
  double tokoLat;
  double tokoLng;
  double custLat;
  double custLng;
  double kurirLat;
  double kurirLng;
  String waktu;

  PesananModel({
    required this.id,
    required this.customerNama,
    required this.alamat,
    required this.items,
    required this.totalHarga,
    required this.metodeBayar,
    required this.jenisPengiriman,
    required this.status,
    required this.tokoLat,
    required this.tokoLng,
    required this.custLat,
    required this.custLng,
    required this.kurirLat,
    required this.kurirLng,
    required this.waktu,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) => PesananModel(
        id: json['id'] ?? '',
        customerNama: json['customerNama'] ?? '',
        alamat: json['alamat'] ?? '',
        items: json['items'] ?? '',
        totalHarga: json['totalHarga'] ?? '',
        metodeBayar: json['metodeBayar'] ?? '',
        jenisPengiriman: json['jenisPengiriman'] ?? 'Kurir Pendingin Es Bale Ikan',
        status: json['status'] ?? 'Menunggu Konfirmasi Penjual',
        tokoLat: (json['tokoLat'] as num?)?.toDouble() ?? -6.3050,
        tokoLng: (json['tokoLng'] as num?)?.toDouble() ?? 107.2960,
        custLat: (json['custLat'] as num?)?.toDouble() ?? -6.3260,
        custLng: (json['custLng'] as num?)?.toDouble() ?? 107.2910,
        kurirLat: (json['kurirLat'] as num?)?.toDouble() ?? -6.3050,
        kurirLng: (json['kurirLng'] as num?)?.toDouble() ?? 107.2960,
        waktu: json['waktu'] ?? 'Baru saja',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerNama': customerNama,
        'alamat': alamat,
        'items': items,
        'totalHarga': totalHarga,
        'metodeBayar': metodeBayar,
        'jenisPengiriman': jenisPengiriman,
        'status': status,
        'tokoLat': tokoLat,
        'tokoLng': tokoLng,
        'custLat': custLat,
        'custLng': custLng,
        'kurirLat': kurirLat,
        'kurirLng': kurirLng,
        'waktu': waktu,
      };
}