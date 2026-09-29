import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'farming_tools.dart';

void main() => runApp(const AgriSmartApp());

class AgriSmartApp extends StatelessWidget {
  const AgriSmartApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AgriSmart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const LoginPage(),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });
    final storage = const FlutterSecureStorage();
    final savedEmail = await storage.read(key: 'agrismart_email');
    final savedPassword = await storage.read(key: 'agrismart_password');

    if (email.text.trim() == savedEmail && password.text == savedPassword) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } else if (mounted) {
      setState(() => error = 'Email or password is incorrect.');
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.agriculture,
                        size: 72, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text(
                      'AgriSmart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'AI-Powered Smart Farming Assistant',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (error != null)
                      Text(error!,
                          style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterPage()),
                      ),
                      child: const Text('Create a farmer account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool loading = false;
  String? message;

  Future<void> register() async {
    final userName = name.text.trim();
    final userEmail = email.text.trim();
    final userPassword = password.text;
    final confirmation = confirm.text;

    if (userName.isEmpty || userEmail.isEmpty || userPassword.length < 6) {
      setState(() => message = 'Enter your name, a valid email, and a password of at least 6 characters.');
      return;
    }
    if (userPassword != confirmation) {
      setState(() => message = 'Passwords do not match.');
      return;
    }

    setState(() {
      loading = true;
      message = null;
    });

    final storage = const FlutterSecureStorage();
    await storage.write(key: 'agrismart_name', value: userName);
    await storage.write(key: 'agrismart_email', value: userEmail);
    await storage.write(key: 'agrismart_password', value: userPassword);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (_) => false,
      );
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create account')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
            TextField(
                controller: confirm,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm password')),
            if (message != null)
              Text(message!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: loading ? null : register,
              child: const Text('Register'),
            ),
          ],
        ),
      );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('AgriSmart'),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
              icon: const Icon(Icons.person),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('Smart farming, clearer decisions.',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                  'Use verified data and model-backed tools to support your farm decisions.'),
              const SizedBox(height: 20),
              const WeatherCard(),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  FeatureCard(
                    icon: Icons.grass,
                    title: 'Crop Recommendation',
                    page: CropRecommendationPage(),
                  ),
                  FeatureCard(
                    icon: Icons.local_florist,
                    title: 'Disease Detection',
                    page: DiseaseDetectionPage(),
                  ),
                  FeatureCard(
                    icon: Icons.analytics,
                    title: 'Yield Prediction',
                    page: YieldPredictionPage(),
                  ),
                  FeatureCard(
                    icon: Icons.smart_toy,
                    title: 'AgriBot',
                    page: AgriBotPage(),
                  ),
                  FeatureCard(
                    icon: Icons.cloud,
                    title: 'Weather',
                    page: WeatherPage(),
                  ),
                  FeatureCard(
                    icon: Icons.agriculture,
                    title: 'Farm Decisions',
                    page: FarmDecisionPage(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.cloud, size: 42, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live weather',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Open Weather to load current conditions and a 5-day forecast.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.page,
  });

  final IconData icon;
  final String title;
  final Widget page;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 34, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
}

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline,
                    size: 56, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  '$title is ready for its verified provider/model integration.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No prediction is displayed until the required real service or trained model is configured.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Secure session'),
              subtitle: Text(
                  'Authentication tokens are stored using platform secure storage.'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Service configuration'),
              subtitle: Text(
                  'API, weather, AI and ML credentials belong on the backend.'),
            ),
          ],
        ),
      );
}
