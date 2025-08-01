import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safenest/models/contact_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _addContactDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    String? base64Image;

    Future<void> _pickImage(StateSetter setModalState) async {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setModalState(() {
          base64Image = base64Encode(bytes);
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text("Add Contact"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _pickImage(setModalState),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: base64Image != null
                        ? MemoryImage(base64Decode(base64Image!))
                        : null,
                    child: base64Image == null
                        ? const Icon(Icons.add_a_photo, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = _auth.currentUser;
                if (user != null) {
                  final contact = ContactModel(
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    image: base64Image,
                  );

                  await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection('contacts')
                      .add(contact.toJson());

                  Navigator.pop(ctx);
                  Fluttertoast.showToast(msg: "✅ Contact added");
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Contacts"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addContactDialog,
          )
        ],
      ),
      body: user == null
          ? const Center(child: Text("Not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('contacts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading contacts"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final contacts = snapshot.data!.docs
                    .map((doc) => ContactModel.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();

                if (contacts.isEmpty) {
                  return const Center(child: Text("No contacts yet"));
                }

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      leading: contact.image != null && contact.image!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(base64Decode(contact.image!)),
                            )
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(contact.name ?? 'No Name'),
                      subtitle: Text("${contact.phone ?? ''}\n${contact.email ?? ''}"),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
    );
  }
}
