// lib/screens/profile_setup_screen.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _skillsOfferedController =
      TextEditingController();
  final TextEditingController _skillsWantedController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();

  File? _profileImage;
  final List<File> _skillImages = [];

  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _skillsOfferedController.dispose();
    _skillsWantedController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickSkillImages() async {
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 75);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _skillImages.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<String> _uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  List<String> _parseSkills(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImage == null) {
      setState(() {
        _errorMessage = 'Please upload a profile picture';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'User not logged in';
        });
        return;
      }

      // Upload profile picture
      final profileImageUrl =
          await _uploadFile(_profileImage!, 'profile_pictures/${user.uid}.jpg');

      // Upload skill images (optional)
      List<String> skillImageUrls = [];
      for (var i = 0; i < _skillImages.length; i++) {
        final url = await _uploadFile(
            _skillImages[i], 'skill_images/${user.uid}_$i.jpg');
        skillImageUrls.add(url);
      }

      // Prepare profile data
      final profileData = {
        'skillsOffered': _parseSkills(_skillsOfferedController.text),
        'skillsWanted': _parseSkills(_skillsWantedController.text),
        'availability': _availabilityController.text.trim(),
        'profileImageUrl': profileImageUrl,
        'skillImageUrls': skillImageUrls,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );

      // Navigate to Home or next screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_profileImage != null)
          CircleAvatar(
            radius: 50,
            backgroundImage: FileImage(_profileImage!),
          )
        else
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
        TextButton.icon(
          onPressed: _pickProfileImage,
          icon: const Icon(Icons.upload),
          label: const Text('Upload Profile Picture'),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skillImages
              .map((file) => Stack(
                    children: [
                      Image.file(file,
                          width: 80, height: 80, fit: BoxFit.cover),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _skillImages.remove(file);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
        TextButton.icon(
          onPressed: _pickSkillImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add Skill Images (Optional)'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _skillsOfferedController,
                    decoration: const InputDecoration(
                      labelText: 'Skill(s) Offered (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateRequired,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillsWantedController,
                    decoration: const InputDecoration(
                      labelText: 'Skill(s) Wanted (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateRequired,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _availabilityController,
                    decoration: const InputDecoration(
                      labelText: 'Availability',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateRequired,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    ErrorMessage(message: _errorMessage!),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const LoadingIndicator()
                      : SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Save Profile'),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
