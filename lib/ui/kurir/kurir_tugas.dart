import 'package:flutter/material.dart';
import '../../service/realtime_sync_service.dart';
import '../live_map_page.dart';

class KurirTugas extends StatelessWidget {
  const KurirTugas({super.key});

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2B2D42);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RealtimeSyncService.instance,
      builder: (context, _) {
        final tugasAktif = RealtimeSyncService.instance.daftarPesanan
            .where((p) => p.status != 'Tiba di Tujuan (Selesai)')
            .toList();

        if (tugasAktif.isEmpty) {
          return const Center(
            child: Text('Belum ada tugas pengantaran aktif saat ini.\nSemua pesanan telah selesai diantar!', textAlign: TextAlign.center),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tugasAktif.length,
          itemBuilder: (context, index) {
            final p = tugasAktif[index];
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
                      Text(p.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentCoral.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.status,
                          style: const TextStyle(color: accentCoral, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('Penerima: ${p.customerNama}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Alamat Tujuan: ${p.alamat}', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                  const SizedBox(height: 4),
                  Text('Muatan Ikan: ${p.items}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primarySeafoam,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          RealtimeSyncService.instance.gerakkanKurirMendekatiCustomer(p.id);
                        },
                        icon: const Icon(Icons.navigation, size: 16),
                        label: const Text('Majukan Posisi GPS Kurir'),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primarySeafoam),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveMapPage(pesananId: p.id, roleAktor: 'kurir'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map, size: 16, color: primarySeafoam),
                        label: const Text('Buka Peta Rute Antar', style: TextStyle(color: primarySeafoam)),
                      ),
                    ],
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