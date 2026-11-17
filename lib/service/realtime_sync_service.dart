import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/pesanan_model.dart';

class RealtimeSyncService extends ChangeNotifier {
  static final RealtimeSyncService instance = RealtimeSyncService._internal();
  RealtimeSyncService._internal() {
    _startRealtimeSync();
  }

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  Timer? _syncTimer;

  List<PesananModel> _daftarPesanan = [
    PesananModel(
      id: 'TRX-88901',
      customerNama: 'Budi Santoso (Customer)',
      alamat: 'Perum Galuh Mas Blok A2, Telukjambe, Karawang',
      items: '2 kg Ikan Gabus Segar, 1 kg Ikan Patin Tambak',
      totalHarga: 'Rp 125.000',
      metodeBayar: 'QRIS Bale Ikan (Lunas)',
      jenisPengiriman: 'Kurir Internal Pendingin Es',
      status: 'Sedang Diantar Kurir',
      tokoLat: -6.3050,
      tokoLng: 107.2960,
      custLat: -6.3260,
      custLng: 107.2910,
      kurirLat: -6.3155,
      kurirLng: 107.2935,
      waktu: 'Hari ini, 10:30',
    ),
  ];

  List<PesananModel> get daftarPesanan => _daftarPesanan;

  String get _baseUrl => kIsWeb ? Uri.base.origin : 'http://localhost:8080';

  void _startRealtimeSync() {
    fetchOrders();
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchOrders();
    });
  }

  Future<void> fetchOrders() async {
    try {
      final response = await _dio.get('$_baseUrl/api/orders');
      if (response.statusCode == 200 && response.data is List) {
        _daftarPesanan = (response.data as List)
            .map((item) => PesananModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> buatPesananBaru(PesananModel pesanan) async {
    _daftarPesanan.insert(0, pesanan);
    notifyListeners();
    try {
      await _dio.post('$_baseUrl/api/orders/add', data: pesanan.toJson());
    } catch (_) {}
  }

  Future<void> updateStatusPesanan(String id, String statusBaru) async {
    final idx = _daftarPesanan.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _daftarPesanan[idx].status = statusBaru;
      notifyListeners();
      try {
        await _dio.post('$_baseUrl/api/orders/update', data: {
          'id': id,
          'status': statusBaru,
        });
      } catch (_) {}
    }
  }

  Future<void> gerakkanKurirMendekatiCustomer(String id) async {
    final idx = _daftarPesanan.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final p = _daftarPesanan[idx];

    final double dLat = (p.custLat - p.kurirLat) * 0.35;
    final double dLng = (p.custLng - p.kurirLng) * 0.35;

    p.kurirLat += dLat;
    p.kurirLng += dLng;

    if ((p.custLat - p.kurirLat).abs() < 0.0007 &&
        (p.custLng - p.kurirLng).abs() < 0.0007) {
      p.kurirLat = p.custLat;
      p.kurirLng = p.custLng;
      p.status = 'Tiba di Tujuan (Selesai)';
    } else {
      p.status = 'Sedang Diantar Kurir';
    }

    notifyListeners();
    try {
      await _dio.post('$_baseUrl/api/orders/update', data: {
        'id': p.id,
        'status': p.status,
        'kurirLat': p.kurirLat,
        'kurirLng': p.kurirLng,
      });
    } catch (_) {}
  }
}