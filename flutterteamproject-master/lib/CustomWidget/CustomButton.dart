import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final Color ButtonColor;

  const CustomButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.ButtonColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText,
        style: (
            TextStyle(fontWeight: FontWeight.bold, color: Colors.black )
        ),
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(ButtonColor),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        fixedSize: WidgetStateProperty.all<Size>(Size(300, 50)),
      ),
    );
  }
}
