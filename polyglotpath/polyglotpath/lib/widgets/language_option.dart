// language_option.dart

import 'package:flutter/material.dart';

class LanguageOption extends StatelessWidget {
  final String imagePath;
  final String language;

  const LanguageOption({
    required this.imagePath,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 137,
      height: 153,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Color(0xFFD9D9D9),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              imagePath,
              width: 100,
              height: 100,
            ),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 251, 251, 251)
                  : Color.fromARGB(255, 178, 182, 182),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
