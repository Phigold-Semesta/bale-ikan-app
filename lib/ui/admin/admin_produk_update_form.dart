import 'package:flutter/material.dart';
import 'package:bale_ikan_app/model/produk_ikan.dart';
import 'package:bale_ikan_app/service/produk_service.dart';
import 'admin_beranda.dart';

class ProdukUpdateForm extends StatefulWidget {
  final ProdukIkan produk;
  const ProdukUpdateForm({super.key, required this.produk});

  @override
  State<ProdukUpdateForm> createState() => _ProdukUpdateFormState();
}

class _ProdukUpdateFormState extends State<ProdukUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaIkanCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _stokCtrl = TextEditingController();

  // Variabel untuk Dropdown Kategori
  String? _selectedKategori;
  final List<String> _kategoriList = ['Air Tawar', 'Ikan Laut'];

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2B2D42);

  Future<ProdukIkan> getData() async {
    ProdukIkan data = await ProdukService().getById(widget.produk.id.toString());
    setState(() {
      _namaIkanCtrl.text = data.namaIkan;
      
      // Pastikan kategori dari database cocok dengan list Dropdown
      if (_kategoriList.contains(data.kategori)) {
        _selectedKategori = data.kategori;
      } else {
        _selectedKategori = _kategoriList.first;
      }

      _hargaCtrl.text = data.harga;
      _stokCtrl.text = data.stok;
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  // --- Fungsi Alert Sukses (SweetAlert Style) ---
  void _tampilkanAlertSukses(BuildContext context) {
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
              Text("Informasi ikan berhasil diperbarui di katalog.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
        title: const Text("Ubah Data Produk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Perbarui Informasi Ikan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 8),
              Text("Pastikan harga dan stok selalu ter-update.", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 24),
              _fieldNamaIkan(),
              const SizedBox(height: 16),
              _fieldKategoriDropdown(), // Menggunakan Widget Dropdown
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _fieldHarga()),
                  const SizedBox(width: 16),
                  Expanded(child: _fieldStok()),
                ],
              ),
              const SizedBox(height: 40),
              _tombolSimpan()
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: primarySeafoam, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primarySeafoam, width: 2)),
    );
  }

  Widget _fieldNamaIkan() {
    return TextField(decoration: _inputStyle("Nama Ikan", Icons.set_meal_outlined), controller: _namaIkanCtrl, style: const TextStyle(color: darkText, fontWeight: FontWeight.w500));
  }

  // --- DIPERBAIKI: Menggunakan DropdownButtonFormField ---
  Widget _fieldKategoriDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _inputStyle("Pilih Kategori", Icons.category_outlined),
      value: _selectedKategori,
      icon: const Icon(Icons.arrow_drop_down, color: primarySeafoam),
      items: _kategoriList.map((String kategori) {
        return DropdownMenuItem<String>(
          value: kategori,
          child: Text(kategori, style: const TextStyle(color: darkText, fontWeight: FontWeight.w500)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedKategori = newValue;
        });
      },
    );
  }

  Widget _fieldHarga() {
    return TextField(decoration: _inputStyle("Harga per Kg", Icons.payments_outlined), keyboardType: TextInputType.number, controller: _hargaCtrl, style: const TextStyle(color: darkText, fontWeight: FontWeight.w500));
  }

  Widget _fieldStok() {
    return TextField(decoration: _inputStyle("Stok (Kg)", Icons.inventory_2_outlined), keyboardType: TextInputType.number, controller: _stokCtrl, style: const TextStyle(color: darkText, fontWeight: FontWeight.w500));
  }

  Widget _tombolSimpan() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySeafoam,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: const Icon(Icons.save_outlined, color: Colors.white, size: 22),
        label: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () async {
          // Validasi dropdown agar tidak kosong
          if (_selectedKategori == null || _namaIkanCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Harap lengkapi nama ikan dan kategorinya.')),
            );
            return;
          }

          ProdukIkan produk = ProdukIkan(
            namaIkan: _namaIkanCtrl.text,
            kategori: _selectedKategori!, // Diambil dari state dropdown
            harga: _hargaCtrl.text,
            stok: _stokCtrl.text,
          );
          String id = widget.produk.id.toString();
          
          await ProdukService().ubah(produk, id).then((value) {
             _tampilkanAlertSukses(context);
          });
        },
      ),
    );
  }
}