import 'package:flutter/material.dart';
import '../../service/realtime_sync_service.dart';
import '../live_map_page.dart';

class CustomerPesanan extends StatelessWidget {
  const CustomerPesanan({super.key});

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2B2D42);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RealtimeSyncService.instance,
      builder: (context, _) {
        final daftar = RealtimeSyncService.instance.daftarPesanan;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: daftar.length,
          itemBuilder: (context, index) {
            final p = daftar[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primarySeafoam.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.status,
                          style: const TextStyle(color: primarySeafoam, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(p.items, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Alamat Tujuan: ${p.alamat}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  Text('Total: ${p.totalHarga} • ${p.metodeBayar}', style: const TextStyle(fontSize: 13, color: accentCoral, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primarySeafoam,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveMapPage(pesananId: p.id, roleAktor: 'customer'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Lacak Posisi Kurir di Peta (Real-Time)'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}