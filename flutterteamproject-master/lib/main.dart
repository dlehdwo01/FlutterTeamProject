import 'package:flutter/material.dart';
import 'package:flutterteamproject/Home/Home.dart' as home;
import 'package:flutterteamproject/LogIn/LogInMain.dart';
import 'package:flutterteamproject/Models/Profile_Model.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화

  KakaoSdk.init(
    nativeAppKey: '6b0db2d52b00781dbfdcc6c14ce1d42d',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ProfileModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  Future<String?> sessionCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'loginMain': (context) => LogInMain(), // LogInMain.dart 파일의 화면
      },
      title: 'Your App Title',
      home: FutureBuilder<String?>(
        future: sessionCheck(),
        builder: (context, snapshot) {
          // 데이터 로딩 중 표시할 위젯
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            // 이메일 값이 존재하면 MyDatingApp으로 이동

            return home.MyDatingApp(loggedInEmail: snapshot.data!);
          } else {
            // 이메일 값이 없으면 로그인 페이지로 이동
            return LogInMain();
          }
        },
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('테스트'),),
//     );
//   }
// }