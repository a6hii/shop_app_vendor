import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_vendor/provider/vendor_provider.dart';
import 'package:shop_app_vendor/screens/add_product_screen.dart';
import 'package:shop_app_vendor/screens/home_screen.dart';
import 'package:shop_app_vendor/screens/login_screen.dart';
import 'package:shop_app_vendor/screens/product_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _vendorData = Provider.of<VendorProvider>(context);

    Widget _menu({String? menuTitle, IconData? icon, String? route}) {
      return ListTile(
        leading: icon == null
            ? null
            : Icon(
                icon), //remove ternary operation to make the label text align with other main menu labels
        title: Text(menuTitle!),
        onTap: () {
          Navigator.of(context).pushReplacementNamed(route!);
        },
        //style: ListTileStyle.list,
      );
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            color: Theme.of(context).primaryColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DrawerHeader(
                  margin: null,
                  child: _vendorData.doc == null
                      ? const Text('Fetching...')
                      : Row(
                          children: [
                            CachedNetworkImage(
                                imageUrl: _vendorData.doc!['logo']),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(_vendorData.doc!['businessName']),
                          ],
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _menu(
                  menuTitle: 'Home',
                  icon: Icons.home_outlined,
                  route: HomeScreen.id,
                ),
                ExpansionTile(
                  leading: const Icon(Icons.weekend_outlined),
                  title: const Text('Products'),
                  children: [
                    _menu(
                      menuTitle: 'All Products',
                      route: ProductScreen.id,
                    ),
                    _menu(
                      menuTitle: 'Add Product',
                      route: AddProductScreen.id,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          ListTile(
            title: const Text("Sign out"),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(LoginScreen.id);
            },
          ),
        ],
      ),
    );
  }
}
