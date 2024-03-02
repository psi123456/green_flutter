import 'package:flutter/material.dart';
class Constants {
  static String appName = "GreenCraft";

  //Colors for theme
  static Color lightPrimary = Color.fromARGB(255, 255, 255, 255);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Color(0xFF7ed957);
  static Color lightBG = const Color.fromARGB(255, 255, 255, 255);
  static Color darkBG = Colors.black;
  static Color ratingBG = Colors.yellow[600] ?? Colors.yellow; // null 체크


 // 라이트 테마 데이터 정의
  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG, // 전체 배경색
    primaryColor: lightPrimary, // 기본색
    colorScheme: ColorScheme.light(
      primary: lightPrimary, // 테마의 기본색
      secondary: lightAccent, // 테마의 악센트색
      background: lightBG, // 테마의 배경색
      onPrimary: Colors.black, // 기본색 위의 텍스트 및 아이콘 색상을 검정색으로 설정
      onSecondary: darkBG, // 악센트색 위의 텍스트 및 아이콘 색상
      onBackground: darkBG, // 배경색 위의 텍스트 및 아이콘 색상
    ),
    //scaffoldBackgroundColor: lightBG, // Scaffold 위젯의 기본 배경색
   appBarTheme: AppBarTheme(
  color: lightPrimary, // 앱바 배경색을 흰색으로 설정
  titleTextStyle: TextStyle(
    color: darkBG, // 앱바 타이틀 텍스트 색상을 검정색으로 설정
    fontSize: 18.0,
    fontWeight: FontWeight.w800,
  ),
  
  iconTheme: IconThemeData(color: darkBG), // 앱바 아이콘 색상을 검정색으로 설정
),

    textTheme: TextTheme(
      bodyText1: TextStyle(color: darkBG), // 본문 텍스트 스타일1
      bodyText2: TextStyle(color: darkBG), // 본문 텍스트 스타일2
      // 필요한 경우 다른 텍스트 스타일 추가
    ),
    // 필요한 경우 다른 테마 속성 추가
  );
}

