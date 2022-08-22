import 'dart:core';
import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/model/product_model.dart';
import 'package:shop_app_vendor/provider/product_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;
  final Product? product;
  const ProductDetailsScreen({Key? key, this.productId, this.product})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  bool _editable = true;
  final _productNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _salesPriceController = TextEditingController();
  final _regularPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockOnHandController = TextEditingController();
  final _reOrderLevelController = TextEditingController();
  final _shippingChargeController = TextEditingController();
  final _sizeListTextController = TextEditingController();

  bool? manageInventory;
  bool? isShippingChargeable;

  String? taxPercentage;
  String? taxStatus;
  DateTime? scheduledDate;
  List _sizeList = [];
  bool _addToSizeList = false;
  @override
  void initState() {
    setState(() {
      _productNameController.text = widget.product!.productName!;
      _brandNameController.text = widget.product!.brand!;
      _salesPriceController.text = widget.product!.salesPrice!.toString();
      _regularPriceController.text = widget.product!.regularPrice!.toString();

      taxStatus = widget.product!.taxStatus;
      taxPercentage =
          widget.product!.taxPercentage == 10.00 ? 'GST-10%' : 'GST-12%';
      _descriptionController.text = widget.product!.description!;
      _skuController.text = widget.product!.sku!;
      _stockOnHandController.text = widget.product!.stockOnHand!.toString();
      _reOrderLevelController.text = widget.product!.reOrderLevel!.toString();
      _shippingChargeController.text =
          widget.product!.shippingCharge.toString();
      if (widget.product!.scheduledDate != null) {
        scheduledDate = DateTime.fromMicrosecondsSinceEpoch(
            widget.product!.scheduledDate!.microsecondsSinceEpoch);
      }
      manageInventory = widget.product!.manageInventory;
      isShippingChargeable = widget.product!.isShippingChargeable;
      if (widget.product!.sizeList != null) {
        _sizeList = widget.product!.sizeList!;
      }
    });
    super.initState();
  }

  Widget _taxStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: taxStatus,
      hint: const Text("Tax Status"),
      icon: const Icon(Icons.arrow_drop_down_circle),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          taxStatus = newValue!;
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

  Widget _taxPercentageDropdown() {
    return DropdownButtonFormField<String>(
      value: taxPercentage,
      hint: const Text("Tax Amount"),
      icon: const Icon(Icons.arrow_drop_down_circle),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          taxPercentage = newValue!;
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

  Widget _textField(
      {TextEditingController? controller,
      String? label,
      TextInputType? textType,
      String? Function(String?)? validator}) {
    return TextFormField(
        minLines: null,
        maxLines: null,
        controller: controller,
        keyboardType: textType,
        validator: validator ??
            (value) {
              if (value!.isEmpty) {
                return 'Enter $label';
              }
            });
  }

  updateProduct() {
    EasyLoading.show();
    _services.product.doc(widget.productId).update({
      'brand': _brandNameController.text,
      'productName': _productNameController.text,
      'description': _descriptionController.text,
      'size': _sizeList,
      'regularPrice': int.parse(_regularPriceController.text),
      'salesPrice': int.parse(_salesPriceController.text),
      'taxStatus': taxStatus,
      'taxPercentage': taxPercentage == 'GST-10%' ? 10.00 : 12.00,
      'scheduledDate': scheduledDate,
      'manageInventory': manageInventory,
      'stockOnHand': int.parse(_stockOnHandController.text),
      'reOrderLevel': int.parse(_reOrderLevelController.text),
      'isShippingChargeable': isShippingChargeable,
      'shippingCharge': int.parse(_shippingChargeController.text),
    }).then((value) {
      setState(() {
        _editable = true;
        _addToSizeList = false;
      });
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Text(widget.product!.productName!),
          actions: [
            _editable
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _editable = false;
                      });
                    },
                    icon: const Icon(Icons.edit_outlined))
                : TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        updateProduct();
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: widget.product!.imageUrls!.map((e) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CachedNetworkImage(imageUrl: e),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              AbsorbPointer(
                //to control whether the fields are editable do not
                absorbing: _editable,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Row(
                        children: [
                          Text(
                            "Brand:",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: _textField(
                              label: 'Brand',
                              textType: TextInputType.text,
                              controller: _brandNameController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: _textField(
                        label: 'Product Name ',
                        textType: TextInputType.text,
                        controller: _productNameController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: _textField(
                        label: 'Description',
                        textType: TextInputType.multiline,
                        controller: _descriptionController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text(
                            'Unit',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(widget.product!.unit!),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Sizes/Units: ${_sizeList.isEmpty ? 0 : ""}'),
                                    if (_editable == false)
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _addToSizeList = true;
                                            });
                                          },
                                          child: const Text('Add List')),
                                  ],
                                ),
                              ),
                              if (_addToSizeList == true)
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Form(
                                    key: _formKey1,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: TextFormField(
                                          controller: _sizeListTextController,
                                          decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Enter A Value';
                                            }
                                          },
                                        )),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              if (_formKey1.currentState!
                                                  .validate()) {
                                                _sizeList.add(
                                                    _sizeListTextController
                                                        .text);

                                                setState(() {
                                                  _sizeListTextController
                                                      .clear();
                                                });
                                              }
                                            },
                                            child: const Text("Add"))
                                      ],
                                    ),
                                  ),
                                ),
                              if (_sizeList.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    height: 30,
                                    child: ListView.builder(
                                        itemCount: _sizeList.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onLongPress: () {
                                              setState(
                                                () {
                                                  _sizeList.removeAt(index);
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color:
                                                        Colors.indigo.shade200,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Center(
                                                        child: Text(
                                                            _sizeList[index])),
                                                  )),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  if (widget.product!.salesPrice != null)
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Sales price:",
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Expanded(
                                            child: _textField(
                                              label: 'Sales price',
                                              textType: TextInputType.number,
                                              controller: _salesPriceController,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter Sales price';
                                                }
                                                if (int.parse(
                                                        _regularPriceController
                                                            .text) <=
                                                    int.parse(value)) {
                                                  return 'Regular price should be\nmore than sales price';
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Regular price:",
                                          style: TextStyle(
                                              color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Expanded(
                                          child: _textField(
                                            label: 'Regular price',
                                            textType: TextInputType.number,
                                            controller: _regularPriceController,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Enter Regular price';
                                              }
                                              if (int.parse(value) <=
                                                  int.parse(
                                                      _salesPriceController
                                                          .text)) {
                                                return 'Regular price should be\nmore than sales price';
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (scheduledDate != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('Sale Schedule Date:'),
                                        Text(_services
                                            .formattedDate(scheduledDate)),
                                      ],
                                    ),
                                    if (_editable == false)
                                      ElevatedButton(
                                          onPressed: () {
                                            showDatePicker(
                                                    context: context,
                                                    initialDate: scheduledDate!,
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(5000))
                                                .then((value) {
                                              setState(() {
                                                scheduledDate = value;
                                              });
                                            });
                                          },
                                          child: const Text('Change date')),
                                  ],
                                ),
                              if (scheduledDate == null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('*Sale Not Scheduled'),
                                      ],
                                    ),
                                    if (_editable == false)
                                      ElevatedButton(
                                          onPressed: () {
                                            showDatePicker(
                                                    context: context,
                                                    initialDate: scheduledDate!,
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(5000))
                                                .then((value) {
                                              setState(() {
                                                scheduledDate = value;
                                              });
                                            });
                                          },
                                          child: Text('Add Sale date')),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: _taxStatusDropdown(),
                          ),
                        ),
                        if (taxStatus == 'Taxable')
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              child: _taxPercentageDropdown(),
                            ),
                          ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Text(
                          'Category:MainCat:SubCat:SKU(Product code) as Label or apply dropdown logib same as tax'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Row(
                        children: [
                          Text(
                            "SKU(product code):",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          Text(widget.product!.sku!),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Column(
                            children: [
                              CheckboxListTile(
                                  title: const Text("Manage inventory?"),
                                  contentPadding: EdgeInsets.zero,
                                  value: manageInventory,
                                  onChanged: (value) {
                                    setState(() {
                                      manageInventory = value;
                                      if (value == false) {
                                        _stockOnHandController.clear();
                                        _reOrderLevelController.clear();
                                      }
                                    });
                                  }),
                              if (manageInventory == true)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Stock on hand:",
                                              style: TextStyle(
                                                  color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            Expanded(
                                              child: _textField(
                                                label: 'enter Stock on hand:',
                                                textType: TextInputType.number,
                                                controller:
                                                    _stockOnHandController,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Reorder level",
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Expanded(
                                            child: _textField(
                                              label: 'Reorder level',
                                              textType: TextInputType.number,
                                              controller:
                                                  _reOrderLevelController,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Column(
                            children: [
                              CheckboxListTile(
                                  title: const Text("Add shipping charges?"),
                                  contentPadding: EdgeInsets.zero,
                                  value: isShippingChargeable,
                                  onChanged: (value) {
                                    setState(() {
                                      isShippingChargeable = value;
                                      if (value == false) {
                                        _shippingChargeController.clear();
                                      }
                                    });
                                  }),
                              if (isShippingChargeable == true)
                                Row(
                                  children: [
                                    Text(
                                      "Shipping charge:",
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Expanded(
                                      child: _textField(
                                        label: 'Enter shipping charge',
                                        textType: TextInputType.number,
                                        controller: _shippingChargeController,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
