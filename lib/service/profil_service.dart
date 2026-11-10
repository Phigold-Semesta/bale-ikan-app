import '../model/profil_pengguna.dart';

class ProfilService {
  // Data profil default
  static final ProfilPengguna _dataProfil = ProfilPengguna(
    nama: 'Admin Bale Ikan',
    email: 'admin@baleikan.com',
    alamat: 'Jl. Karawang Baru No. 12',
    password: 'rahasia123',
  );

  // Ambil data profil
  Future<ProfilPengguna> getProfil() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dataProfil;
  }

  // Update informasi dasar (nama & email)
  Future<void> updateProfil(String nama, String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _dataProfil.nama = nama;
    _dataProfil.email = email;
  }

  // Update gambar profil
  Future<void> updateGambar(String? imagePath) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _dataProfil.gambar = imagePath;
  }

  // Ditambahkan: Update Alamat
  Future<void> updateAlamat(String alamatBaru) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _dataProfil.alamat = alamatBaru;
  }

  // Ditambahkan: Update Password
  Future<void> updatePassword(String passwordBaru) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _dataProfil.password = passwordBaru;
  }
}