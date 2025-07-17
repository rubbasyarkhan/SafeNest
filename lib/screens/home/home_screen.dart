import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? fullName;
  String? email;
  String? base64Image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            fullName = data['name'] ?? 'Unknown';
            email = data['email'] ?? user.email ?? 'No Email';
            base64Image = data['image'];
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameInitial = (fullName != null && fullName!.isNotEmpty)
        ? fullName![0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Eco Living",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _showProfileModal(context),
              child: base64Image != null && base64Image!.isNotEmpty
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: MemoryImage(base64Decode(base64Image!)),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.teal,
                      child: Text(
                        nameInitial,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to the Home Screen 🌿",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    final nameInitial = (fullName != null && fullName!.isNotEmpty)
        ? fullName![0].toUpperCase()
        : '?';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              base64Image != null && base64Image!.isNotEmpty
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: MemoryImage(base64Decode(base64Image!)),
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.teal,
                      child: Text(
                        nameInitial,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              Text(
                fullName ?? "Loading...",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                email ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
              const Divider(height: 30, thickness: 1.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
