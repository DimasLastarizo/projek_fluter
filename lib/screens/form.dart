import 'package:flutter/material.dart';

class InputFormV3Sederhana extends StatefulWidget {
  const InputFormV3Sederhana({super.key});

  @override
  State<InputFormV3Sederhana> createState() => _InputFormV3SederhanaState();
}

class _InputFormV3SederhanaState extends State<InputFormV3Sederhana> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();

  String _hasilNama = '';
  String _hasilNim = '';

  void _tampilkanData() {
    setState(() {
      _hasilNama = _namaController.text;
      _hasilNim = _nimController.text;
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Form Dasar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nimController,
              decoration: const InputDecoration(
                labelText: 'NIM',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _tampilkanData,
              child: const Text('Tampilkan Data'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hasil Input:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Nama: $_hasilNama'),
            Text('NIM: $_hasilNim'),
          ],
        ),
      ),
    );
  }
}