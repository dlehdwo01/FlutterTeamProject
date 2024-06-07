import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Image.network(
            'https://firebasestorage.googleapis.com/v0/b/teamproject-972bd.appspot.com/o/logo.png?alt=media&token=53755bc1-3bcf-42cf-b472-1577e3f0b7ab'),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
