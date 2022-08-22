import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/provider/product_provider.dart';
import 'package:shop_app_vendor/provider/vendor_provider.dart';
import 'package:shop_app_vendor/screens/images_screen.dart';
import 'package:shop_app_vendor/widget/add_product/attribute_tab.dart';
import 'package:shop_app_vendor/widget/add_product/general_tab.dart';
import 'package:shop_app_vendor/widget/add_product/inventory_tab.dart';
import 'package:shop_app_vendor/widget/add_product/shipping_tab.dart';
import 'package:shop_app_vendor/widget/custom_drawer.dart';

class AddProductScreen extends StatefulWidget {
  static const String id = 'add-product-screen';
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<ProductProvider>(context);
    final _vendorProvider = Provider.of<VendorProvider>(context);

    return Form(
      key: _formKey,
      child: DefaultTabController(
        length: 6,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            //replace with back button is more ideal
            elevation: 0,
            title: const Text('Add a Product'),
            bottom: const TabBar(
              isScrollable: true,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4, color: Colors.yellow)),
              tabs: [
                Tab(
                  child: Text("General"),
                ),
                Tab(
                  child: Text("Inventory"),
                ),
                Tab(
                  child: Text("Shipping"),
                ),
                Tab(
                  child: Text("Attribute"),
                ),
                Tab(
                  child: Text("Linked Products"),
                ),
                Tab(
                  child: Text("Images"),
                ),
              ],
            ),
          ),
          drawer: const CustomDrawer(),
          body: const TabBarView(
            children: [
              GeneralTab(),
              InventoryTab(),
              ShippingTab(),
              AttributeTab(),
              Center(
                child: Text("Linked products Tab"),
              ),
              ImagesScreen(),
            ],
          ),
          persistentFooterButtons: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_provider.imageFiles!.isEmpty) {
                    _services.scaffold(context, 'Image not selected');
                    return;
                  }

                  if (_formKey.currentState!.validate()) {
                    //save to firebase
                    EasyLoading.show(status: 'Please wait...');
                    _provider.getFormData(seller: {
                      'name': _vendorProvider.vendor!.businessName,
                      'uid': _services.user!.uid,
                    });
                    _services
                        .uploadfiles(
                            images: _provider.imageFiles,
                            ref:
                                'products/${_vendorProvider.vendor!.businessName}/${_provider.productData!['productName']}',
                            provider: _provider)
                        .then((value) {
                      if (value.isNotEmpty) {
                        _services
                            .saveToDb(
                          data: _provider.productData,
                          context: context,
                        )
                            .then((value) {
                          EasyLoading.dismiss();
                          setState(() {
                            _provider.clearProductData();
                          });
                        });
                      }
                    });
                  }
                },
                child: const Text("Save Product"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
