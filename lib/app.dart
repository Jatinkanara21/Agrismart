import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/agri_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/dashboard_shell.dart';
import 'core/theme/app_theme.dart';

class AgriSmartApp extends StatelessWidget {
  const AgriSmartApp({super.key});
  @override Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => AgriProvider(), child: MaterialApp(debugShowCheckedModeBanner: false, title: 'AgriSmart', theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: ThemeMode.light, home: const AuthGate()));
}

class AuthGate extends StatefulWidget { const AuthGate({super.key}); @override State<AuthGate> createState() => _AuthGateState(); }
class _AuthGateState extends State<AuthGate> {
  bool signedIn = false;
  @override Widget build(BuildContext context) => signedIn ? const DashboardShell() : AuthScreen(onSignedIn: () => setState(() => signedIn = true));
}
