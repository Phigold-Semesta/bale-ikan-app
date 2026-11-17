import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/user_info.dart';
import '../model/profil_pengguna.dart';
import '../service/profil_service.dart';
import '../service/realtime_sync_service.dart';
import 'login.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  // Menyimpan cache stream & profil agar tidak pernah berkedip loading ulang
  late Stream<ProfilPengguna> _profilStream;
  ProfilPengguna? _cachedProfil;

  @override
  void initState() {
    super.initState();
    _profilStream = _getProfilStream();
  }

  void _refreshProfil() {
    setState(() {
      _profilStream = _getProfilStream();
    });
  }

  // Menarik data dari ProfilService
  Stream<ProfilPengguna> _getProfilStream() async* {
    ProfilPengguna data = await ProfilService().getProfil();
    _cachedProfil = data;
    yield data;
  }

  // --- Fungsi Alert Sukses (SweetAlert Style) yang Elegan ---
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
                    Navigator.pop(dialogContext); // Tutup dialog sukses
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

  // --- Modal Upload/Hapus Gambar Profil ---
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
              const Text('Kelola Foto Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primarySeafoam.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.upload_file, color: primarySeafoam),
                ),
                title: const Text('Unggah Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih dari laptop/komputer Anda'),
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
                  
                  if (image != null) {
                    final Uint8List bytes = await image.readAsBytes();
                    Navigator.pop(modalContext);
                    await ProfilService().updateGambar(image.path);
                    await RealtimeSyncService.instance.simpanFotoProfil('admin', bytes);
                    if (mounted) {
                      _refreshProfil();
                      _tampilkanAlertSukses(context, "Foto profil berhasil diunggah dan disimpan permanen.");
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: accentCoral.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, color: accentCoral),
                ),
                title: const Text('Hapus Foto', style: TextStyle(fontWeight: FontWeight.w600, color: accentCoral)),
                subtitle: const Text('Kembali menggunakan ikon default'),
                onTap: () async {
                  Navigator.pop(modalContext);
                  await ProfilService().updateGambar(null);
                  await RealtimeSyncService.instance.simpanFotoProfil('admin', Uint8List(0));
                  if (mounted) {
                    _refreshProfil();
                    _tampilkanAlertSukses(context, "Foto profil berhasil dihapus.");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Modal Edit Profil (Nama & Email) ---
  void _tampilkanFormEditProfil(ProfilPengguna profilSaatIni) {
    final _namaCtrl = TextEditingController(text: profilSaatIni.nama);
    final _emailCtrl = TextEditingController(text: profilSaatIni.email);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaCtrl,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  prefixIcon: const Icon(Icons.person, color: primarySeafoam),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primarySeafoam)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Akun",
                  prefixIcon: const Icon(Icons.email, color: primarySeafoam),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primarySeafoam)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primarySeafoam, elevation: 0),
              onPressed: () async {
                await ProfilService().updateProfil(_namaCtrl.text, _emailCtrl.text);
                if (mounted) {
                  Navigator.pop(dialogContext);
                  _refreshProfil();
                  _tampilkanAlertSukses(context, "Informasi profil akun Anda berhasil diperbarui.");
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- Modal Edit Alamat ---
  void _tampilkanFormEditAlamat(ProfilPengguna profilSaatIni) {
    final _alamatCtrl = TextEditingController(text: profilSaatIni.alamat);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Alamat", style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
          content: TextField(
            controller: _alamatCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Alamat Pengiriman",
              alignLabelWithHint: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Icon(Icons.location_on, color: primarySeafoam),
              ),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primarySeafoam)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primarySeafoam, elevation: 0),
              onPressed: () async {
                await ProfilService().updateAlamat(_alamatCtrl.text);
                if (mounted) {
                  Navigator.pop(dialogContext);
                  _refreshProfil();
                  _tampilkanAlertSukses(context, "Alamat pengiriman berhasil diperbarui.");
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- Modal Edit Keamanan & Sandi (DENGAN STATEFULBUILDER & EYE ICON) ---
  void _tampilkanFormEditSandi(ProfilPengguna profilSaatIni) {
    // Controller Data
    final _usernameCtrl = TextEditingController(text: profilSaatIni.email); // Menggunakan email sebagai username
    final _sandiLamaCtrl = TextEditingController(text: profilSaatIni.password); 
    final _sandiBaruCtrl = TextEditingController();

    // Variable State untuk Ikon Mata (Show/Hide Password)
    bool _isSandiLamaHidden = true;
    bool _isSandiBaruHidden = true;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // StatefulBuilder adalah KUNCI JENIUS agar setState berfungsi di dalam Dialog
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Keamanan & Sandi", style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Kolom Username ---
                    TextField(
                      controller: _usernameCtrl,
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: const Icon(Icons.person_outline, color: primarySeafoam),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primarySeafoam)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // --- Kolom Kata Sandi Lama ---
                    TextField(
                      controller: _sandiLamaCtrl,
                      obscureText: _isSandiLamaHidden, // Terhubung dengan boolean
                      decoration: InputDecoration(
                        labelText: "Kata Sandi Lama",
                        prefixIcon: const Icon(Icons.lock_outline, color: primarySeafoam),
                        // Ikon Mata (Visibility Toggle)
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isSandiLamaHidden ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              _isSandiLamaHidden = !_isSandiLamaHidden; // Ubah State
                            });
                          },
                        ),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primarySeafoam)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // --- Kolom Kata Sandi Baru ---
                    TextField(
                      controller: _sandiBaruCtrl,
                      obscureText: _isSandiBaruHidden, // Terhubung dengan boolean
                      decoration: InputDecoration(
                        labelText: "Kata Sandi Baru",
                        prefixIcon: const Icon(Icons.lock, color: primarySeafoam),
                        // Ikon Mata (Visibility Toggle)
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isSandiBaruHidden ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              _isSandiBaruHidden = !_isSandiBaruHidden; // Ubah State
                            });
                          },
                        ),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primarySeafoam)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primarySeafoam, elevation: 0),
                  onPressed: () async {
                    // Update username(email) dan password sekaligus
                    await ProfilService().updateProfil(profilSaatIni.nama, _usernameCtrl.text);
                    if (_sandiBaruCtrl.text.isNotEmpty) {
                      await ProfilService().updatePassword(_sandiBaruCtrl.text);
                    }

                    if (mounted) {
                      Navigator.pop(dialogContext);
                      _refreshProfil();
                      // Tampilkan SweetAlert sukses
                      _tampilkanAlertSukses(context, "Data username dan kata sandi keamanan berhasil diperbarui.");
                    }
                  },
                  child: const Text("Perbarui", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
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
      body: StreamBuilder<ProfilPengguna>(
        stream: _profilStream,
        initialData: _cachedProfil,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _cachedProfil == null) {
            return const Center(child: CircularProgressIndicator(color: primarySeafoam));
          }

          final profil = snapshot.data ?? _cachedProfil;
          if (profil == null) return const Center(child: Text("Gagal memuat profil"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      // ListenableBuilder HANYA membungkus gambar agar layar tidak pernah berkedip loading
                      ListenableBuilder(
                        listenable: RealtimeSyncService.instance,
                        builder: (context, _) {
                          final Uint8List? syncBytes = RealtimeSyncService.instance.getFotoProfil('admin');
                          final bool adaSyncBytes = syncBytes != null && syncBytes.isNotEmpty;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              adaSyncBytes
                                  ? Container(
                                      width: 90,
                                      height: 90,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4))],
                                      ),
                                      child: ClipOval(
                                        child: Image.memory(syncBytes, fit: BoxFit.cover),
                                      ),
                                    )
                                  : profil.gambar != null
                                      ? Container(
                                          width: 90,
                                          height: 90,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4))],
                                          ),
                                          child: ClipOval(
                                            child: kIsWeb
                                                ? Image.network(profil.gambar!, fit: BoxFit.cover)
                                                : Image.file(File(profil.gambar!), fit: BoxFit.cover),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 45,
                                          backgroundColor: primarySeafoam.withOpacity(0.15),
                                          child: const Icon(Icons.person, size: 50, color: primarySeafoam),
                                        ),
                              
                              // Tombol Edit/Upload Foto
                              Positioned(
                                bottom: 0,
                                right: -5,
                                child: GestureDetector(
                                  onTap: () => _tampilkanModalGambar(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: accentCoral,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(profil.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                      const SizedBox(height: 4),
                      Text(profil.email, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // --- Menu Pengaturan Profil ---
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
                        onTap: () => _tampilkanFormEditProfil(profil),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: primarySeafoam),
                        title: const Text('Alamat Pengiriman'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () => _tampilkanFormEditAlamat(profil),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline, color: primarySeafoam),
                        title: const Text('Keamanan & Sandi'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () => _tampilkanFormEditSandi(profil),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // --- Tombol Keluar ---
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
          );
        },
      ),
    );
  }
}