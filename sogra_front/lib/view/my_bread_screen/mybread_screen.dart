import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/image_assets.dart';
import '../components/appbar_preffered_size.dart';

class MybreadScreen extends StatelessWidget {
  const MybreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title:
        Text(
          '델리만쥬',
          style: GoogleFonts.gugi(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: appBarBottomLine(),
      ),
      body: Center(
        child: Text('내빵'),
      ),
    );
  }
}
