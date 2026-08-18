import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildSection(
              'General Settings',
              [
                _buildMenuItem(Icons.person_outline, 'Edit Profile'),
                _buildMenuItem(Icons.landscape_outlined, 'My Farms'),
                _buildMenuItem(Icons.notifications_none, 'Notifications', trailing: const Text('ON', style: TextStyle(color: AppColors.primary))),
                _buildMenuItem(Icons.language, 'Language', trailing: const Text('English')),
              ],
            ),
            _buildSection(
              'App Preferences',
              [
                _buildMenuItem(Icons.dark_mode_outlined, 'Dark Mode', trailing: Switch(value: false, onChanged: (v) {})),
                _buildMenuItem(Icons.help_outline, 'Help & Support'),
                _buildMenuItem(Icons.info_outline, 'About AgriSmart'),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: const Text('Logout'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=farmer'),
        ),
        SizedBox(height: 16),
        Text('Farmer John', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('john.farmer@email.com', style: TextStyle(color: AppColors.textSecondary)),
        SizedBox(height: 8),
        Chip(
          label: Text('Premium Member', style: TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () {},
    );
  }
}
