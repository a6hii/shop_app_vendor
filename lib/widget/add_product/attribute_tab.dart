import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_vendor/provider/product_provider.dart';

class AttributeTab extends StatefulWidget {
  const AttributeTab({Key? key}) : super(key: key);

  @override
  State<AttributeTab> createState() => _AttributeTabState();
}

class _AttributeTabState extends State<AttributeTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<String> _sizeList = [];
  final _sizeTextController = TextEditingController();
  String? selectedUnit;
  final List<String> _units = [
    'Unit',
    "Kg",
    'L',
    'mL',
    'G',
    'CM',
    'M',
    'Feet',
    'In',
    'Set'
  ];
  bool? _saved = false;
  bool _isButtonActive =
      false; //entered in tutorial //url-  https://youtu.be/8IZ_vVY32Ck?list=PLLMOQJG4zQsXKDdzxnjlorRW9-vOZR18V

  Widget _formfield(
      {String? label,
      TextInputType? inputType,
      void Function(String)? onChanged,
      int? minLines,
      int? maxLines}) {
    return TextFormField(
      decoration: InputDecoration(
        label: Text(label!),
      ),
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
    );
  }

  Widget _unitDropdown(ProductProvider provider) {
    return DropdownButtonFormField<String>(
      value: selectedUnit,
      hint: const Text("Select unit"),
      icon: const Icon(Icons.arrow_drop_down_circle),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          selectedUnit = newValue!;
          provider.getFormData(
            unit: newValue,
          );
        });
      },
      items: _units.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Select a unit';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ProductProvider>(builder: ((context, provider, _) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _formfield(
              label: 'Brand',
              inputType: TextInputType.text,
              onChanged: (value) {
                provider.getFormData(
                  brand: value,
                );
              },
            ),
            _formfield(
              label: 'Brand description...',
              minLines: 2,
              maxLines: 4,
              inputType: TextInputType.text,
              onChanged: (value) {
                provider.getFormData(
                  brandDescription: value,
                );
              },
            ),
            _unitDropdown(provider),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeTextController,
                    decoration: const InputDecoration(
                      label: Text('Size'),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _isButtonActive =
                              true; //controlling Add button visibility. Should be visible all the time and change state based on input text
                        });
                      }
                    },
                  ),
                ),
                if (_isButtonActive)
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _sizeList.add(_sizeTextController.text);
                          _sizeTextController.clear();
                          _isButtonActive = false;
                          _saved = false;
                        });
                      },
                      child: const Text("Add"))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            if (_sizeList.isNotEmpty)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _sizeList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onLongPress: () {
                          setState(() {
                            _sizeList.removeAt(index);
                            provider.getFormData(
                              sizeList: _sizeList,
                            );
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.indigo.shade100,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(_sizeList[index])),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_sizeList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    child: Text(
                      '*long-press to delete',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                  if (_saved == false)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          provider.getFormData(
                            sizeList: _sizeList,
                          );
                          _saved = true;
                        });
                      },
                      child: const Text("Press to Save"),
                    )
                ],
              ),
          ],
        ),
      );
    }));
  }
}
