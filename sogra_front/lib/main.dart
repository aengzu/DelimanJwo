import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sizing/sizing.dart';
import 'package:sogra_front/view/main_screens.dart';

import 'package:sogra_front/view/splash_view/splash_screen.dart';

import 'constants/theme.dart';

void main() {
  runApp(
    DelimanjooApp(),
  );
}

class DelimanjooApp extends StatelessWidget {
  const DelimanjooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SizingBuilder(
      builder: () => GetMaterialApp(
        theme: theme(),
        title: 'DelimanjooApp',
        debugShowCheckedModeBanner: false,
        home: MainScreens(),
      ),
    );
  }
}
