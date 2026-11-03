import 'package:flutter/material.dart';
import '../ui/login.dart';

/// Sidebar (Drawer) Bale Ikan.
///
/// Fungsi utamanya BUKAN menduplikasi menu bottom navigation, tetapi:
/// - Pintasan kategori ikan (memfilter katalog di Beranda)
/// - Pintasan Favorit (menampilkan ikan favorit + jumlahnya)
/// - Info toko & bantuan
/// - Keluar akun dengan dialog konfirmasi
class Sidebar extends StatelessWidget {
  /// Kategori yang sedang aktif di Beranda ('Semua', 'Air Tawar', 'Ikan Laut', 'Favorit').
  final String kategoriAktif;

  /// Jumlah ikan yang difavoritkan (ditampilkan sebagai badge).
  final int jumlahFavorit;

  /// Dipanggil saat pengguna memilih kategori/pintasan dari sidebar.
  final ValueChanged<String>? onKategoriSelected;

  const Sidebar({
    super.key,
    this.kategoriAktif = 'Semua',
    this.jumlahFavorit = 0,
    this.onKategoriSelected,
  });

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2B2D42);

  void _pilihKategori(BuildContext context, String kategori) {
    Navigator.pop(context); // tutup drawer
    onKategoriSelected?.call(kategori);
  }

  void _tampilkanBantuan(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bantuan & Kontak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
            ),
            SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.phone_outlined, color: primarySeafoam),
              title: Text('+62 812-0000-0000'),
              subtitle: Text('Layanan pelanggan (08.00 - 17.00)'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.email_outlined, color: primarySeafoam),
              title: Text('admin@baleikan.com'),
              subtitle: Text('Email pertanyaan & pesanan'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on_outlined, color: primarySeafoam),
              title: Text('Karawang, Jawa Barat'),
              subtitle: Text('Lokasi toko Bale Ikan'),
            ),
          ],
        ),
      ),
    );
  }

  void _tampilkanTentang(BuildContext context) {
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: 'Bale Ikan',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.set_meal, color: primarySeafoam, size: 40),
      children: const [
        SizedBox(height: 12),
        Text('Aplikasi katalog dan pemesanan ikan segar air tawar dan ikan laut.'),
      ],
    );
  }

  Future<void> _konfirmasiKeluar(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun?'),
        content: const Text('Kamu akan kembali ke halaman login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentCoral,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (yakin == true && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildLabel('KATEGORI IKAN'),
                _buildItem(
                  context,
                  icon: Icons.grid_view_rounded,
                  title: 'Semua Ikan',
                  aktifKey: 'Semua',
                ),
                _buildItem(
                  context,
                  icon: Icons.water,
                  title: 'Ikan Air Tawar',
                  aktifKey: 'Air Tawar',
                ),
                _buildItem(
                  context,
                  icon: Icons.set_meal,
                  title: 'Ikan Laut',
                  aktifKey: 'Ikan Laut',
                ),
                _buildItem(
                  context,
                  icon: Icons.favorite_border,
                  title: 'Ikan Favorit',
                  aktifKey: 'Favorit',
                  badge: jumlahFavorit,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1),
                ),
                _buildLabel('LAINNYA'),
                ListTile(
                  leading: const Icon(Icons.support_agent, color: primarySeafoam),
                  title: const Text('Bantuan & Kontak'),
                  onTap: () => _tampilkanBantuan(context),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: primarySeafoam),
                  title: const Text('Tentang Aplikasi'),
                  onTap: () => _tampilkanTentang(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: accentCoral),
                  title: const Text(
                    'Keluar',
                    style: TextStyle(color: accentCoral, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _konfirmasiKeluar(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Bale Ikan v1.0.0',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Komponen
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 24,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primarySeafoam, Color(0xFF028090)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFE6F7F5),
              child: Icon(Icons.set_meal, color: primarySeafoam, size: 32),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Admin Bale Ikan',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          const Text(
            'admin@baleikan.com',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Administrator',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String teks) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        teks,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String aktifKey,
    int badge = 0,
  }) {
    final aktif = kategoriAktif == aktifKey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: aktif ? const Color(0xFFE6F7F5) : null,
        leading: Icon(icon, color: aktif ? primarySeafoam : Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: aktif ? FontWeight.bold : FontWeight.w500,
            color: aktif ? primarySeafoam : darkText,
          ),
        ),
        trailing: badge > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentCoral,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () => _pilihKategori(context, aktifKey),
      ),
    );
  }
}