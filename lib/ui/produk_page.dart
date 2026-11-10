import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/produk_ikan.dart';
import '../service/produk_service.dart';
import 'produk_item.dart';
import 'produk_form.dart';

class ProdukPage extends StatefulWidget {
  /// Dua parameter ini opsional dan dipertahankan agar pemanggil lama
  /// (mis. Beranda) tidak error. Jika diisi, tetap dihormati; jika tidak,
  /// halaman ini mengelola favorit sendiri.
  final Set<String>? favoritItemIds;
  final Function(String)? onToggleFavorit;

  const ProdukPage({super.key, this.favoritItemIds, this.onToggleFavorit});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  static const List<String> _daftarKategori = ['Semua', 'Air Tawar', 'Ikan Laut', 'Favorit'];
  static const String _kunciFavorit = 'favorit_produk_ids';

  String _kategoriAktif = 'Semua';

  // Daftar id produk favorit, disimpan di state halaman ini sendiri.
  final Set<String> _favorit = {};

  // Future dibuat SEKALI (bukan di dalam build) agar menekan love
  // tidak memanggil API berulang kali.
  late Future<List<ProdukIkan>> _futureProduk;

  @override
  void initState() {
    super.initState();
    if (widget.favoritItemIds != null) _favorit.addAll(widget.favoritItemIds!);
    _futureProduk = ProdukService().listData();
    _muatFavorit();
  }

  // ---------------------------------------------------------------------------
  // Favorit
  // ---------------------------------------------------------------------------
  Future<void> _muatFavorit() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final tersimpan = pref.getStringList(_kunciFavorit) ?? const <String>[];
      if (!mounted) return;
      setState(() => _favorit.addAll(tersimpan));
    } catch (_) {
      // Jika penyimpanan gagal dibaca, lanjut dengan daftar kosong.
    }
  }

  Future<void> _simpanFavorit() async {
    try {
      final pref = await SharedPreferences.getInstance();
      await pref.setStringList(_kunciFavorit, _favorit.toList());
    } catch (_) {
      // Gagal menyimpan permanen tidak boleh membuat aplikasi error.
    }
  }

  void _toggleFavorit(String id) {
    setState(() {
      if (!_favorit.remove(id)) _favorit.add(id);
    });
    widget.onToggleFavorit?.call(id); // beri tahu pemanggil lama bila ada
    _simpanFavorit();
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------
  Future<void> _muatUlang() async {
    final baru = ProdukService().listData();
    setState(() => _futureProduk = baru);
    try {
      await baru; // agar indikator tarik-untuk-refresh menunggu sampai selesai
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _bukaFormTambah() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProdukForm()),
    );
    if (mounted) _muatUlang(); // daftar langsung menampilkan data baru
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Katalog Produk Ikan',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: primarySeafoam, size: 28),
              onPressed: _bukaFormTambah,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterKategori(),
          Expanded(child: _buildIsi()),
        ],
      ),
    );
  }

  Widget _buildFilterKategori() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _daftarKategori.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final kategori = _daftarKategori[index];
            final aktif = kategori == _kategoriAktif;
            return ChoiceChip(
              label: Text(kategori),
              selected: aktif,
              showCheckmark: false,
              selectedColor: primarySeafoam,
              backgroundColor: Colors.white,
              side: BorderSide(color: aktif ? primarySeafoam : Colors.grey.shade300),
              labelStyle: TextStyle(
                color: aktif ? Colors.white : darkText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              onSelected: (_) => setState(() => _kategoriAktif = kategori),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIsi() {
    return FutureBuilder<List<ProdukIkan>>(
      future: _futureProduk,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primarySeafoam),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: accentCoral),
                const SizedBox(height: 16),
                const Text(
                  'Gagal Memuat Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                ),
                const SizedBox(height: 8),
                Text('Periksa koneksi atau alamat API Anda.', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _muatUlang,
                  icon: const Icon(Icons.refresh, color: primarySeafoam),
                  label: const Text('Coba lagi', style: TextStyle(color: primarySeafoam)),
                ),
              ],
            ),
          );
        }

        var daftarIkan = snapshot.data ?? <ProdukIkan>[];

        if (_kategoriAktif == 'Favorit') {
          daftarIkan = daftarIkan.where((ikan) => _favorit.contains(ikan.id.toString())).toList();
        } else if (_kategoriAktif != 'Semua') {
          daftarIkan = daftarIkan.where((ikan) => ikan.kategori == _kategoriAktif).toList();
        }

        if (daftarIkan.isEmpty) {
          return RefreshIndicator(
            color: primarySeafoam,
            onRefresh: _muatUlang,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _kategoriAktif == 'Favorit'
                        ? 'Belum ada ikan favorit'
                        : 'Belum ada ikan di kategori ini',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: primarySeafoam,
          onRefresh: _muatUlang,
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            itemCount: daftarIkan.length,
            itemBuilder: (context, index) {
              final ikan = daftarIkan[index];
              final id = ikan.id.toString();

              return ProdukItem(
                produk: ikan,
                isFavorit: _favorit.contains(id),
                // Diperbarui: Panggilan onToggleFavorit sudah diteruskan ke fungsi internal
                onToggleFavorit: () => _toggleFavorit(id),
              );
            },
          ),
        );
      },
    );
  }
}