import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterteamproject/SignUp/Profile_BasicInfo.dart';
import 'package:flutterteamproject/CustomWidget/CustomButton.dart';
import 'package:flutterteamproject/CustomWidget/CustomTheme.dart';
import 'package:flutterteamproject/CustomWidget/prevPageButton.dart';
import 'package:flutterteamproject/LogIn/LogInMain.dart';
import 'package:flutterteamproject/Models/Profile_Model.dart';
import 'package:flutterteamproject/SignUp/Notification.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AuthPhoneNumber extends StatelessWidget {
  String type;
  AuthPhoneNumber({required this.type});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: CustomTheme(child: MyWidget(type: type),)
    );
  }
}

class MyWidget extends StatefulWidget {
  String type;
  MyWidget({required this.type});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _PhoneNumCtrl = TextEditingController();
  final TextEditingController _smsCodeCtrl = TextEditingController();
  bool _isButtonEnabled = false; // 버튼 활성화 여부
  // bool _isConfirmButtonEnabled = false;
  String _sentCode = "";

  @override
  void initState() {
    super.initState();
    _PhoneNumCtrl.addListener(_updateButtonState);
    _smsCodeCtrl;
  }

  //핸드폰 번호 인증 버튼 활성화 여부
  void _updateButtonState() {
    if (_PhoneNumCtrl.text.length == 11 && !_isButtonEnabled) {
      setState(() {
        _isButtonEnabled = true;
      });
    } else if (_PhoneNumCtrl.text.length != 11 && _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = false;
      });
    }
  }

  //문자인증 테스트
  void sendSMS() async {
    // 예시로, 직접 '000111'로 설정
    _sentCode = '000111';
    print('Fake SMS sent with code: $_sentCode');
  }

  // //문자 인증
  // final String serverUrl = 'http://10.0.2.2:4000/send-sms'; // 나중에 서버로 변경
  // void sendSMS() async {
  //   // 난수 6자리 생성
  //   final random = Random();
  //   final randomNumber = random.nextInt(900000) + 100000; // 100000 ~ 999999
  //   _sentCode = randomNumber.toString();
  //
  //   _sentCode = '000111';
  //
  //   Map<String, String> data = {
  //     'to': _PhoneNumCtrl.text, // 사용자가 입력하는 번호
  //     'from': '01046548947', // 고정
  //     'text': '인증번호: $_sentCode'
  //   };
  //   try {
  //     final response = await http.post(
  //       Uri.parse(serverUrl),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(data),
  //     );
  //
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //   } catch (e) {
  //     print('Error sending request: $e');
  //   }
  // }

  @override
  void dispose() {
    _PhoneNumCtrl.dispose();
    _smsCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 100,),
                prevButton(
                  onPressed: (){
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogInMain()),
                    );
                  },
                ),
                SizedBox(height: 100,),
                Text('전화번호를 입력해주세요',
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: _PhoneNumCtrl,
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '자신의 전화번호를 입력해주세요',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 100,),
                CustomButton(
                  buttonText: '인증하기',
                  onPressed: _isButtonEnabled ? () => _handleNextButton() : null,
                  ButtonColor: _isButtonEnabled ? Colors.white : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _handleNextButton() {
    sendSMS();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('인증번호 입력'),
          content: TextField(
            controller: _smsCodeCtrl,
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: '인증번호를 입력하세요'),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () => _checkCode(context), // 항상 활성화
            ),
          ],
        );
      },
    );
  }

  void _checkCode(BuildContext context) {
    if (_smsCodeCtrl.text == _sentCode) {
      Provider.of<ProfileModel>(context, listen: false).updatePhoneNumber(_PhoneNumCtrl.text);
      if(widget.type == 'Default'){
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => Noti())
        );
      } else {
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => SignUpProfile())
        );
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('잘못된 인증번호입니다. 다시 입력해주세요.'))
      );
      Navigator.of(context).pop(); // 다이얼로그 닫기
    }
  }

}
