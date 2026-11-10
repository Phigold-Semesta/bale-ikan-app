import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/transaksi.dart';

class TransaksiService {
  Future<List<Transaksi>> listData() async {
    final Response response = await ApiClient().get('transaksi');
    final List data = response.data as List;
    List<Transaksi> result = data.map((json) => Transaksi.fromJson(json)).toList();
    return result;
  }

  Future<Transaksi> simpan(Transaksi transaksi) async {
    var data = transaksi.toJson();
    final Response response = await ApiClient().post('transaksi', data);
    Transaksi result = Transaksi.fromJson(response.data);
    return result;
  }

  Future<Transaksi> ubah(Transaksi transaksi, String id) async {
    var data = transaksi.toJson();
    final Response response = await ApiClient().put('transaksi/$id', data);
    Transaksi result = Transaksi.fromJson(response.data);
    return result;
  }

  Future<Transaksi> getById(String id) async {
    final Response response = await ApiClient().get('transaksi/$id');
    Transaksi result = Transaksi.fromJson(response.data);
    return result;
  }

  Future<Transaksi> hapus(Transaksi transaksi) async {
    final Response response = await ApiClient().delete('transaksi/${transaksi.id}');
    Transaksi result = Transaksi.fromJson(response.data);
    return result;
  }
}