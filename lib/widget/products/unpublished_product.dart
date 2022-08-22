//For products sent for approval

import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:shop_app_vendor/model/product_model.dart';
import 'package:shop_app_vendor/widget/products/product_card.dart';

class UnPublishedProduct extends StatelessWidget {
  const UnPublishedProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder<Product>(
      query: productQuery(false),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong! ${snapshot.error}'));
        }
        if (snapshot.docs.isEmpty) {
          return const Center(
            child: Text('No products to show'),
          );
        }

        return ProductCard(
          snapshot: snapshot,
        );
      },
    );
  }
}
