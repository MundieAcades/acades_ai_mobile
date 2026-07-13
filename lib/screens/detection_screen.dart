import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../services/detection_service.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  File? _image;
  bool _isDetecting = false;
  String? _label;
  double? _confidence;
  String? _notes;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pick(ImageSource src) async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: src, imageQuality: 80);
      if (picked == null) return;
      setState(() {
        _image = File(picked.path);
        _label = null;
        _confidence = null;
        _notes = null;
      });
      await _detect();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _detect() async {
    if (_image == null) return;
    setState(() => _isDetecting = true);
    try {
      final res = await DetectionService.detect(_image!);
      if (!mounted) return;
      setState(() {
        _label = res['label']?.toString();
        _confidence = (res['confidence'] is num)
            ? (res['confidence'] as num).toDouble()
            : null;
        _notes = res['notes']?.toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Detection failed')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isDetecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Detect Crop Disease',
            style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: Center(
                  child: _image == null
                      ? const Text('No image selected',
                          style: TextStyle(color: AppColors.textMuted))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Take Photo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isDetecting) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 12),
                const Text('Analyzing image... Please wait',
                    textAlign: TextAlign.center),
              ],
              if (_label != null && !_isDetecting) ...[
                const Divider(height: 28),
                Text('Result: $_label',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                if (_confidence != null)
                  Text(
                      'Confidence: ${((_confidence ?? 0) * 100).toStringAsFixed(0)}%'),
                if (_notes != null) ...[
                  const SizedBox(height: 8),
                  Text(_notes!),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: () {
                    // Placeholder: future action could open advice article or start treatment plan
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved observation')));
                  },
                  child: const Text('Save Observation'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
