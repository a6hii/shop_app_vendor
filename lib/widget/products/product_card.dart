import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:search_page/search_page.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/model/product_model.dart';
import 'package:shop_app_vendor/widget/products/product_details_screen.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({Key? key, this.snapshot}) : super(key: key);

  final FirestoreQueryBuilderSnapshot? snapshot;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final FirebaseServices? _services = FirebaseServices();
  List<Product> _productsList = [];
  @override
  void initState() {
    getProductList();
    super.initState();
  }

  getProductList() {
    return widget.snapshot!.docs.forEach((element) {
      Product product = element.data();
      setState(() {
        _productsList.add(Product(
          approved: product.approved,
          productName: product.productName,
          regularPrice: product.regularPrice,
          salesPrice: product.salesPrice,
          taxStatus: product.taxStatus,
          taxPercentage: product.taxPercentage,
          category: product.category,
          subCategory: product.subCategory,
          mainCategory: product.mainCategory,
          description: product.description,
          scheduledDate: product.scheduledDate,
          sku: product.sku,
          manageInventory: product.manageInventory,
          stockOnHand: product.stockOnHand,
          reOrderLevel: product.reOrderLevel,
          isShippingChargeable: product.isShippingChargeable,
          shippingCharge: product.shippingCharge,
          brand: product.brand,
          brandDescription: product.brandDescription,
          sizeList: product.sizeList,
          unit: product.unit,
          imageUrls: product.imageUrls,
          seller: product.seller,
          productId: element.id,
        ));
      });
    });
  }

  Widget _products() {
    return ListView.builder(
        itemCount: widget.snapshot!.docs.length,
        itemBuilder: (context, index) {
          Product product = widget.snapshot!.docs[index].data();
          String id = widget.snapshot!.docs[index].id;

          var discountRate = ((product.regularPrice! - product.salesPrice!) /
                  product.regularPrice!) *
              100.00;

          return Slidable(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext contect) => ProductDetailsScreen(
                          product: product,
                          productId: id,
                        )));
              },
              child: Card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: 80,
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                              imageUrl: product.imageUrls![0]),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.productName!),
                          Row(
                            children: [
                              Text(
                                _services!.formattedPrice(product.regularPrice),
                                style: TextStyle(
                                    decoration: product.salesPrice != null
                                        ? TextDecoration.lineThrough
                                        : null),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              if (product.salesPrice != null)
                                Text(_services!
                                    .formattedPrice(product.salesPrice)),
                            ],
                          ),
                          Text(
                            '${discountRate.toInt()}%',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            endActionPane: ActionPane(motion: const ScrollMotion(), children: [
              SlidableAction(
                // An action can be bigger than the others.
                flex: 1,
                onPressed: (context) {
                  _services!.product.doc(id).delete();
                },
                backgroundColor: const Color.fromARGB(255, 235, 13, 13),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
              SlidableAction(
                flex: 1,
                onPressed: (context) {
                  _services!.product.doc(id).update(
                      {'approved': product.approved == false ? true : false});
                },
                backgroundColor: const Color.fromARGB(255, 18, 189, 12),
                foregroundColor: Colors.white,
                icon: Icons.approval,
                label: product.approved == false ? 'Approve' : 'Inactive',
              ),
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    contentPadding:
                        EdgeInsets.only(bottom: 8, left: 10, right: 10),
                    fillColor: Colors.white,
                    filled: true,
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: SearchPage<Product>(
                        //onQueryUpdate: (s) => print(s),
                        items: _productsList,
                        searchLabel: 'Search product',
                        suggestion: _products(),
                        failure: Center(
                          child: Text('No products found :('),
                        ),
                        filter: (product) => [
                          product.productName,
                          product.category,
                          product.mainCategory,
                          product.subCategory,
                          product.brand,
                          product.sku
                        ],
                        builder: (product) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (BuildContext contect) =>
                                      ProductDetailsScreen(
                                    product: product,
                                    productId: product.productId,
                                  ),
                                ),
                              )
                                  .whenComplete(() {
                                _productsList.clear;
                                getProductList();
                              });
                            },
                            child: Card(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CachedNetworkImage(
                                            imageUrl: product.imageUrls![0]),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(product.productName!),
                                        Row(
                                          children: [
                                            Text(
                                              _services!.formattedPrice(
                                                  product.regularPrice),
                                              style: TextStyle(
                                                  decoration:
                                                      product.salesPrice != null
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            if (product.salesPrice != null)
                                              Text(_services!.formattedPrice(
                                                  product.salesPrice)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Total products-${widget.snapshot!.docs.length}'),
                    ),
                  ),
                  Expanded(
                    child: _products(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
