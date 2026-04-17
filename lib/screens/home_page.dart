import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toko Online')),
      body: const Center(
        child: Text(
          'Selamat datang di toko online Flutter',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}