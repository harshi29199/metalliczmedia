
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'Utils/all_imports.dart'; // Ensure this includes all your screens, providers, colors, etc.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  HttpOverrides.global = MyHttpOverrides(); // Set before runApp
  runApp(const MyAppProviders());
}

/// Allow bad SSL certificates (for development only)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Top-level provider wrapper
class MyAppProviders extends StatelessWidget {
  const MyAppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => StoreOverviewProvider()),
        ChangeNotifierProvider(create: (_) => CameraElementProvider()),
      ],
      child: const ConnectivityWrapper(), // 👈 Manages network state
    );
  }
}

/// Handles online/offline switching
class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({super.key});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((result) => result != ConnectivityResult.none);
      setState(() {
        _isOffline = !isConnected;
      });
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    final isConnected = results.any((result) => result != ConnectivityResult.none);
    setState(() {
      _isOffline = !isConnected;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NoInternetScreen(),
      );
    }
    return const MyApp();
  }
}

/// Root MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metallicz Media Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
      ),
      home: const SplashScreen(),
    );
  }
}

/// Offline UI screen
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:  [
            Center(
                child: Lottie.asset(
                  'assets/Icons/nointernet.json',
                  height: screenHeight * 0.25,
                  fit: BoxFit.cover,
                )),
            SizedBox(height: 20),
            Text(
              "No Internet Connection",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "Please check your connection and try again.",
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
