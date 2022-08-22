import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_vendor/provider/vendor_provider.dart';
import 'package:shop_app_vendor/widget/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _vendorData = Provider.of<VendorProvider>(context);
    if (_vendorData.doc == null) {
      _vendorData.getVendorData();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Dashboard"),
      ),
      drawer: const CustomDrawer(),
      body: const Center(child: Text('Home')),
    );
  }
}
