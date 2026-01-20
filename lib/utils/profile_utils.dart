import 'package:flutter/material.dart';
import 'dart:convert';

class ProfileUtils {
  static Widget buildProfileImage(Map<String, dynamic>? userData, {double size = 35}) {
    final profileImageBase64 = userData?['profileImageBase64'] ?? '';
    
    if (profileImageBase64.isNotEmpty) {
      try {
        return ClipOval(
          child: Image.memory(
            base64Decode(profileImageBase64),
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        print('Error decoding profile image: $e');
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }
}