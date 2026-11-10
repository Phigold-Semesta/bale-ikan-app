import 'dart:io';
import 'package:flutter/foundation.dart'; // Ditambahkan untuk pengecekan platform web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Ditambahkan untuk akses folder/galeri
import '../model/produk_ikan.dart';
import '../service/produk_service.dart';
import 'produk_page.dart';
import 'produk_update_form.dart';
import 'beranda.dart'; // Ditambahkan untuk navigasi hapus data

class ProdukDetail extends StatefulWidget {
  final ProdukIkan produk;
  const ProdukDetail({super.key, required this.produk});

  @override
  State<ProdukDetail> createState() => _ProdukDetailState();
}

class _ProdukDetailState extends State<ProdukDetail> {
  // Warna Tema Konsisten
  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  Stream<ProdukIkan> getData() async* {
    ProdukIkan data = await ProdukService().getById(widget.produk.id.toString());
    yield data;
  }

  // Menentukan ikon berdasarkan kategori
  IconData _getIcon(String kategori) {
    if (kategori.toLowerCase().contains('laut')) {
      return Icons.set_meal;
    } else {
      return Icons.waves;
    }
  }

  // --- FUNGSI ALERT SUKSES HAPUS (SweetAlert Style) ---
  void _tampilkanAlertSukses(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan klik di luar
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
              Text("Data ikan berhasil dihapus dari katalog.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
                    Navigator.pop(dialogContext); // Tutup SweetAlert
                    // Langsung redirect ke Beranda secara instan
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Beranda()),
                      (Route<dynamic> route) => false,
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

  // Modal Bottom Sheet untuk Kelola Gambar langsung dari Halaman Detail
  void _tampilkanModalGambar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kelola Gambar Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
              ),
              const SizedBox(height: 24),
              // Tombol Unggah Gambar
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
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  
                  if (image != null) {
                    Navigator.pop(modalContext);
                    await ProdukService().updateGambar(widget.produk.id!, image.path);
                    
                    if (context.mounted) {
                      setState(() {});
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
                  Navigator.pop(modalContext);
                  await ProdukService().updateGambar(widget.produk.id!, null);
                  
                  if (context.mounted) {
                    setState(() {});
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
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: primarySeafoam,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Produk",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<ProdukIkan>(
        stream: getData(),
        builder: (context, AsyncSnapshot<ProdukIkan> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString(), style: const TextStyle(color: accentCoral)));
          }
          if (snapshot.connectionState != ConnectionState.done && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primarySeafoam)));
          }
          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            return const Center(child: Text('Data Tidak Ditemukan', style: TextStyle(color: darkText)));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Card Detail Utama
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // LOGIKA GAMBAR DENGAN TOMBOL UPLOAD DI POJOKNYA
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          data.gambar != null
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4))],
                                  ),
                                  child: ClipOval(
                                    child: kIsWeb
                                        ? Image.network(data.gambar!, fit: BoxFit.cover)
                                        : Image.file(File(data.gambar!), fit: BoxFit.cover),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: primarySeafoam.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_getIcon(data.kategori), size: 60, color: primarySeafoam),
                                ),
                          
                          // Tombol Edit/Upload Gambar Mini
                          Positioned(
                            bottom: 0,
                            right: -10,
                            child: GestureDetector(
                              onTap: () => _tampilkanModalGambar(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentCoral,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [BoxShadow(color: Color(0x2A000000), blurRadius: 4, offset: Offset(0, 2))],
                                ),
                                child: const Icon(Icons.add_a_photo_outlined, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Nama & Kategori
                      Text(
                        data.kategori.toUpperCase(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primarySeafoam, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.namaIkan,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText),
                      ),
                      
                      const Divider(height: 40, thickness: 1, color: Color(0xFFEEEEEE)),
                      
                      // Harga & Stok
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Harga per Kg', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${data.harga}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentCoral),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
                          Column(
                            children: [
                              Text('Sisa Stok', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              const SizedBox(height: 4),
                              Text(
                                '${data.stok} kg',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Tombol Aksi
                Row(
                  children: [
                    Expanded(child: _tombolUbah()),
                    const SizedBox(width: 16),
                    Expanded(child: _tombolHapus()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tombolUbah() {
    return StreamBuilder<ProdukIkan>(
      stream: getData(),
      builder: (context, AsyncSnapshot<ProdukIkan> snapshot) => ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySeafoam,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
        label: const Text("Ubah Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          if (snapshot.hasData) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProdukUpdateForm(produk: snapshot.data!),
              ),
            ).then((value) {
              if (mounted) setState(() {});
            });
          }
        },
      ),
    );
  }

  Widget _tombolHapus() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: accentCoral,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: accentCoral, width: 1.5),
        ),
        elevation: 0,
      ),
      icon: const Icon(Icons.delete_outline, size: 20),
      label: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () {
        // Modal Konfirmasi Hapus yang Elegan
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) { 
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: accentCoral, size: 28),
                  SizedBox(width: 10),
                  Text("Konfirmasi", style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                "Apakah Anda yakin ingin menghapus data ikan ini? Tindakan ini tidak dapat dibatalkan.",
                style: TextStyle(color: darkText),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), // Tutup dialog pembatalan
                  child: Text("Batal", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                ),
                // DIPERBAIKI: Dibuat sebagai ElevatedButton biasa TANPA StreamBuilder agar tidak crash / ngelag!
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentCoral,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    // 1. Langsung tutup dialog konfirmasi seketika agar UI terasa super mulus
                    Navigator.pop(dialogContext);
                    
                    // 2. Eksekusi hapus data menggunakan widget.produk (sumber data yang aman)
                    await ProdukService().hapus(widget.produk).then((value) {
                      
                      // 3. Setelah berhasil dihapus, munculkan SweetAlert Sukses!
                      if (mounted) {
                        _tampilkanAlertSukses(context);
                      }
                    });
                  },
                  child: const Text("Ya, Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}