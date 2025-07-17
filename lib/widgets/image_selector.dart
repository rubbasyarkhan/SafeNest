// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';

// class ImageSelector extends StatefulWidget {
//   final String? initialImageBase64;
//   final ValueChanged<String>? onImageSelected; // ✅ Callback

//   const ImageSelector({
//     super.key,
//     this.initialImageBase64,
//     this.onImageSelected,
//   });

//   @override
//   State<ImageSelector> createState() => _ImageSelectorState();
// }

// class _ImageSelectorState extends State<ImageSelector> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   String? _base64Image;

//   @override
//   void initState() {
//     super.initState();
//     _base64Image = widget.initialImageBase64;
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       final bytes = await picked.readAsBytes();
//       final base64img = base64Encode(bytes);
//       _updateImage(base64img);
//     }
//   }

//   Future<void> _updateImage(String base64img) async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     setState(() {
//       _base64Image = base64img;
//     });

//     // ✅ Save to Firestore
//     await _firestore.collection('users').doc(uid).update({
//       'image': base64img,
//     });

//     // ✅ Notify parent
//     if (widget.onImageSelected != null) {
//       widget.onImageSelected!(base64img);
//     }

//     Fluttertoast.showToast(msg: "✅ Image updated");
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageWidget = _base64Image != null
//         ? CircleAvatar(
//             radius: 50,
//             backgroundImage: MemoryImage(base64Decode(_base64Image!)),
//           )
//         : const CircleAvatar(
//             radius: 50,
//             child: Icon(Icons.person, size: 40),
//           );

//     return GestureDetector(
//       onTap: _pickImage,
//       child: imageWidget,
//     );
//   }
// }
