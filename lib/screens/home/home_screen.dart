import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safenest/screens/contact/contacts_screen.dart';
import '../../services/location_service.dart';
import '../../services/video_service.dart'; // ⬅️ NEW video service

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
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
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

      if (!mounted || position == null) return;

      final latitude = position.latitude;
      final longitude = position.longitude;
      final googleMapsLink =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          final savedLat = data?['latitude'];
          final savedLng = data?['longitude'];

          if (savedLat == null ||
              savedLng == null ||
              (savedLat - latitude).abs() > 0.0001 ||
              (savedLng - longitude).abs() > 0.0001) {
            await docRef.update({
              'latitude': latitude,
              'longitude': longitude,
              'locationLink': googleMapsLink,
              'locationUpdatedAt': FieldValue.serverTimestamp(),
            });
            print("✅ Location updated in Firebase.");
          } else {
            print("ℹ️ Location already saved, no update needed.");
          }
        }
      }

      // 🗺️ Show dialog
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
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location error: $e")));
    }
  }

  Future<void> _recordVideo() async {
    try {
      final filePath = await VideoService.recordVideo();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("🎥 Video saved at: $filePath")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Camera error: $e")));
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

            // 📍 Get Location Button
            ElevatedButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.location_on),
              label: const Text("Get My Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // 🎥 Record Video Button
            ElevatedButton.icon(
              onPressed: _recordVideo,
              icon: const Icon(Icons.videocam),
              label: const Text("Record Video"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),

           ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactsScreen()),
    );
  },
  icon: const Icon(Icons.contacts),
  label: const Text("My Contacts"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey,
    foregroundColor: Colors.white,
  ),
),

         
         
          ],
        ),
      ),
    );
  }
}
