import 'package:flutter/material.dart';
import 'package:flutterteamproject/CustomWidget/CustomButton.dart';
import 'package:flutterteamproject/CustomWidget/CustomButtonColor.dart';
import 'package:flutterteamproject/CustomWidget/prevPageButton.dart';
import 'package:flutterteamproject/LogIn/LogInMain.dart';
import 'package:flutterteamproject/SignUp/AuthPhone.dart';
import 'package:flutterteamproject/SignUp/Create_Account.dart';
import 'package:flutterteamproject/SignUp/Profile_BasicInfo.dart';

void main() {
  runApp(const Noti());
}

class Noti extends StatelessWidget {
  const Noti({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyWidget()
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( appBar: AppBar(
      leading: IconButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogInMain()),
          );
        },
        icon: Icon(Icons.close),
      ),
    ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70,),
                Text('처음처럼에 오신 것을 환영합니다.',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text('아래 네 가지 규칙을 명심해 주세요.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 50,),
                Text('내 모습 그대로 당당하기',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text('사진, 나이, 자기소개를 사실대로 올려주세요',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                SizedBox(height: 20,),
                Text('안전을 최우선으로',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text('잘 모르는 상대방에게 개인 정보를 알려주지 마세요!',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                SizedBox(height: 20,),
                Text('매너 있는 대화',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text('존중 받고 싶은 만큼 상대방을 배려해주세요.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                SizedBox(height: 20,),
                Text('신고는 적극적으로',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text('상대가 잘못된 언행을 보이면 신고해주세요.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                SizedBox(height: 80,),
              ],
            ),
            Column(
              children: [
                CustomColorButton(
                  buttonText: '동의합니다.',
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAccount(),
                      ),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
