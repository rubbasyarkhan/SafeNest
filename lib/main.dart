import 'package:flutter/foundation.dart'; // for kReleaseMode
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safenest/screens/home/profile_screen.dart';
import 'package:safenest/screens/home/splahsecond_screen.dart';

import 'firebase_options.dart';

// Import Routes
import 'routes/app_routes.dart';

// Import Screens
import 'screens/home/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Only enabled in debug mode
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Living App',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // Important for DevicePreview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.splashscreen2: (context) => const SplahsecondScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),  
        AppRoutes.profile: (context) => const ProfileScreen(),

        AppRoutes.home: (context) => const HomeScreen(),

      },
    );
  }
}