import 'package:flutter/material.dart';

class prevButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData seletIcon;

  const prevButton({
    super.key,
    this.onPressed,
    this.seletIcon = Icons.arrow_back,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(seletIcon),
        iconSize: 35.0,
        color: Colors.black54,
      ),
    );
  }
}
