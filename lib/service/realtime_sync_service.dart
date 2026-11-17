import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/pesanan_model.dart';

class RealtimeSyncService extends ChangeNotifier {
  static final RealtimeSyncService instance = RealtimeSyncService._internal();
  RealtimeSyncService._internal() {
    _muatGambarLokal();
    _startRealtimeSync();
  }

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  Timer? _syncTimer;

  // Penyimpanan gambar produk & profil lintas aktor
  final Map<String, Uint8List> _fotoProdukMap = {};
  final Map<String, Uint8List> _fotoProfilMap = {};
  final Map<String, String> _hashGambarTersimpan = {};

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

  Uint8List? getFotoProduk(String namaIkan) => _fotoProdukMap[namaIkan];
  Uint8List? getFotoProfil(String role) => _fotoProfilMap[role];

  String get _baseUrl => kIsWeb ? Uri.base.origin : 'http://localhost:8080';

  Future<void> _muatGambarLokal() async {
    final prefs = await SharedPreferences.getInstance();
    bool adaPerubahan = false;

    for (final key in prefs.getKeys()) {
      if (key.startsWith('foto_ikan_')) {
        final nama = key.replaceFirst('foto_ikan_', '');
        final b64 = prefs.getString(key) ?? '';
        if (_hashGambarTersimpan[key] != b64) {
          _hashGambarTersimpan[key] = b64;
          _fotoProdukMap[nama] = b64.isNotEmpty ? base64Decode(b64) : Uint8List(0);
          adaPerubahan = true;
        }
      } else if (key.startsWith('foto_profil_')) {
        final role = key.replaceFirst('foto_profil_', '');
        final b64 = prefs.getString(key) ?? '';
        if (_hashGambarTersimpan[key] != b64) {
          _hashGambarTersimpan[key] = b64;
          _fotoProfilMap[role] = b64.isNotEmpty ? base64Decode(b64) : Uint8List(0);
          adaPerubahan = true;
        }
      }
    }

    if (adaPerubahan) notifyListeners();
  }

  Future<void> simpanFotoProduk(String namaIkan, Uint8List bytes) async {
    _fotoProdukMap[namaIkan] = bytes;
    final b64 = bytes.isNotEmpty ? base64Encode(bytes) : '';
    final key = 'foto_ikan_$namaIkan';
    _hashGambarTersimpan[key] = b64;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (b64.isNotEmpty) {
      await prefs.setString(key, b64);
    } else {
      await prefs.remove(key);
    }

    try {
      await _dio.post('$_baseUrl/api/images/product', data: {
        'nama': namaIkan,
        'base64': b64,
      });
    } catch (_) {}
  }

  Future<void> simpanFotoProfil(String role, Uint8List bytes) async {
    _fotoProfilMap[role] = bytes;
    final b64 = bytes.isNotEmpty ? base64Encode(bytes) : '';
    final key = 'foto_profil_$role';
    _hashGambarTersimpan[key] = b64;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (b64.isNotEmpty) {
      await prefs.setString(key, b64);
    } else {
      await prefs.remove(key);
    }

    try {
      await _dio.post('$_baseUrl/api/images/profile', data: {
        'role': role,
        'base64': b64,
      });
    } catch (_) {}
  }

  void _startRealtimeSync() {
    fetchOrders();
    fetchImages();
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchOrders();
      fetchImages();
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

  Future<void> fetchImages() async {
    try {
      final response = await _dio.get('$_baseUrl/api/images');
      if (response.statusCode == 200 && response.data is Map) {
        final prefs = await SharedPreferences.getInstance();
        bool adaPerubahan = false;

        final prodMap = response.data['product_images'];
        if (prodMap is Map) {
          for (final entry in prodMap.entries) {
            final nama = entry.key.toString();
            final b64 = entry.value.toString();
            final key = 'foto_ikan_$nama';
            if (_hashGambarTersimpan[key] != b64) {
              _hashGambarTersimpan[key] = b64;
              _fotoProdukMap[nama] = b64.isNotEmpty ? base64Decode(b64) : Uint8List(0);
              await prefs.setString(key, b64);
              adaPerubahan = true;
            }
          }
        }

        final profMap = response.data['profile_images'];
        if (profMap is Map) {
          for (final entry in profMap.entries) {
            final role = entry.key.toString();
            final b64 = entry.value.toString();
            final key = 'foto_profil_$role';
            if (_hashGambarTersimpan[key] != b64) {
              _hashGambarTersimpan[key] = b64;
              _fotoProfilMap[role] = b64.isNotEmpty ? base64Decode(b64) : Uint8List(0);
              await prefs.setString(key, b64);
              adaPerubahan = true;
            }
          }
        }

        if (adaPerubahan) notifyListeners();
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