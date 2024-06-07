import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterteamproject/Home/Home.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:flutter/foundation.dart' show debugPrint;

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Initializing Kakao SDK');

  //카카오 로그인
  KakaoSdk.init(
    nativeAppKey: '6b0db2d52b00781dbfdcc6c14ce1d42d',
  );

  debugPrint('Kakao SDK initialized');
  runApp(const kakaoLogin());
}

class kakaoLogin extends StatelessWidget {
  const kakaoLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyWidget()
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          child: Image.asset('assets/kakao_login_medium_narrow.png'),
          onPressed: () => signInWithKakao(context),
        ),
      ),
    );
  }

}
