import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/premium/pages/subscriptions_page.dart';
import 'package:Cinemate/features/settings/pages/help_center/help_center_page.dart';
import 'package:Cinemate/features/settings/pages/manage_account/manage_account_page.dart';
import 'package:Cinemate/features/settings/pages/password_manager/update_password_page.dart';
import 'package:Cinemate/features/settings/pages/policies/privacy_policy_page.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:Cinemate/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    bool isDarkMode = themeCubit.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [


          _buildTile(Icons.vpn_key_outlined, "Şifre Yöneticisi", () {
           Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UpdatePasswordScreen()),
            );
          }),
          _buildTile(Icons.help_outline, "Yardım Merkezi", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterPage()),
            );
          }),
          _buildTile(Icons.privacy_tip_outlined, "Gizlilik Ayarları", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
            );
          }),
          
          
          ListTile(
            leading: Icon(Icons.dark_mode_outlined),
            title: Text("Karanlık Mod",style: AppTextStyles.medium,),
            trailing: CupertinoSwitch(
              value: isDarkMode,
              onChanged: (value) {
                themeCubit.toggleTheme();
              },
            ),
          ),
           _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title,style: AppTextStyles.medium,),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  Widget _buildLogoutButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.read<AuthCubit>().logout(),
        icon: const Icon(Icons.logout),
        label: Text("Çıkış Yap",style: AppTextStyles.bold,),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // oval görünüm
          ),
          padding: const EdgeInsets.symmetric(vertical: 16), // yüksekliği artır
          textStyle: const TextStyle(fontSize: 16),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    ),
  );
}

}
