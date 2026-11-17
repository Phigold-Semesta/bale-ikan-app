import 'package:flutter/material.dart';
import '../service/login_service.dart';
import 'beranda.dart';
import 'customer/customer_beranda.dart';
import 'kurir/kurir_beranda.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _sembunyikanPassword = true;
  bool _sedangMasuk = false;

  // Konsistensi warna tema Bale Ikan
  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color deepOcean = Color(0xFF028090);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2B2D42);
  static const Color fieldBg = Color(0xFFF4F7F8);

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Aksi
  // ---------------------------------------------------------------------------
  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    await _eksekusiLogin(_usernameCtrl.text.trim(), _passwordCtrl.text);
  }

  Future<void> _masukPintasanAktor(String user, String pass) async {
    FocusScope.of(context).unfocus();
    _usernameCtrl.text = user;
    _passwordCtrl.text = pass;
    await _eksekusiLogin(user, pass);
  }

  Future<void> _eksekusiLogin(String username, String password) async {
    setState(() => _sedangMasuk = true);
    try {
      final role = await LoginService().loginWithRole(username, password);
      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Beranda()),
        );
      } else if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerBeranda()),
        );
      } else if (role == 'kurir') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KurirBeranda()),
        );
      } else {
        final berhasil = await LoginService().login(username, password);
        if (!mounted) return;
        if (berhasil == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Beranda()),
          );
        } else {
          _tampilkanDialogGagal();
        }
      }
    } catch (_) {
      if (!mounted) return;
      _tampilkanSnackBar('Terjadi kesalahan. Coba lagi beberapa saat lagi.');
    } finally {
      if (mounted) setState(() => _sedangMasuk = false);
    }
  }

  void _tampilkanDialogGagal() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.error_outline, color: accentCoral, size: 36),
        title: const Text('Gagal Masuk'),
        content: const Text(
          'Username atau password salah.\n\nGunakan salah satu akun resmi:\n• Penjual: admin / admin\n• Pembeli: customer / customer\n• Kurir: kurir / kurir',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK', style: TextStyle(color: primarySeafoam)),
          ),
        ],
      ),
    );
  }

  void _masukDenganGoogle() {
    // TODO: Integrasikan dengan paket `google_sign_in` + Firebase Auth, contoh:
    //   final akun = await GoogleSignIn().signIn();
    //   if (akun == null) return; // pengguna membatalkan
    //   ... lanjutkan autentikasi ke Firebase / backend
    _tampilkanSnackBar(
      'Login Google simulasi aktif: mengarahkan ke beranda Customer...',
    );
    _masukPintasanAktor('customer', 'customer');
  }

  void _lupaPassword() {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _LupaPasswordSheet(),
    ).then((email) {
      if (email != null && mounted) {
        _tampilkanSnackBar('Jika $email terdaftar, tautan reset password akan dikirim.');
      }
    });
  }

  void _tampilkanSnackBar(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.white,
      ),
      child: SelectionContainer.disabled(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Stack(
              children: [
                // Dekorasi lingkaran lembut di latar
                Positioned(
                  top: -90,
                  right: -70,
                  child: IgnorePointer(
                    child: _lingkaran(260, const Color(0x1A00A896)),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: -90,
                  child: IgnorePointer(
                    child: _lingkaran(160, const Color(0x14FF6B6B)),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -60,
                  child: IgnorePointer(
                    child: _lingkaran(220, const Color(0x14028090)),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBrand(),
                              const SizedBox(height: 36),
                              _buildFieldUsername(),
                              const SizedBox(height: 16),
                              _buildFieldPassword(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _lupaPassword,
                                  style: TextButton.styleFrom(
                                    foregroundColor: primarySeafoam,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  child: const Text(
                                    'Lupa password?',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildTombolMasuk(),
                              const SizedBox(height: 18),
                              _buildPintasanAktorDemo(),
                              const SizedBox(height: 20),
                              _buildPemisah(),
                              const SizedBox(height: 20),
                              _buildTombolGoogle(),
                              const SizedBox(height: 28),
                              Text(
                                'Dengan masuk, kamu menyetujui Syarat & Ketentuan\ndan Kebijakan Privasi Bale Ikan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, height: 1.5, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lingkaran(double ukuran, Color warna) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0x3300A896), blurRadius: 24, offset: Offset(0, 10)),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo/bale_ikan_logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                color: primarySeafoam,
                child: const Icon(Icons.set_meal, color: Colors.white, size: 56),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'BALE IKAN',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: darkText,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pasar Ikan Segar Langsung dari Nelayan & Peternak',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, height: 1.4, color: Colors.grey[600]),
        ),
      ],
    );
  }

  InputDecoration _dekorasiField({
    required String label,
    required IconData ikon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color warna, [double lebar = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: warna, width: lebar),
        );

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      floatingLabelStyle: const TextStyle(color: primarySeafoam, fontWeight: FontWeight.w600),
      prefixIcon: Icon(ikon, color: primarySeafoam),
      suffixIcon: suffix,
      filled: true,
      fillColor: fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(primarySeafoam, 1.5),
      errorBorder: border(accentCoral),
      focusedErrorBorder: border(accentCoral, 1.5),
    );
  }

  Widget _buildFieldUsername() {
    return TextFormField(
      controller: _usernameCtrl,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username],
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
      decoration: _dekorasiField(
        label: 'Username (admin / customer / kurir)',
        ikon: Icons.person_outline,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Username wajib diisi';
        return null;
      },
    );
  }

  Widget _buildFieldPassword() {
    return TextFormField(
      controller: _passwordCtrl,
      focusNode: _passwordFocus,
      obscureText: _sembunyikanPassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (_) => _masuk(),
      decoration: _dekorasiField(
        label: 'Password',
        ikon: Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(
            _sembunyikanPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey[500],
          ),
          onPressed: () => setState(() => _sembunyikanPassword = !_sembunyikanPassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password wajib diisi';
        return null;
      },
    );
  }

  Widget _buildTombolMasuk() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [primarySeafoam, deepOcean]),
        boxShadow: const [
          BoxShadow(color: Color(0x4000A896), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _sedangMasuk ? null : _masuk,
        child: _sedangMasuk
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                'Masuk Aplikasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildPintasanAktorDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pintasan Cepat Demo 3 Aktor:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primarySeafoam,
                  side: const BorderSide(color: primarySeafoam),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _sedangMasuk ? null : () => _masukPintasanAktor('customer', 'customer'),
                icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                label: const Text('Pembeli', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: darkText,
                  side: const BorderSide(color: darkText),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _sedangMasuk ? null : () => _masukPintasanAktor('admin', 'admin'),
                icon: const Icon(Icons.storefront_outlined, size: 16),
                label: const Text('Penjual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentCoral,
                  side: const BorderSide(color: accentCoral),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _sedangMasuk ? null : () => _masukPintasanAktor('kurir', 'kurir'),
                icon: const Icon(Icons.delivery_dining_outlined, size: 16),
                label: const Text('Kurir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPemisah() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'atau masuk dengan',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildTombolGoogle() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: _sedangMasuk ? null : _masukDenganGoogle,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LogoGoogle(),
          SizedBox(width: 12),
          Text(
            'Lanjutkan dengan Google',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText),
          ),
        ],
      ),
    );
  }
}

/// Huruf "G" berwarna khas Google (tanpa aset gambar tambahan).
class _LogoGoogle extends StatelessWidget {
  const _LogoGoogle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => const SweepGradient(
        colors: [
          Color(0xFF4285F4),
          Color(0xFF4285F4),
          Color(0xFF34A853),
          Color(0xFF34A853),
          Color(0xFFFBBC05),
          Color(0xFFFBBC05),
          Color(0xFFEA4335),
          Color(0xFFEA4335),
          Color(0xFF4285F4),
          Color(0xFF4285F4),
        ],
        stops: [0, 0.125, 0.125, 0.375, 0.375, 0.625, 0.625, 0.875, 0.875, 1],
      ).createShader(rect),
      child: const Text(
        'G',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
      ),
    );
  }
}

/// Bottom sheet "Lupa Password": meminta email untuk mengirim tautan reset.
class _LupaPasswordSheet extends StatefulWidget {
  const _LupaPasswordSheet();

  @override
  State<_LupaPasswordSheet> createState() => _LupaPasswordSheetState();
}

class _LupaPasswordSheetState extends State<_LupaPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _mengirim = false;

  static final RegExp _polaEmail = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _mengirim = true);

    // TODO: Panggil API/Firebase (mis. sendPasswordResetEmail) di sini.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.pop(context, _emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F7F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset, size: 32, color: LoginState.primarySeafoam),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lupa Password?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LoginState.darkText),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan email akunmu. Kami akan mengirimkan tautan untuk mengatur ulang password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, height: 1.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _kirim(),
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined, color: LoginState.primarySeafoam),
                filled: true,
                fillColor: LoginState.fieldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Email wajib diisi';
                if (!_polaEmail.hasMatch(email)) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LoginState.primarySeafoam,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _mengirim ? null : _kirim,
              child: _mengirim
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'Kirim Tautan Reset',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
            TextButton(
              onPressed: _mengirim ? null : () => Navigator.pop(context),
              child: Text('Kembali ke Login', style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }
}