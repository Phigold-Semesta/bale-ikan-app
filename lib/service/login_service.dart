import '../helpers/user_info.dart';

class LoginService {
  Future<String?> loginWithRole(String username, String password) async {
    final user = username.trim().toLowerCase();
    final pass = password.trim().toLowerCase();

    if (user == 'admin' && pass == 'admin') {
      await UserInfo().setToken("admin_token_bale_ikan");
      await UserInfo().setUserID("1");
      await UserInfo().setUsername("Admin Bale Ikan");
      await UserInfo().setRole("admin");
      return 'admin';
    } else if (user == 'customer' && pass == 'customer') {
      await UserInfo().setToken("customer_token_bale_ikan");
      await UserInfo().setUserID("2");
      await UserInfo().setUsername("Budi Santoso (Customer)");
      await UserInfo().setRole("customer");
      return 'customer';
    } else if (user == 'kurir' && pass == 'kurir') {
      await UserInfo().setToken("kurir_token_bale_ikan");
      await UserInfo().setUserID("3");
      await UserInfo().setUsername("Kang Asep (Kurir Pendingin)");
      await UserInfo().setRole("kurir");
      return 'kurir';
    }
    return null;
  }

  Future<bool> login(String username, String password) async {
    final role = await loginWithRole(username, password);
    return role != null;
  }
}