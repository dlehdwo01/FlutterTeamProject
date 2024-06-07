import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterteamproject/CustomWidget/CustomButton.dart';
import 'package:flutterteamproject/CustomWidget/CustomButtonImage.dart';
import 'package:flutterteamproject/CustomWidget/CustomTheme.dart';
import 'package:flutterteamproject/LogIn/Login.dart';
import 'package:flutterteamproject/Models/Profile_Model.dart';
import 'package:flutterteamproject/SignUp/AuthPhone.dart';
import 'package:flutterteamproject/SignUp/Profile_BasicInfo.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Home/Home.dart';

void main() {
  runApp(const LogInMain());
}

class LogInMain extends StatelessWidget {
  const LogInMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: CustomTheme(child: MyWidget(),)
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  //카카오 로그인
  void signInWithKakao(BuildContext context) async {

    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  // 구글 로그인 및 파이어베이스 데이터베이스에 사용자 이메일 저장
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google 로그인이 취소되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth!.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      String userEmail = user!.email ?? '';

      if (user != null) {
        //Provider.of<ProfileModel>(context, listen: false).setGoogleAccountStatus(true);
        final profile = Provider.of<ProfileModel>(context, listen: false);
        profile.updateEmail(userEmail);

        FirebaseFirestore fs = FirebaseFirestore.instance;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('USER')
            .where('EMAIL', isEqualTo: userEmail)
            .get();

        print('아이디 확인 : $userEmail');
        if (querySnapshot.docs.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', userEmail);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyDatingApp(loggedInEmail : userEmail)),
          );
          return;
        }

        Navigator.push(
          context,
          //MaterialPageRoute(builder: (context) => SignUpProfile(email: user.email!)),
          MaterialPageRoute(builder: (context) => AuthPhoneNumber(type: 'Google',)),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google 로그인 성공!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      print('에러 유형: ${error.runtimeType}, 에러 메시지: $error');
      if (error is FirebaseAuthException) {
        print('Firebase Auth 에러 코드: ${error.code}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google 로그인에 실패했습니다: $error'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            SizedBox(height:500,),
            CustomImageButton(
              imagePath: 'assets/kakao_login_medium_wide.png',
              width: 300,
              height: 50,
              ButtonColor: Colors.yellow,
              onPressed: () => signInWithKakao(context),
            ),
            SizedBox(height:15,),
            CustomImageButton(
              imagePath: 'assets/googleLogin.png',
              width: 300,
              height: 50,
              ButtonColor: Colors.white,
              onPressed: () => signInWithGoogle(context),
            ),
            SizedBox(height:15,),
            CustomButton(
              buttonText: '이메일로 계속하기',
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
            SizedBox(height:50,),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPhoneNumber(type: 'Default',)),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: '회원가입',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white, // 밑줄 색상 설정
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


}

