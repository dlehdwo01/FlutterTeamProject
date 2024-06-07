import 'package:flutter/material.dart';

class CustomImageButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String imagePath;
  final double width;
  final double height;
  final Color ButtonColor;

  const CustomImageButton({
    super.key,
    required this.onPressed,
    required this.imagePath,
    this.width = 300,
    this.height = 50,
    this.ButtonColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Image.asset(imagePath, fit: BoxFit.cover), // 이미지를 버튼에 맞추어 채우기
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(ButtonColor),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
          ),
        ),
        fixedSize: WidgetStateProperty.all<Size>(Size(width, height)), // 버튼 크기 고정
        padding: WidgetStateProperty.all(EdgeInsets.zero), // 패딩 제거
      ),
    );
  }
}