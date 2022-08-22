import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:shop_app_vendor/screens/landing_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      // If the user is already signed-in, use it as initial data
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData) {
          return Scaffold(
            //avoids renderflex error
            body: SignInScreen(
                headerBuilder: (context, constraints, _) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Center(
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Shop App',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Vendor',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                subtitleBuilder: (context, action) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      action == AuthAction.signIn
                          ? 'Welcome to Shop App Vendor! Please sign in to continue.'
                          : 'Welcome to Shop App Vendor! Please create an account to continue',
                    ),
                  );
                },
                footerBuilder: (context, _) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'By signing in, you agree to our terms and conditions.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                providerConfigs: const [
                  EmailProviderConfiguration(),
                  GoogleProviderConfiguration(
                      clientId:
                          '73471013962-44mujo9va3q3virg3bffna61qa3f23t3.apps.googleusercontent.com'),
                  PhoneProviderConfiguration(),
                ]),
          );
        }

        // Render your application if authenticated
        return const LandingScreen();
      },
    );
  }
}
