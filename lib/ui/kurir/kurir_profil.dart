import 'package:flutter/material.dart';
import '../../helpers/user_info.dart';
import '../login.dart';

class KurirProfil extends StatelessWidget {
  const KurirProfil({super.key});

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
            child: Icon(Icons.delivery_dining, size: 50, color: primarySeafoam),
          ),
          const SizedBox(height: 12),
          const Text('Kang Asep (Kurir Pendingin)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
          const Text('Armada: Motor Box Pendingin Es • T 4581 KW', style: TextStyle(color: Colors.grey)),
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
              label: const Text('Keluar dari Akun Kurir', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}