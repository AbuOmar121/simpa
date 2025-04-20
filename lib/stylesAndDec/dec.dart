import 'package:flutter/material.dart';

class BoxDec {
  static BoxDecoration get style => BoxDecoration(
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      );
}

/*
class TextDec {
    static InputDecoration Get style => InputDecoration(

    );
}
*/
