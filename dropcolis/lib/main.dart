import 'package:flutter/material.dart';
import 'package:dropcolis/webview.dart';

void main() {
  runApp(const DropColis());
}

class DropColis extends StatelessWidget {
  const DropColis({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebviewScreen(),
    );
  }
}
