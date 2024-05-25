import 'package:flutter/material.dart';
import 'package:sogra_front/constants/color.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading; // 로딩 상태를 위한 변수 추가

  const CustomButton({Key? key, required this.label, required this.onPressed, this.isLoading = false})
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
        onPressed: isLoading ? null : onPressed, // 로딩 중일 때는 버튼 비활성화
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white) // 로딩 중일 때는 인디케이터 표시
            : Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
    );
  }
}
