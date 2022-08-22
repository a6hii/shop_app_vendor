import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/provider/product_provider.dart';

class ShippingTab extends StatefulWidget {
  const ShippingTab({Key? key}) : super(key: key);

  @override
  State<ShippingTab> createState() => _ShippingTabState();
}

class _ShippingTabState extends State<ShippingTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final FirebaseServices _services = FirebaseServices();
  bool? _isShippingChargeable = false; //_chargeShipping
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ProductProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Charge Shipping?',
                  style: TextStyle(
                      color: Colors.grey
                          .shade500), //implement color change when checkbox is selected/is true
                ),
                value: _isShippingChargeable,
                onChanged: (value) {
                  setState(() {
                    _isShippingChargeable = value;
                    provider.getFormData(
                      isShippingChargeable: value,
                    );
                  });
                }),
            if (_isShippingChargeable == true)
              Column(
                children: [
                  _services.formfield(
                      label: 'Shipping charge',
                      inputType: TextInputType.number,
                      onChanged: (value) {
                        provider.getFormData(
                          shippingCharge: int.parse(value),
                        );
                      }),
                ],
              ),
          ],
        ),
      );
    });
  }
}
