import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onSignedIn});
  final VoidCallback onSignedIn;
  @override State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final phone = TextEditingController(text: '');
  bool otp = false;
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 66, height: 66, decoration: BoxDecoration(color: AppTheme.green, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.eco, color: Colors.white, size: 36)),
    const SizedBox(height: 24), const Text('AgriSmart', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.forest)), const SizedBox(height: 8),
    Text(otp ? 'Enter the 6-digit code sent to your phone.' : 'Your AI-powered farming advisor, built for the field.', style: const TextStyle(color: Colors.black54, fontSize: 16)), const SizedBox(height: 28),
    if (!otp) ...[
      const Text('Phone number', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(prefixText: '+91  ', hintText: 'Enter mobile number')),
      const SizedBox(height: 14), SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: () => setState(() => otp = true), child: const Text('Continue with OTP'))),
      const SizedBox(height: 12), SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(onPressed: widget.onSignedIn, icon: const Icon(Icons.account_circle), label: const Text('Continue with Google'))),
      const SizedBox(height: 18), const Center(child: Text('By continuing, you agree to the AgriSmart privacy policy.', style: TextStyle(fontSize: 11, color: Colors.black45))),
    ] else ...[
      TextField(keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: 'OTP', hintText: '123456')), const SizedBox(height: 14), SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: widget.onSignedIn, child: const Text('Verify & Open AgriSmart'))), const SizedBox(height: 10), TextButton(onPressed: () => setState(() => otp = false), child: const Text('Change phone number')),
    ]
  ])))));
}
