import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier {
  Map<String, dynamic>? productData = {
    'approved': false,
  };
  List<XFile>? imageFiles = [];

  getFormData({
    String? productName,
    int? regularPrice,
    int? salesPrice,
    String? taxStatus,
    double? taxPercentage,
    String? category,
    String? mainCategory,
    String? subCategory,
    String? description,
    DateTime? scheduledDate,
    String? sku,
    bool? manageInventory,
    int? stockOnHand, //soh in tutorial
    int? reOrderLevel,
    bool? isShippingChargeable,
    int? shippingCharge,
    String? brand,
    String? brandDescription,
    List? sizeList,
    String? unit,
    List? imageUrls,
    Map? seller,
  }) {
    if (productName != null) {
      productData!['productName'] = productName;
    }
    if (regularPrice != null) {
      productData!['regularPrice'] = regularPrice;
    }
    if (salesPrice != null) {
      productData!['salesPrice'] = salesPrice;
    }
    if (taxStatus != null) {
      productData!['taxStatus'] = taxStatus;
    }
    if (taxPercentage != null) {
      productData!['taxPercentage'] = taxPercentage;
    }
    if (category != null) {
      productData!['category'] = category;
    }
    if (mainCategory != null) {
      productData!['mainCategory'] = mainCategory;
    }
    if (subCategory != null) {
      productData!['subCategory'] = subCategory;
    }
    if (description != null) {
      productData!['description'] = description;
    }
    if (scheduledDate != null) {
      productData!['scheduledDate'] = scheduledDate;
    }
    if (sku != null) {
      productData!['sku'] = sku;
    }
    if (manageInventory != null) {
      productData!['manageInventory'] = manageInventory;
    }
    if (stockOnHand != null) {
      productData!['stockOnHand'] = stockOnHand;
    }
    if (reOrderLevel != null) {
      productData!['reOrderLevel'] = reOrderLevel;
    }
    if (isShippingChargeable != null) {
      productData!['isShippingChargeable'] = isShippingChargeable;
    }
    if (shippingCharge != null) {
      productData!['shippingCharge'] = shippingCharge;
    }
    if (brand != null) {
      productData!['brand'] = brand;
    }
    if (brandDescription != null) {
      productData!['brandDescription'] = brandDescription;
    }
    if (sizeList != null) {
      productData!['size'] = sizeList;
    }
    if (unit != null) {
      productData!['unit'] = unit;
    }
    if (imageUrls != null) {
      productData!['imageUrls'] = imageUrls;
    }
    if (seller != null) {
      productData!['seller'] = seller;
    }
    notifyListeners();
  }

  getImageFile(image) {
    imageFiles!.add(image);
    notifyListeners();
  }

  clearProductData() {
    productData!.clear();
    imageFiles!.clear();
    productData!['approved'] = false;
    notifyListeners();
  }
}
