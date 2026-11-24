import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bale_ikan_app/model/produk_ikan.dart';
import 'package:bale_ikan_app/service/produk_service.dart';
import 'package:bale_ikan_app/service/realtime_sync_service.dart';
import 'admin_beranda.dart';
import 'admin_produk_detail.dart';

class ProdukItem extends StatelessWidget {
  final ProdukIkan produk;
  final bool isFavorit;
  final VoidCallback? onToggleFavorit;

  const ProdukItem({
    super.key,
    required this.produk,
    this.isFavorit = false,
    this.onToggleFavorit,
  });

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  // Ikon default jika belum ada gambar yang di-upload
  IconData _getIcon() {
    if (produk.kategori.toLowerCase().contains('laut')) {
      return Icons.set_meal;
    } else {
      return Icons.waves;
    }
  }

  // --- Fungsi Alert Sukses (SweetAlert Style) ---
  void _tampilkanAlertSukses(BuildContext context, String pesan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: primarySeafoam.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline, color: primarySeafoam, size: 60),
              ),
              const SizedBox(height: 24),
              const Text("Berhasil!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 8),
              Text(pesan, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primarySeafoam,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext); // Tutup dialog
                    // Refresh halaman utama agar gambar baru langsung terlihat
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Beranda()),
                      (route) => false,
                    );
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Modal Bottom Sheet untuk Kelola Gambar
  void _tampilkanModalGambar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext modalContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kelola Gambar Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 24),
              // Tombol Unggah Gambar (Buka Folder Laptop/Web)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primarySeafoam.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.upload_file, color: primarySeafoam),
                ),
                title: const Text('Unggah Gambar', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih file dari laptop/komputer Anda'),
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

                  if (image != null) {
                    final Uint8List bytes = await image.readAsBytes();
                    Navigator.pop(modalContext); // Tutup modal
                    await ProdukService().updateGambar(produk.id!, image.path);
                    await RealtimeSyncService.instance.simpanFotoProduk(produk.namaIkan, bytes);

                    if (context.mounted) {
                      // Tampilkan SweetAlert
                      _tampilkanAlertSukses(context, "Gambar produk berhasil diunggah dan disimpan.");
                    }
                  }
                },
              ),
              const Divider(),
              // Tombol Hapus Gambar
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: accentCoral.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, color: accentCoral),
                ),
                title: const Text('Hapus Gambar', style: TextStyle(fontWeight: FontWeight.w600, color: accentCoral)),
                subtitle: const Text('Kembali menggunakan ikon bawaan'),
                onTap: () async {
                  Navigator.pop(modalContext); // Tutup modal
                  await ProdukService().updateGambar(produk.id!, null);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('foto_ikan_${produk.namaIkan}');

                  if (context.mounted) {
                    // Tampilkan SweetAlert (menggunakan style sukses tapi bisa disesuaikan pesannya)
                    _tampilkanAlertSukses(context, "Gambar produk berhasil dihapus.");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RealtimeSyncService.instance,
      builder: (context, _) {
        final Uint8List? syncBytes = RealtimeSyncService.instance.getFotoProduk(produk.namaIkan);

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProdukDetail(produk: produk)));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Stack(
                      children: [
                        // LOGIKA RENDER GAMBAR JENIUS (Mendukung Memori Permanen, Web, & File)
                        if (syncBytes != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.memory(
                              syncBytes,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        else if (produk.gambar != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: kIsWeb
                                ? Image.network(produk.gambar!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : Image.file(File(produk.gambar!), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          )
                        else
                          Center(child: Icon(_getIcon(), size: 50, color: primarySeafoam)),

                        // Tombol Love Favorit
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: onToggleFavorit,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(
                                isFavorit ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: accentCoral,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(produk.kategori, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primarySeafoam)),
                      const SizedBox(height: 2),
                      Text(produk.namaIkan, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('Stok: ${produk.stok} kg', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Rp ${produk.harga}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentCoral),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Tombol pemicu Modal Unggah/Hapus Gambar
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _tampilkanModalGambar(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: primarySeafoam, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add_a_photo_outlined, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}