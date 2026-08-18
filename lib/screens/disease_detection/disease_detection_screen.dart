import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  bool _isAnalyzing = false;
  bool _showResult = false;

  void _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
      _showResult = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAnalyzing = false;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disease Detection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildUploadSection(),
            const SizedBox(height: 24),
            if (!_showResult) ...[
              const Text(
                'Take a photo of the affected plant part to identify potential diseases and get treatment recommendations.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: _isAnalyzing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.analytics_outlined),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Start Analysis'),
              ),
            ],
            if (_showResult) _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: _showResult 
        ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network('https://images.unsplash.com/photo-1592841208389-52317a70233d?w=500&q=80', fit: BoxFit.cover),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 60, color: AppColors.primary.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('Take a Photo or Upload Image', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconButton(Icons.camera_alt, 'Camera'),
                  const SizedBox(width: 20),
                  _buildIconButton(Icons.photo_library, 'Gallery'),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Tomato Early Blight Detected', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    Text('Confidence: 94.5%', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Symptoms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('• Dark spots with concentric rings on lower leaves.\n• Yellowing around the spots.\n• Premature leaf drop.', style: TextStyle(height: 1.5)),
        const SizedBox(height: 16),
        const Text('Recommended Treatment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('• Apply copper-based fungicides.\n• Remove and destroy infected plant parts.\n• Improve air circulation around plants.', style: TextStyle(height: 1.5)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _showResult = false),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: AppColors.textPrimary),
          child: const Text('Scan Another'),
        ),
      ],
    );
  }
}
