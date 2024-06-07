import 'package:flutter/material.dart';
import 'EditProfile.dart';
import 'EditProfileProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutterteamproject/Profile.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
        title: 'Profile',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Test(),
      );



  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: (){
          print('click');
          Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(),));
        },
        child: Center(
            child : Text('haha')),
      ),
    );
  }
}
