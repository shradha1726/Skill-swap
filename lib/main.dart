import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/swipe_screen.dart';
import 'screens/match_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_settings_screen.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SkillSwapApp());
}

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      theme: appTheme,
      initialRoute: '/splash',

      // Define static routes for screens without required parameters
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/emailVerification': (context) => const EmailVerificationScreen(),
        '/profileSetup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/swipe': (context) => const SwipeScreen(),
        '/match': (context) => const MatchScreen(),
        '/profileSettings': (context) => const ProfileSettingsScreen(),
      },

      // Handle routes that require parameters here
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null ||
              !args.containsKey('chatUserId') ||
              !args.containsKey('chatUserName')) {
            // If arguments are missing, you can redirect or show error
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Missing chat parameters')),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatUserId: args['chatUserId'] as String,
              chatUserName: args['chatUserName'] as String,
            ),
          );
        }

        // Return null for unknown routes to show error or fallback
        return null;
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
