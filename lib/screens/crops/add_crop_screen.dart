import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/crop.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _variety = TextEditingController();
  final _farm = TextEditingController();
  final _area = TextEditingController();
  String soil = 'Loamy';
  DateTime planted = DateTime.now();
  DateTime harvest = DateTime.now().add(const Duration(days: 90));

  @override
  void dispose() {
    _name.dispose();
    _variety.dispose();
    _farm.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool planting) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: planting ? planted : harvest,
    );
    if (picked == null) return;
    setState(() {
      if (planting) {
        planted = picked;
      } else {
        harvest = picked;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final crop = Crop(
      id: 'crop-${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      variety: _variety.text.trim().isEmpty ? 'Standard' : _variety.text.trim(),
      farmName: _farm.text.trim().isEmpty ? 'My Farm' : _farm.text.trim(),
      plantedOn: planted,
      expectedHarvest: harvest,
      progress: 0,
      health: CropHealth.good,
      areaAcres: double.tryParse(_area.text) ?? 1,
    );
    Navigator.pop(context, crop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add crop', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 42),
                  SizedBox(height: 8),
                  Text('Crop image is optional', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Crop name',
                prefixIcon: Icon(Icons.eco_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter crop name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _variety,
              decoration: const InputDecoration(labelText: 'Variety', hintText: 'e.g. Roma'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _farm,
              decoration: const InputDecoration(
                labelText: 'Farm name',
                prefixIcon: Icon(Icons.landscape_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _area,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Area (acres)',
                prefixIcon: Icon(Icons.square_foot_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(true),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('${planted.day}/${planted.month}/${planted.year}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(false),
                    icon: const Icon(Icons.event_available_outlined),
                    label: Text('${harvest.day}/${harvest.month}/${harvest.year}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: soil,
              decoration: const InputDecoration(
                labelText: 'Soil type',
                prefixIcon: Icon(Icons.layers_outlined),
              ),
              items: ['Clay', 'Sandy', 'Loamy', 'Silty']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => soil = v ?? soil),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save crop'),
            ),
          ],
        ),
      ),
    );
  }
}
