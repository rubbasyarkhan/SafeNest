import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../routes/app_routes.dart';
import '../../services/location_service.dart'; // ← Import location service

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
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
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

 Future<void> _getLocation() async {
  try {
    final position = await LocationService.getCurrentLocation();

    if (!mounted) return;

    if (position != null) {
      final latitude = position.latitude;
      final longitude = position.longitude;
      final googleMapsLink =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

      print("📍 Google Maps Link: $googleMapsLink");

      // 🔥 Save to Firestore only if location is not already saved
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          final savedLat = data?['latitude'];
          final savedLng = data?['longitude'];

          // Check if saved location already exists and is similar (to avoid redundant updates)
          if (savedLat == null || savedLng == null || 
              (savedLat - latitude).abs() > 0.0001 || 
              (savedLng - longitude).abs() > 0.0001) {
            await docRef.update({
              'latitude': latitude,
              'longitude': longitude,
              'locationLink': googleMapsLink,
            });
            print("✅ Location updated in Firebase.");
          } else {
            print("ℹ️ Location already saved, no update needed.");
          }
        }
      }

      // 🗺️ Show location dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Your Location"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Latitude: $latitude"),
              Text("Longitude: $longitude"),
              const SizedBox(height: 10),
              SelectableText(
                googleMapsLink,
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Location error: $e")));
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Eco Living",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: GestureDetector(
        //       onTap: () => _showProfileModal(context),
        //       child: base64Image != null && base64Image!.isNotEmpty
        //           ? CircleAvatar(
        //               radius: 20,
        //               backgroundImage: MemoryImage(base64Decode(base64Image!)),
        //             )
        //           : CircleAvatar(
        //               radius: 20,
        //               backgroundColor: Colors.teal,
        //               child: Text(
        //                 nameInitial,
        //                 style: const TextStyle(
        //                   fontWeight: FontWeight.bold,
        //                   fontSize: 18,
        //                   color: Colors.white,
        //                 ),
        //               ),
        //             ),
        //     ),
        //   ),
        // ],
      
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to the Home Screen 🌿",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.location_on),
              label: const Text("Get My Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

 
}
