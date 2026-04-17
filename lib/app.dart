import 'package:flutter/material.dart';
import 'package:projek_fluter/screens/profil_page.dart';



class MyStoreApp extends StatelessWidget {
  const MyStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toko Online',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ProfilPage(),
    );
  }
}