import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _password = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _authService = AuthService();

  bool _isLoading = false;
  String? _base64Image;
  late Color avatarColor;

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.deepPurple,
    Colors.teal,
    Colors.indigo,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    avatarColor = _colors[Random().nextInt(_colors.length)];
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!mounted) return;
    if (doc.exists) {
      final data = doc.data()!;
      _name.text = data['name'] ?? '';
      _phone.text = data['phone'] ?? '';
      _bio.text = data['bio'] ?? '';
      setState(() {
        _base64Image = data['image'];
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64img = base64Encode(bytes);

      setState(() {
        _base64Image = base64img;
      });

      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({'image': base64img});
      Fluttertoast.showToast(msg: "✅ Image updated");
    }
  }

  Future<void> updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final uid = _auth.currentUser!.uid;

        await _firestore.collection('users').doc(uid).set({
          'name': _name.text.trim(),
          'phone': _phone.text.trim(),
          'bio': _bio.text.trim(),
          'image': _base64Image,
        }, SetOptions(merge: true));

        if (_password.text.isNotEmpty) {
          await _auth.currentUser!.updatePassword(_password.text.trim());
        }

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Profile updated successfully!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameInitial = _name.text.isNotEmpty ? _name.text[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: _base64Image != null && _base64Image!.isNotEmpty
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: MemoryImage(base64Decode(_base64Image!)),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: avatarColor,
                              child: Text(
                                nameInitial,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: "Full Name"),
                      validator: (value) => value!.isEmpty ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Phone (+92xxxxxxxxxx)"),
                      validator: (value) {
                        if (value!.isEmpty) return "Enter phone";
                        if (!value.startsWith('+')) {
                          return "Include country code e.g. +92";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _bio,
                      decoration: const InputDecoration(labelText: "Bio"),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "New Password (optional)"),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return "Minimum 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Update Profile",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
