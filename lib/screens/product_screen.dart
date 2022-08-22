import 'package:flutter/material.dart';
import 'package:shop_app_vendor/widget/custom_drawer.dart';
import 'package:shop_app_vendor/widget/products/published_product.dart';
import 'package:shop_app_vendor/widget/products/unpublished_product.dart';

//Product List page
class ProductScreen extends StatelessWidget {
  static const String id = 'product-screen';
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          //replacing with back button is more logical
          elevation: 0,
          title: const Text('Products List'),
          bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 4,
                  color: Colors.indigo.shade200,
                ),
              ),
              tabs: const [
                Tab(
                  child: Text('Products for approval'),
                ),
                Tab(
                  child: Text('Products approved'),
                ),
              ]),
        ),
        drawer: const CustomDrawer(),
        body: const TabBarView(
          children: [
            UnPublishedProduct(),
            PublishedProduct(),
          ],
        ),
      ),
    );
  }
}
