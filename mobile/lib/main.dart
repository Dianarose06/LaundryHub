import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/edit_profile_screen.dart';
import 'services/auth_service.dart';
import 'models/profile_model.dart';
import 'theme/laundryhub_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    FlutterError.onError = (errorDetails) {
      if (errorDetails.exception.toString().contains('fonts.gstatic') ||
          errorDetails.exception.toString().contains('Failed to fetch')) {
        return;
      }
      FlutterError.presentError(errorDetails);
    };
  }

  runApp(const LaundryHubApp());
}

class LaundryHubApp extends StatelessWidget {
  const LaundryHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaundryHub',
      debugShowCheckedModeBanner: false,
      theme: LaundryHubTheme.light(),
      home: _SplashGate(),
      onGenerateRoute: (settings) {
        if (settings.name == '/edit-profile') {
          final args = settings.arguments as CustomerProfile?;
          return MaterialPageRoute(
            builder: (context) => EditProfileScreen(profile: args),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    // Run auth check and minimum brand display in parallel.
    // Navigate as soon as BOTH are done — no unnecessary waiting.
    _initApp();
  }

  Future<void> _initApp() async {
    // Run auth check and a 1.0 second minimum brand display concurrently.
    // This ensures the logo is visible for approximately 1.0 seconds only,
    // avoiding glitchy instantaneous blinks while still being extremely fast.
    final results = await Future.wait([
      _resolveAuthDestination(),
      Future.delayed(const Duration(milliseconds: 1000)),
    ]);

    if (!mounted) return;

    final destination = results[0] as Widget;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => destination,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<Widget> _resolveAuthDestination() async {
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getUser();

      if (token != null && user != null) {
        final role = user['role']?.toString().toLowerCase() ?? 'user';
        if (role == 'admin') {
          await AuthService.logout();
          return const LoginScreen();
        }
        return const MainShell();
      }
    } catch (_) {
      // On any error, fall through to login
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaundryHubColors.primary,
      body: Center(
        child: SizedBox(
          width: 250,
          height: 250,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image,
                size: 100,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }
}
