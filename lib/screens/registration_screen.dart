import 'dart:io';

import 'package:csc_picker/csc_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/screens/landing_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _shopImage;
  XFile? _logo;
  final _businessNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstController = TextEditingController();
  final _pinController = TextEditingController();
  final _landmarkController = TextEditingController();

  String? countryValue;
  String? stateValue;
  String? cityValue;

  String? _businessName;
  String? _taxStatus;
  String? _shopImageUrl;
  String? _logoUrl;

  Widget _formField(
      {TextEditingController? controller,
      String? label,
      TextInputType? textType,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: textType,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: validator,
      onChanged: (value) {
        if (controller == _businessNameController) {
          setState(() {
            _businessName = value;
          });
        }
      },
    );
  }

  _pickImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  _saveToDb() {
    if (_shopImage == null) {
      _services.scaffold(context, 'Please add a shop image');
      return;
    }
    if (_logo == null) {
      _services.scaffold(context, 'Please add a logo image');
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (countryValue == null || stateValue == null || cityValue == null) {
        _services.scaffold(context, 'Please select all address fields');
        return;
      }
      EasyLoading.show(status: 'Please wait.');
      _services
          .uploadImage(
              _shopImage, 'vendors/${_services.user!.uid}/shopImage.jpg')
          .then((String? url) {
        if (url != null) {
          setState(() {
            _shopImageUrl = url;
          });
        }
      }).then((value) {
        _services
            .uploadImage(_logo, 'vendors/${_services.user!.uid}/logo.jpg')
            .then((url) {
          setState(() {
            _logoUrl = url;
          });
        }).then((value) {
          _services.addVendor(data: {
            'shopImage': _shopImageUrl,
            'logo': _logoUrl,
            'businessName': _businessNameController.text,
            'contactNumber': _contactController.text,
            'email': _emailController.text,
            'taxRegistered': _taxStatus,
            'gstNumber':
                _gstController.text.isEmpty ? null : _gstController.text,
            'pinCode': _pinController.text,
            'landmark': _landmarkController.text,
            'country': countryValue,
            'state': stateValue,
            'city': cityValue,
            'approved': false,
            'uid': _services.user!.uid,
            'time': DateTime.now(),
          }).then((value) {
            EasyLoading.dismiss();
            return Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const LandingScreen(),
              ),
            );
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    _shopImage == null
                        ? Container(
                            color: Colors.blue,
                            height: 250,
                            child: TextButton(
                              child: Center(
                                child: Text(
                                  'Tap to add shop image',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 20),
                                ),
                              ),
                              onPressed: () {
                                _pickImage().then((value) {
                                  setState(() {
                                    _shopImage = value;
                                  });
                                });
                              },
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              _pickImage().then((value) {
                                setState(() {
                                  _shopImage = value;
                                });
                              });
                            },
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                image: DecorationImage(
                                  opacity: 50,
                                  image: FileImage(
                                    File(_shopImage!.path),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 80,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        actions: [
                          IconButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                              },
                              icon: const Icon(Icons.logout))
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                _pickImage().then((value) {
                                  setState(() {
                                    _logo = value;
                                  });
                                });
                              },
                              child: Card(
                                elevation: 4,
                                child: _logo == null
                                    ? const SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: Center(child: Text('+')),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Image.file(File(_logo!.path)),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              _businessName == null ? '' : _businessName!,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Column(
                  children: [
                    _formField(
                        controller: _businessNameController,
                        label: 'Business Name',
                        textType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Business Name';
                          }
                          return null;
                        }),
                    _formField(
                        controller: _contactController,
                        label: 'Contact Number',
                        textType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Contact Number';
                          }
                          return null;
                        }),
                    _formField(
                        controller: _emailController,
                        label: 'Email',
                        textType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Email Address';
                          }
                          bool _isValid = EmailValidator.validate(value);
                          if (_isValid == false) {
                            return 'Invalid email';
                          }
                          return null;
                        }),
                    Row(
                      children: [
                        const Text('Tax Registered:'),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 10, 0, 10),
                            child: DropdownButtonFormField(
                                value: _taxStatus,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Select Tax Status';
                                  }
                                  return null;
                                },
                                hint: const Text('Select'),
                                items: <String>['Yes', 'No']
                                    .map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _taxStatus = value;
                                  });
                                }),
                          ),
                        )
                      ],
                    ),
                    if (_taxStatus == 'Yes')
                      _formField(
                          controller: _gstController,
                          label: 'GST Number',
                          textType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter GST Number';
                            }
                            return null;
                          }),
                    _formField(
                        controller: _pinController,
                        label: 'Postal PIN Code',
                        textType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter PIN Code';
                          }
                          return null;
                        }),
                    _formField(
                        controller: _landmarkController,
                        label: 'Landmark',
                        textType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Landmark';
                          }
                          return null;
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    CSCPicker(
                      ///Enable disable state dropdown [OPTIONAL PARAMETER]
                      showStates: true,

                      /// Enable disable city drop down [OPTIONAL PARAMETER]
                      showCities: true,

                      ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
                      flagState: CountryFlag.DISABLE,

                      ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
                      dropdownDecoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),

                      ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
                      disabledDropdownDecoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.shade300,
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),

                      ///placeholders for dropdown search field
                      countrySearchPlaceholder: "Country",
                      stateSearchPlaceholder: "State",
                      citySearchPlaceholder: "City",

                      ///labels for dropdown
                      countryDropdownLabel: "*Country",
                      stateDropdownLabel: "*State",
                      cityDropdownLabel: "*City",

                      ///Default Country
                      defaultCountry: DefaultCountry.India,

                      ///Disable country dropdown (Note: use it with default country)
                      //disableCountry: true,

                      ///selected item style [OPTIONAL PARAMETER]
                      selectedItemStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),

                      ///DropdownDialog Heading style [OPTIONAL PARAMETER]
                      dropdownHeadingStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),

                      ///DropdownDialog Item style [OPTIONAL PARAMETER]
                      dropdownItemStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),

                      ///Dialog box radius [OPTIONAL PARAMETER]
                      dropdownDialogRadius: 10.0,

                      ///Search bar radius [OPTIONAL PARAMETER]
                      searchBarRadius: 10.0,

                      ///triggers once country selected in dropdown
                      onCountryChanged: (value) {
                        setState(() {
                          ///store value in country variable
                          countryValue = value;
                        });
                      },

                      ///triggers once state selected in dropdown
                      onStateChanged: (value) {
                        setState(() {
                          ///store value in state variable
                          stateValue = value;
                        });
                      },

                      ///triggers once city selected in dropdown
                      onCityChanged: (value) {
                        setState(() {
                          ///store value in city variable
                          cityValue = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        persistentFooterButtons: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: _saveToDb,
                    child: const Text('Register'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
