import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/provider/product_provider.dart';

class GeneralTab extends StatefulWidget {
  const GeneralTab({Key? key}) : super(key: key);

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final FirebaseServices _services = FirebaseServices();

  final List<String> _categories = [];
  String? selectedCategory;
  String? taxStatus;
  String? taxPercentage;
  bool _salesPrice = false;

  Widget _categoryDropdown(ProductProvider provider) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      hint: const Text("Select category"),
      icon: const Icon(Icons.arrow_drop_down_circle),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          selectedCategory = newValue!;
          provider.getFormData(
            category: newValue,
          );
        });
      },
      items: _categories.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Select a category';
        }
        return null;
      },
    );
  }

  Widget _taxStatusDropdown(ProductProvider provider) {
    return DropdownButtonFormField<String>(
      value: taxStatus,
      hint: const Text("Tax Status"),
      icon: const Icon(Icons.arrow_drop_down_circle),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          taxStatus = newValue!;
          provider.getFormData(
            taxStatus: newValue,
          );
        });
      },
      items: ['Taxable', 'Non-Taxable']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Select tax status';
        }
        return null;
      },
    );
  }

  Widget _taxAmountDropdown(ProductProvider provider) {
    return DropdownButtonFormField<String>(
      value: taxPercentage,
      hint: const Text("Tax Amount"),
      icon: const Icon(Icons.arrow_drop_down_circle),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          taxPercentage = newValue!;
          provider.getFormData(
            taxPercentage: taxPercentage == 'GST-10%' ? 10 : 12,
          );
        });
      },
      items:
          ['GST-10%', 'GST-12%'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Select tax amount';
        }
        return null;
      },
    );
  }

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  getCategories() {
    _services.categories.get().then((value) {
      for (var element in value.docs) {
        setState(() {
          _categories.add(element['catName']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(children: [
            _services.formfield(
              label: 'Enter Product Name',
              inputType: TextInputType.name,
              onChanged: (value) {
                //save in provider
                provider.getFormData(
                  productName: value,
                );
              },
            ),
            _services.formfield(
              label: 'Enter product description',
              inputType: TextInputType.multiline,
              minLines: 2,
              maxLines: 10,
              onChanged: (value) {
                //save in provider
                provider.getFormData(
                  description: value,
                );
              },
            ),
            _categoryDropdown(provider),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    provider.productData!['mainCategory'] ??
                        'Select main category',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (selectedCategory != null)
                    InkWell(
                      child: const Icon(
                        Icons.arrow_drop_down_circle,
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (
                              context,
                            ) {
                              return MainCategoryList(
                                selectedCategory: selectedCategory,
                                provider: provider,
                              );
                            }).whenComplete(() {
                          setState(() {});
                        });
                      },
                    ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey.shade500,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.productData!['subCategory'] ??
                        'Select sub category',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (provider.productData!['mainCategory'] != null)
                    InkWell(
                      child: const Icon(
                        Icons.arrow_drop_down_circle,
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (
                              context,
                            ) {
                              return SubCategoryList(
                                selectedMainCategory:
                                    provider.productData!['mainCategory'],
                                provider: provider,
                              );
                            }).whenComplete(() {
                          setState(() {});
                        });
                      },
                    ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey.shade500,
              thickness: 1,
            ),
            _services.formfield(
              label: 'Enter Regular Price (\$)',
              inputType: TextInputType.number,
              onChanged: (value) {
                //save in provider
                provider.getFormData(
                  regularPrice: int.parse(value),
                );
              },
            ),
            _services.formfield(
              label: 'Enter Sales Price (\$)',
              inputType: TextInputType.number,
              onChanged: (value) {
                if (int.parse(value) >= provider.productData!['regularPrice']) {
                  _services.scaffold(context,
                      'Sales price should be less\nthan Regular price');
                  return;
                }

                setState(() {
                  provider.getFormData(
                    salesPrice: int.parse(value),
                  );
                  _salesPrice = true;
                });
              },
            ),
            if (_salesPrice)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(5000),
                      ).then((value) {
                        setState(() {
                          provider.getFormData(
                            scheduledDate: value,
                          );
                        });
                      });
                    },
                    child: const Text(
                      'Sale Schedule',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  if (provider.productData!['scheduledDate'] != null)
                    Text(_services
                        .formattedDate(provider.productData!['scheduledDate'])),
                ],
              ),
            _taxStatusDropdown(provider),
            if (taxStatus == 'Taxable') _taxAmountDropdown(provider),
          ]),
        );
      },
    );
  }
}

class MainCategoryList extends StatelessWidget {
  final String? selectedCategory;
  final ProductProvider? provider;
  const MainCategoryList({Key? key, this.selectedCategory, this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _service = FirebaseServices();
    return Dialog(
      child: FutureBuilder<QuerySnapshot>(
        future: _service.mainCategories
            .where('category', isEqualTo: selectedCategory)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.size == 0) {
            return const Center(
              child: Text('No main category found'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.size,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  provider!.getFormData(
                    mainCategory: snapshot.data!.docs[index]['mainCategory'],
                  );
                  Navigator.pop(context);
                },
                title: Text(snapshot.data!.docs[index]['mainCategory']),
              );
            },
          );
        },
      ),
    );
  }
}

class SubCategoryList extends StatelessWidget {
  final String? selectedMainCategory;
  final ProductProvider? provider;
  const SubCategoryList({Key? key, this.selectedMainCategory, this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _service = FirebaseServices();
    return Dialog(
      child: FutureBuilder<QuerySnapshot>(
        future: _service.subCategories
            .where('mainCategory', isEqualTo: selectedMainCategory)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.size == 0) {
            return const Center(
              child: Text('No sub category found'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.size,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  provider!.getFormData(
                    subCategory: snapshot.data!.docs[index]['subcatName'],
                  );
                  Navigator.pop(context);
                },
                title: Text(snapshot.data!.docs[index]['subcatName']),
              );
            },
          );
        },
      ),
    );
  }
}
