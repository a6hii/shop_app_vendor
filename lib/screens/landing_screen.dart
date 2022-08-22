import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/model/vendor_model.dart';
import 'package:shop_app_vendor/screens/home_screen.dart';
import 'package:shop_app_vendor/screens/login_screen.dart';
import 'package:shop_app_vendor/screens/registration_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _services.vendor.doc(_services.user!.uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const RegistrationScreen();
          }

          Vendor vendor =
              Vendor.fromJson(snapshot.data!.data() as Map<String, dynamic>);

          if (vendor.approved == true) {
            return const HomeScreen();
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: vendor.logo!,
                        placeholder: (context, url) => Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    vendor.businessName!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Landing Screen \n Your application has been sent. Wait for confirmation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          elevation: MaterialStateProperty.all(4.0)),
                      onPressed: () {
                        FirebaseAuth.instance.signOut().then((value) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const LoginScreen()),
                          );
                        });
                      },
                      child: const Text(
                        'Sign out',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
