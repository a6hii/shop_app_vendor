import 'package:cloud_firestore/cloud_firestore.dart';

class Vendor {
  Vendor({
    this.approved,
    this.businessName,
    this.city,
    this.contactNumber,
    this.country,
    this.email,
    this.gstNumber,
    this.landmark,
    this.logo,
    this.pinCode,
    this.shopImage,
    this.state,
    this.taxRegistered,
    this.time,
    this.uid,
  });

  Vendor.fromJson(Map<String, Object?> json)
      : this(
          approved: json['approved']! as bool,
          businessName: json['businessName']! as String,
          city: json['city']! as String,
          contactNumber: json['contactNumber']! as String,
          country: json['country']! as String,
          email: json['email']! as String,
          gstNumber: json['gstNumber']! as String,
          landmark: json['landmark']! as String,
          logo: json['logo']! as String,
          pinCode: json['pinCode']! as String,
          shopImage: json['shopImage']! as String,
          state: json['state']! as String,
          taxRegistered: json['taxRegistered']! as String,
          time: json['time']! as Timestamp,
          uid: json['uid']! as String,
        );
  final bool? approved;
  final String? businessName;
  final String? city;
  final String? contactNumber;
  final String? country;
  final String? email;
  final String? gstNumber;

  final String? landmark;
  final String? logo;

  final String? pinCode;
  final String? shopImage;
  final String? state;
  final String? taxRegistered;
  final Timestamp? time;
  final String? uid;

  Map<String, Object?> toJson() {
    return {
      'approved': approved,
      'businessName': businessName,
      'city': city,
      'contactNumber': contactNumber,
      'country': country,
      'email': email,
      'gstNumber': gstNumber,
      'landmark': landmark,
      'logo': logo,
      'pinCode': pinCode,
      'shopImage': shopImage,
      'state': state,
      'taxRegistered': taxRegistered,
      'time': time,
      'uid': uid,
    };
  }
}
