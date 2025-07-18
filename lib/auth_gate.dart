import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_calorie_flutter/home_scaffold.dart';
import 'package:smart_calorie_flutter/screens/login_screen.dart';
import 'package:smart_calorie_flutter/screens/onboarding/onboarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // User is logged in, check if their profile is created (onboarding complete)
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).snapshots(),
          builder: (context, profileSnapshot) {
            // While checking, show a loading spinner
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // If profile exists, they are onboarded. Go to the main app layout.
            if (profileSnapshot.hasData && profileSnapshot.data!.exists) {
              return const HomeScaffold();
            } 
            
            // Otherwise, they need to complete onboarding.
            else {
              return const OnboardingScreen();
            }
          },
        );
      },
    );
  }
}