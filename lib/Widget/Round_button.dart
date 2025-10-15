import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const RoundButton({super.key ,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 330,
        decoration: BoxDecoration(
          color: Color(0xFF2e5e25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(title, style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),),)
      ),
    );
  }
}
