class ProfilPengguna {
  String nama;
  String email;
  String? gambar;
  // Ditambahkan: Variabel baru untuk menu tambahan
  String alamat;
  String password;

  ProfilPengguna({
    required this.nama,
    required this.email,
    this.gambar,
    // Default valuenya jika baru pertama kali jalan
    this.alamat = 'Jl. Karawang Baru No. 12',
    this.password = 'rahasia123',
  });
}