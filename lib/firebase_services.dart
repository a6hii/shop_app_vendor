import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:shop_app_vendor/provider/product_provider.dart';

class FirebaseServices {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference vendor =
      FirebaseFirestore.instance.collection('vendor');
  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference mainCategories =
      FirebaseFirestore.instance.collection('mainCategories');
  final CollectionReference subCategories =
      FirebaseFirestore.instance.collection('subCategories');
  final CollectionReference product =
      FirebaseFirestore.instance.collection('product');

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> uploadImage(XFile? filePath, String? reference) async {
    File file = File(filePath!.path);
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref(reference);

    await ref.putFile(file);
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<List> uploadfiles(
      {List<XFile>? images, String? ref, ProductProvider? provider}) async {
    var imageUrls = await Future.wait(
      images!.map(
        (_image) => uploadFile(
          image: File(_image.path), //passing single file/image-file path
          reference: ref,
        ),
      ),
    );
    provider!.getFormData(
      imageUrls: imageUrls,
    );

    return imageUrls;
  }

  Future uploadFile({File? image, String? reference}) async {
    firebase_storage.Reference storageReference = storage
        .ref()
        .child('$reference/${DateTime.now().microsecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask = storageReference.putFile(image!);
    await uploadTask;
    return storageReference.getDownloadURL();
  }

  Future<void> addVendor({Map<String, dynamic>? data}) {
    return vendor.doc(user!.uid).set(data);
  }

  Future<void> saveToDb({BuildContext? context, Map<String, dynamic>? data}) {
    return product
        .add(data)
        .then((value) => scaffold(context, "Product Saved"));
  }

  String formattedDate(date) {
    var outputFormat = DateFormat('dd/MM/yyyy hh:mm:ss');
    var outputDate = outputFormat.format(date);
    return outputDate;
  }

  String formattedPrice(number) {
    var outputPriceFormat = NumberFormat('##,##,###');
    String formattedPrice = outputPriceFormat.format(number);
    return formattedPrice;
  }

  Widget formfield(
      {String? label,
      TextInputType? inputType,
      void Function(String)? onChanged,
      int? minLines,
      int? maxLines}) {
    return TextFormField(
      decoration: InputDecoration(
        label: Text(label!),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return label;
        }
        return null;
      },
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
    );
  }

  scaffold(context, message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      ),
    );
  }
}
