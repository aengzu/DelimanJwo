import 'package:flutter/material.dart';
import 'package:sogra_front/constants/color.dart';


class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CustomButton({Key? key, required this.label, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 50.0,
      width: screenWidth * 0.8,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor().secondaryColor, // 버튼의 배경색
          elevation: 2, // 그림자 높이 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0), // 버튼 모양을 둥글게 설정
          ),
        ),
        onPressed: onPressed, // 버튼 클릭 이벤트 연결
        child: Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
    );
  }
}
