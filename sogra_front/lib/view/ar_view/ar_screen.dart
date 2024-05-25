import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sogra_front/view/components/appbar_preffered_size.dart';

class ArScreen extends StatelessWidget {
  const ArScreen({super.key});

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
        child: Text('AR Screen'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ArScreen(),
  ));
}
