import 'package:flutter/material.dart';
import '../../helpers/user_info.dart';
import '../login.dart';

class CustomerProfil extends StatelessWidget {
  const CustomerProfil({super.key});

  static const Color primarySeafoam = Color(0xFF00A896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2B2D42);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFE6F7F5),
            child: Icon(Icons.person, size: 50, color: primarySeafoam),
          ),
          const SizedBox(height: 12),
          const Text('Budi Santoso (Customer)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
          const Text('customer@baleikan.com • Member Karawang', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentCoral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                await UserInfo().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun Pembeli', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}