import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_vendor/provider/product_provider.dart';

class ImagesScreen extends StatefulWidget {
  const ImagesScreen({Key? key}) : super(key: key);

  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ImagePicker _picker = ImagePicker();

  _pickImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    return images;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ProductProvider>(builder: (context, provider, __) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextButton(
              onPressed: () {
                _pickImage().then((value) {
                  value!.forEach((image) {
                    setState(() {
                      provider.getImageFile(image);
                    });
                  });
                });
              },
              child: const Text('Add product images'),
            ),
            Center(
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: provider.imageFiles!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        onLongPress: () {
                          setState(() {
                            provider.imageFiles!.removeAt(index);
                          });
                        },
                        child: provider.imageFiles == null
                            ? const Center(child: Text("No image selected"))
                            : Image.file(
                                File(provider.imageFiles![index].path),
                              ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    });
  }
}
