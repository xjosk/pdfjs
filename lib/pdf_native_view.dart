import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PDFNativeView extends StatelessWidget {
  const PDFNativeView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{"path": path};

    return Scaffold(
      appBar: AppBar(),
      body: UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
