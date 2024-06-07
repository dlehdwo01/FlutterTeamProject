import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterteamproject/LogIn/LogInMain.dart';

class Setting extends StatefulWidget {
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    // 로그아웃
    void logout(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacementNamed(context, 'loginMain');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset("assets/mainlogo.png",width: 75,height: 75,)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('완료'),
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Divider(color: Colors.black),
            // Container(
            //   color: Colors.white,
            //   child: Column(
            //     children: [
            //       SizedBox(
            //         height: 10,
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Text('내 프로필 공개하기'),
            //         ],
            //       ),
            //       SizedBox(
            //         height: 10,
            //       )
            //     ],
            //   ),
            // ),
            Divider(color: Colors.black),
            GestureDetector(
              onTap: () {
                logout(context);
              },
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('로그아웃'),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
            // Divider(color: Colors.black),
            // Container(
            //   color: Colors.white,
            //   child: Column(
            //     children: [
            //       SizedBox(
            //         height: 10,
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Text('계정 삭제하기'),
            //         ],
            //       ),
            //       SizedBox(
            //         height: 10,
            //       )
            //     ],
            //   ),
            // ),
            Divider(color: Colors.black),
          ],
        ),
      ),
    );
  }
}
