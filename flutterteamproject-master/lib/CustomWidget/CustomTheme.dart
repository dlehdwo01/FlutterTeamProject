import 'package:flutter/material.dart';


//앱 테마 배경 색상
class CustomTheme extends StatelessWidget {
  final Widget child;

  const CustomTheme({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.purple.shade200, Colors.pink.shade200],
          ),
        ),
        child: child, // 자식 위젯을 표시
      ),
    );
  }
}