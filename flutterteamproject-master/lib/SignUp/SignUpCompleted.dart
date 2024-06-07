
import 'package:flutter/material.dart';
import 'package:flutterteamproject/CustomWidget/CustomButtonColor.dart';
import 'package:flutterteamproject/Home/Home.dart';
import 'package:flutterteamproject/SignUp/Profile_Interests.dart';

class SignUpWaiting extends StatefulWidget {
  final String email; // 이메일 추가
  const SignUpWaiting({super.key, required this.email});

  @override
  State<SignUpWaiting> createState() => _SignUpWaitingState();
}

class _SignUpWaitingState extends State<SignUpWaiting> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: 200,),
            Text('처음처럼 회원가입을 축하드립니다.', style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('좋은 인연을 만들어보세요', style: TextStyle(
                    fontSize: 18, color: Colors.grey
                ),),
                SizedBox(width: 5,),
                Icon(Icons.favorite, color: Colors.red,)
              ],
            ),
            SizedBox(height: 20,),
            Text('상세 정보를 입력하시면 매칭될 확률이 높아요', style: TextStyle(
              fontSize: 15
            ),),
            SizedBox(height: 100,),
            CustomColorButton(
                buttonText: '건너뛰기',
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyDatingApp(loggedInEmail: '${widget.email}',)),
                  );
                },
            ),
            SizedBox(height: 20,),
            CustomColorButton(
                buttonText: '상세 정보 입력',
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InterestsInfo(email: widget.email)),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
