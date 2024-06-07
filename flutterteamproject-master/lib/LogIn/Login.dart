import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterteamproject/CustomWidget/CustomButtonColor.dart';
import 'package:flutterteamproject/CustomWidget/prevPageButton.dart';
import 'package:flutterteamproject/Home/Home.dart' as home;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MyWidget());
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView(
          children: [
            Column(
              children: [
                SizedBox(height: 150,),
                CustomTextField(
                    _emailCtrl,
                    '아이디(이메일)',
                    '아이디를 입력해주세요'
                ),
                CustomPwdField(
                    _pwdCtrl,
                    '비밀번호',
                    '비밀번호를 입력해주세요',
                ),
                SizedBox(height: 200,),
                CustomColorButton(
                  buttonText: '로그인',
                  onPressed: () => _login(_emailCtrl.text, _pwdCtrl.text),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _login(String email, String password) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('USER')
          .where('EMAIL', isEqualTo: email)
          .where('PWD', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 문서 가져오기
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;

        // SharedPreferences에 저장
        await _saveUserDataToPrefs(userData);

        // 로그인 성공 시 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => home.MyDatingApp(loggedInEmail: 'asdfrg')),
        );
      } else {
        // 로그인 실패
        _showSnackbar('아이디 및 비밀번호가 일치하지 않습니다.');
      }
    } catch (e) {
      print('Error during login: $e');
      _showSnackbar('로그인 중 오류가 발생했습니다.');
    }
  }

  Future<void> _saveUserDataToPrefs(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', userData['EMAIL']);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

Widget CustomTextField(TextEditingController controller, String label, String hintText) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label를 입력해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          labelStyle: TextStyle(color: Colors.black),
          suffixIcon: controller.text.isNotEmpty
              ? controller.text.length >= 6
              ? Icon(Icons.check, color: Colors.green)
              : Icon(Icons.close, color: Colors.red)
              : null,
        ),
      ),
      SizedBox(height: 30),
    ],
  );
}

Widget CustomPwdField(TextEditingController controller, String label, String hintText) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label를 입력해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hintText,
          labelStyle: TextStyle(color: Colors.black),
          suffixIcon: controller.text.isNotEmpty
              ? controller.text.length >= 6
              ? Icon(Icons.check, color: Colors.green)
              : Icon(Icons.close, color: Colors.red)
              : null,
        ),
      ),
      SizedBox(height: 30),
    ],
  );
}