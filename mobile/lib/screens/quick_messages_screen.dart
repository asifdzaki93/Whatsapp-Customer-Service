import 'package:flutter/material.dart';

class QuickMessagesScreen extends StatelessWidget {
  const QuickMessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan Cepat'),
      ),
      body: Center(
        child: const Text('Ini adalah halaman Pesan Cepat.'),
      ),
    );
  }
}
