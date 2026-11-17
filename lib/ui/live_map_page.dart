import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../model/pesanan_model.dart';
import '../service/realtime_sync_service.dart';

class LiveMapPage extends StatelessWidget {
  final String pesananId;
  final String roleAktor; // 'admin', 'customer', atau 'kurir'

  const LiveMapPage({
    super.key,
    required this.pesananId,
    required this.roleAktor,
  });

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2B2D42);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RealtimeSyncService.instance,
      builder: (context, _) {
        final daftar = RealtimeSyncService.instance.daftarPesanan;
        final PesananModel pesanan = daftar.firstWhere(
          (e) => e.id == pesananId,
          orElse: () => daftar.first,
        );

        final LatLng titikToko = LatLng(pesanan.tokoLat, pesanan.tokoLng);
        final LatLng titikKurir = LatLng(pesanan.kurirLat, pesanan.kurirLng);
        final LatLng titikCustomer = LatLng(pesanan.custLat, pesanan.custLng);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: darkText,
            elevation: 0,
            title: Text(
              'Live Map Tracking • ${pesanan.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: titikKurir,
                    initialZoom: 14.2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.baleikan.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [titikToko, titikKurir, titikCustomer],
                          strokeWidth: 4.5,
                          color: primarySeafoam,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: titikToko,
                          width: 115,
                          height: 65,
                          child: _markerItem(
                            ikon: Icons.storefront,
                            warna: primarySeafoam,
                            teks: 'Toko Bale Ikan',
                          ),
                        ),
                        Marker(
                          point: titikCustomer,
                          width: 115,
                          height: 65,
                          child: _markerItem(
                            ikon: Icons.home,
                            warna: accentCoral,
                            teks: 'Rumah Pembeli',
                          ),
                        ),
                        Marker(
                          point: titikKurir,
                          width: 125,
                          height: 70,
                          child: _markerItem(
                            ikon: Icons.delivery_dining,
                            warna: darkText,
                            teks: 'Kurir Pendingin',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pesanan.customerNama,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primarySeafoam.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            pesanan.status,
                            style: const TextStyle(color: primarySeafoam, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Tujuan: ${pesanan.alamat}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    Text('Muatan: ${pesanan.items}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      'GPS Kurir Live: ${pesanan.kurirLat.toStringAsFixed(4)}, ${pesanan.kurirLng.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: accentCoral, fontWeight: FontWeight.bold),
                    ),
                    if (roleAktor == 'kurir') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primarySeafoam,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                RealtimeSyncService.instance.gerakkanKurirMendekatiCustomer(pesanan.id);
                              },
                              icon: const Icon(Icons.navigation),
                              label: const Text('Majukan Posisi Kurir di Peta'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _markerItem({required IconData ikon, required Color warna, required String teks}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: warna, borderRadius: BorderRadius.circular(6)),
          child: Text(teks, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 2),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: Icon(ikon, color: warna, size: 20),
        ),
      ],
    );
  }
}