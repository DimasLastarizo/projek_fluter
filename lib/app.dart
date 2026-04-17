import 'package:flutter/material.dart';
import 'package:projek_fluter/screens/form.dart';
import 'package:projek_fluter/screens/login.dart';
import 'package:projek_fluter/screens/profil_page.dart';


class MyStoreApp extends StatelessWidget {
  const MyStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'belajar dadi mahir hehe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const InputFormV3Sederhana(),
    );
  }
}