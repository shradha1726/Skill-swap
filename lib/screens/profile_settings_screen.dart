// lib/screens/profile_settings_screen.dart

// ignore_for_file: prefer_final_fields

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _skillsOfferedController = TextEditingController();
  TextEditingController _skillsWantedController = TextEditingController();
  TextEditingController _availabilityController = TextEditingController();

  File? _newProfileImageFile;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      final data = doc.data();

      _displayNameController.text = _user!.displayName ?? '';
      _profileImageUrl = _user!.photoURL ?? '';

      if (data != null) {
        _skillsOfferedController.text =
            (data['skillsOffered'] as List<dynamic>?)?.join(', ') ?? '';
        _skillsWantedController.text =
            (data['skillsWanted'] as List<dynamic>?)?.join(', ') ?? '';
        _availabilityController.text = data['availability'] ?? '';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickNewProfileImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _newProfileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_newProfileImageFile == null || _user == null) return null;

    final ref = _storage.ref().child('profile_pictures/${_user!.uid}.jpg');
    final uploadTask = ref.putFile(_newProfileImageFile!);
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? uploadedImageUrl = _profileImageUrl;

      if (_newProfileImageFile != null) {
        uploadedImageUrl = await _uploadProfileImage();
      }

      // Update Firebase Auth profile
      await _user?.updateDisplayName(_displayNameController.text.trim());
      if (uploadedImageUrl != null) {
        await _user?.updatePhotoURL(uploadedImageUrl);
      }
      await _user?.reload();
      _user = _auth.currentUser;

      // Update Firestore user document
      await _firestore.collection('users').doc(_user!.uid).set({
        'skillsOffered': _parseSkills(_skillsOfferedController.text),
        'skillsWanted': _parseSkills(_skillsWantedController.text),
        'availability': _availabilityController.text.trim(),
        'profileImageUrl': uploadedImageUrl ?? '',
        'displayName': _displayNameController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile. Please try again.';
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

  @override
  void dispose() {
    _displayNameController.dispose();
    _skillsOfferedController.dispose();
    _skillsWantedController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickNewProfileImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _newProfileImageFile != null
                            ? FileImage(_newProfileImageFile!)
                            : (_profileImageUrl != null &&
                                    _profileImageUrl!.isNotEmpty)
                                ? NetworkImage(_profileImageUrl!)
                                    as ImageProvider
                                : const AssetImage('assets/default_avatar.png'),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(
                              Icons.camera_alt,
                              size: 22,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Display Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateRequired,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skillsOfferedController,
                          decoration: const InputDecoration(
                            labelText: 'Skills Offered (comma separated)',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateRequired,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skillsWantedController,
                          decoration: const InputDecoration(
                            labelText: 'Skills Wanted (comma separated)',
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _saveProfile,
                          child: const Text('Save Changes'),
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
