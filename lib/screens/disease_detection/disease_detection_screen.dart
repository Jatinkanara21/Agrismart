import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final _picker = ImagePicker();
  XFile? _image;
  bool _analyzing = false;
  bool _showResult = false;

  Future<void> _pick(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 82);
    if (!mounted) return;
    if (image != null) setState(() { _image = image; _showResult = false; });
  }

  Future<void> _analyze() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a plant image first.')));
      return;
    }
    setState(() => _analyzing = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _analyzing = false; _showResult = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant health scan', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 120), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(22)),
          child: const Row(children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 28), SizedBox(width: 12),
            Expanded(child: Text('AI-style crop analysis', style: TextStyle(fontWeight: FontWeight.w800))),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          height: 320,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .45))),
          clipBehavior: Clip.antiAlias,
          child: _image == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(padding: const EdgeInsets.all(18), decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle), child: const Icon(Icons.document_scanner_outlined, color: AppColors.primary, size: 38)),
                const SizedBox(height: 14), const Text('Capture a clear leaf photo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 6), const Text('Use daylight and focus on affected areas.', style: TextStyle(color: AppColors.textSecondary)),
              ])
            : Stack(fit: StackFit.expand, children: [Image.network(_image!.path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.mint, child: const Icon(Icons.image_outlined, size: 60, color: AppColors.primary))), if (_analyzing) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white)))]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera'))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(onPressed: () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery'))),
        ]),
        const SizedBox(height: 14),
        ElevatedButton.icon(onPressed: _analyzing ? null : _analyze, icon: Icon(_analyzing ? Icons.hourglass_top_rounded : Icons.analytics_outlined), label: Text(_analyzing ? 'Analyzing plant…' : 'Analyze health')),
        if (_showResult) ...[
          const SizedBox(height: 22),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.check_circle_rounded, color: AppColors.primary), const SizedBox(width: 10), const Expanded(child: Text('Tomato early blight detected', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: const Text('94%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)))]),
            const SizedBox(height: 14),
            const Text('Symptoms', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('Dark concentric leaf spots, yellowing around lesions, and early leaf drop.', style: TextStyle(color: AppColors.textSecondary, height: 1.45)),
            const SizedBox(height: 13),
            const Text('Recommended treatment', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('Remove infected leaves, improve airflow, and consider a copper-based fungicide.', style: TextStyle(color: AppColors.textSecondary, height: 1.45)),
          ])),
        ],
      ]),
    );
  }
}
