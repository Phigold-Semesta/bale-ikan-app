import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/user_info.dart';
import '../../service/realtime_sync_service.dart';
import '../login.dart';

class CustomerProfil extends StatefulWidget {
  const CustomerProfil({super.key});

  @override
  State<CustomerProfil> createState() => _CustomerProfilState();
}

class _CustomerProfilState extends State<CustomerProfil> {
  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  Uint8List? _profileImageBytes;
  String _namaCustomer = 'Budi Santoso';
  String _emailCustomer = 'customer@baleikan.com';
  String _alamatCustomer = 'Perum Galuh Mas Blok B4, Telukjambe Timur, Karawang';

  @override
  void initState() {
    super.initState();
    _loadSavedProfileData();
  }

  Future<void> _loadSavedProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNama = prefs.getString('nama_profil_customer');
    final savedEmail = prefs.getString('email_profil_customer');
    final savedAlamat = prefs.getString('alamat_profil_customer');

    if (savedNama != null) _namaCustomer = savedNama;
    if (savedEmail != null) _emailCustomer = savedEmail;
    if (savedAlamat != null) _alamatCustomer = savedAlamat;

    final syncBytes = RealtimeSyncService.instance.getFotoProfil('customer');
    if (syncBytes != null) {
      if (mounted) setState(() => _profileImageBytes = syncBytes);
      return;
    }

    final String? base64Image = prefs.getString('foto_profil_customer');
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
      await RealtimeSyncService.instance.simpanFotoProfil('customer', bytes);

      if (mounted) {
        setState(() => _profileImageBytes = bytes);
        _tampilkanAlertSukses('Foto profil berhasil diperbarui dan disimpan permanen!');
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
    final namaCtrl = TextEditingController(text: _namaCustomer);
    final emailCtrl = TextEditingController(text: _emailCustomer);

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
            const Text('Edit Profil Pembeli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 16),
            TextField(
              controller: namaCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
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
                await prefs.setString('nama_profil_customer', namaCtrl.text.trim());
                await prefs.setString('email_profil_customer', emailCtrl.text.trim());
                setState(() {
                  _namaCustomer = namaCtrl.text.trim();
                  _emailCustomer = emailCtrl.text.trim();
                });
                if (mounted) {
                  Navigator.pop(modalContext);
                  _tampilkanAlertSukses('Profil berhasil diperbarui!');
                }
              },
              child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _bukaModalAlamat() {
    final alamatCtrl = TextEditingController(text: _alamatCustomer);

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
            const Text('Alamat Pengiriman Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 16),
            TextField(
              controller: alamatCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Alamat Lengkap di Karawang',
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
                await prefs.setString('alamat_profil_customer', alamatCtrl.text.trim());
                setState(() => _alamatCustomer = alamatCtrl.text.trim());
                if (mounted) {
                  Navigator.pop(modalContext);
                  _tampilkanAlertSukses('Alamat pengiriman berhasil diperbarui!');
                }
              },
              child: const Text('Simpan Alamat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                _tampilkanAlertSukses('Kata sandi keamanan akun berhasil diperbarui!');
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
                  Text(_namaCustomer, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 4),
                  Text(_emailCustomer, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
                    onTap: _bukaModalAlamat,
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