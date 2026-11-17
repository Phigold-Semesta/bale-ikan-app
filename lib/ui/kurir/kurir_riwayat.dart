import 'package:flutter/material.dart';
import '../../service/realtime_sync_service.dart';
import '../live_map_page.dart';

class KurirRiwayat extends StatelessWidget {
  const KurirRiwayat({super.key});

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color darkText = Color(0xFF2B2D42);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RealtimeSyncService.instance,
      builder: (context, _) {
        final riwayatSelesai = RealtimeSyncService.instance.daftarPesanan
            .where((p) => p.status == 'Tiba di Tujuan (Selesai)')
            .toList();

        if (riwayatSelesai.isEmpty) {
          return const Center(
            child: Text('Belum ada riwayat pengantaran yang selesai hari ini.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: riwayatSelesai.length,
          itemBuilder: (context, index) {
            final p = riwayatSelesai[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE6F7F5),
                  child: Icon(Icons.check_circle, color: primarySeafoam),
                ),
                title: Text('${p.id} • ${p.customerNama}', style: const TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                subtitle: Text('${p.items}\nTujuan: ${p.alamat}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.map_outlined, color: primarySeafoam),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveMapPage(pesananId: p.id, roleAktor: 'kurir'),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}