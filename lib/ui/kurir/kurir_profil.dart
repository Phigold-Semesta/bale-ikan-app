import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/user_info.dart';
import '../../service/realtime_sync_service.dart';
import '../login.dart';

class KurirProfil extends StatefulWidget {
  const KurirProfil({super.key});

  @override
  State<KurirProfil> createState() => _KurirProfilState();
}

class _KurirProfilState extends State<KurirProfil> {
  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  Uint8List? _profileImageBytes;
  String _namaKurir = 'Kang Asep (Kurir Pendingin)';
  String _emailKurir = 'kurir@baleikan.com';
  String _ruteOperasional = 'Pool Logistik Bale Ikan Karawang • Mobil Box T 4581 KW';

  @override
  void initState() {
    super.initState();
    _loadSavedProfileData();
  }

  Future<void> _loadSavedProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNama = prefs.getString('nama_profil_kurir');
    final savedEmail = prefs.getString('email_profil_kurir');
    final savedRute = prefs.getString('rute_profil_kurir');

    if (savedNama != null) _namaKurir = savedNama;
    if (savedEmail != null) _emailKurir = savedEmail;
    if (savedRute != null) _ruteOperasional = savedRute;

    final syncBytes = RealtimeSyncService.instance.getFotoProfil('kurir');
    if (syncBytes != null) {
      if (mounted) setState(() => _profileImageBytes = syncBytes);
      return;
    }

    final String? base64Image = prefs.getString('foto_profil_kurir');
    if (base64Image != null && mounted) {
      setState(() {
        _profileImageBytes = base64Decode(base64Image);
      });
    } else if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickAndSaveProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      await RealtimeSyncService.instance.simpanFotoProfil('kurir', bytes);

      if (mounted) {
        setState(() => _profileImageBytes = bytes);
        _tampilkanAlertSukses('Foto profil Kurir berhasil diperbarui dan disimpan permanen!');
      }
    }
  }

  void _tampilkanAlertSukses(String pesan) {
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _bukaModalEditProfil() {
    final namaCtrl = TextEditingController(text: _namaKurir);
    final emailCtrl = TextEditingController(text: _emailKurir);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(modalContext).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Edit Profil Kurir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 16),
            TextField(
              controller: namaCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Kurir',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email Kurir',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySeafoam,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('nama_profil_kurir', namaCtrl.text.trim());
                await prefs.setString('email_profil_kurir', emailCtrl.text.trim());
                setState(() {
                  _namaKurir = namaCtrl.text.trim();
                  _emailKurir = emailCtrl.text.trim();
                });
                if (mounted) {
                  Navigator.pop(modalContext);
                  _tampilkanAlertSukses('Profil Kurir berhasil diperbarui!');
                }
              },
              child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _bukaModalLokasiArmada() {
    final ruteCtrl = TextEditingController(text: _ruteOperasional);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(modalContext).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Alamat Pool & Armada Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 16),
            TextField(
              controller: ruteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Wilayah Operasional & Plat Nomor Mobil Box',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySeafoam,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('rute_profil_kurir', ruteCtrl.text.trim());
                setState(() => _ruteOperasional = ruteCtrl.text.trim());
                if (mounted) {
                  Navigator.pop(modalContext);
                  _tampilkanAlertSukses('Data armada & alamat operasional berhasil diperbarui!');
                }
              },
              child: const Text('Simpan Data Armada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _bukaModalSandi() {
    final sandiCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(modalContext).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Keamanan & Sandi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 16),
            TextField(
              controller: sandiCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Kata Sandi Baru',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySeafoam,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(modalContext);
                _tampilkanAlertSukses('Kata sandi keamanan kurir berhasil diperbarui!');
              },
              child: const Text('Perbarui Sandi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profil Akun', style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndSaveProfileImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: primarySeafoam.withOpacity(0.15),
                            shape: BoxShape.circle,
                            image: _profileImageBytes != null
                                ? DecorationImage(image: MemoryImage(_profileImageBytes!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _profileImageBytes == null
                              ? const Icon(Icons.person, size: 55, color: primarySeafoam)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accentCoral,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_namaKurir, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 4),
                  Text(_emailKurir, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3))],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: primarySeafoam),
                    title: const Text('Edit Profil'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: _bukaModalEditProfil,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: primarySeafoam),
                    title: const Text('Alamat Pengiriman'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: _bukaModalLokasiArmada,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: primarySeafoam),
                    title: const Text('Keamanan & Sandi'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: _bukaModalSandi,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentCoral,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await UserInfo().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Keluar Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}