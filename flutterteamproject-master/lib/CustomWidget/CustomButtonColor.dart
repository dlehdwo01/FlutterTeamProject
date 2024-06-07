import 'package:flutter/material.dart';

class CustomColorButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const CustomColorButton({
    super.key,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Container(
          width: 300,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed))
                return Colors.transparent;
              return null; // Defer to the widget's default.
            },
          ),
        ),
      ),
    );
  }
}