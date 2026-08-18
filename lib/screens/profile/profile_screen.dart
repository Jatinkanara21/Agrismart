import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import '../farm/farm_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & settings', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 110), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]), borderRadius: BorderRadius.circular(24)), child: Row(children: [
          const CircleAvatar(radius: 32, backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, color: Colors.white, size: 34)),
          const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Jatin Kanara', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)), SizedBox(height: 4), Text('Smart farmer workspace', style: TextStyle(color: Colors.white70))])),
          IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile editor coming next.'))), icon: const Icon(Icons.edit_outlined, color: Colors.white)),
        ])),
        const SizedBox(height: 22),
        _Section(title: 'Workspace', children: [
          _Item(icon: Icons.landscape_outlined, title: 'My farms', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmScreen()))),
          _Item(icon: Icons.notifications_none_rounded, title: 'Notifications', trailing: Switch(value: notifications, onChanged: (v) => setState(() => notifications = v)), onTap: () => setState(() => notifications = !notifications)),
        ]),
        const SizedBox(height: 14),
        _Section(title: 'Preferences', children: [
          _Item(icon: Icons.dark_mode_outlined, title: 'Dark mode', trailing: Switch(value: darkMode, onChanged: (v) => setState(() => darkMode = v)), onTap: () => setState(() => darkMode = !darkMode)),
          _Item(icon: Icons.language_outlined, title: 'Language', trailing: const Text('English', style: TextStyle(color: AppColors.textSecondary)), onTap: () {}),
          _Item(icon: Icons.notifications_active_outlined, title: 'Notification center', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
        ]),
        const SizedBox(height: 14),
        _Section(title: 'Support', children: [
          _Item(icon: Icons.help_outline_rounded, title: 'Help & support', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support center opened.')))),
          _Item(icon: Icons.info_outline_rounded, title: 'About AgriSmart', onTap: () => showAboutDialog(context: context, applicationName: 'AgriSmart', applicationVersion: '1.0.0', applicationLegalese: 'Smart farming intelligence')),
        ]),
        const SizedBox(height: 18),
        OutlinedButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())), icon: const Icon(Icons.logout_rounded), label: const Text('Log out'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error))),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .4))), child: Column(children: children))]);
}

class _Item extends StatelessWidget {
  final IconData icon; final String title; final Widget? trailing; final VoidCallback onTap;
  const _Item({required this.icon, required this.title, required this.onTap, this.trailing});
  @override
  Widget build(BuildContext context) => ListTile(onTap: onTap, leading: Icon(icon, color: AppColors.textSecondary), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary));
}
