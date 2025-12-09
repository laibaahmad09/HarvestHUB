import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isLoading;
  const RoundButton({super.key ,
    required this.title,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 330,
        decoration: BoxDecoration(
          color: isLoading ? Color(0xFF2e5e25).withOpacity(0.7) : Color(0xFF2e5e25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isLoading 
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  title, 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 17, 
                    fontWeight: FontWeight.w700
                  ),
                ),
        ),
      ),
    );
  }
}
