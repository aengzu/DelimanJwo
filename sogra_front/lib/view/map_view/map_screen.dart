import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import '../components/appbar_preffered_size.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  Completer<NaverMapController> _controller = Completer();


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
      body: Container(
        child: NaverMap(
          options: const NaverMapViewOptions(

          ),
          onMapReady: (controller) {
            print("네이버 맵 로딩됨!");
          },
        ),
      ),
    );

  }

}

