import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/model/vendor_model.dart';

class VendorProvider with ChangeNotifier {
  final FirebaseServices _services = FirebaseServices();
  DocumentSnapshot? doc;
  Vendor? vendor;

  getVendorData() {
    _services.vendor.doc(_services.user!.uid).get().then(
      (document) {
        doc = document;
        vendor = Vendor.fromJson(document.data() as Map<String,
            dynamic>); //so that the data can be used in add_product_screen
        notifyListeners();
      },
    );
  }
}
