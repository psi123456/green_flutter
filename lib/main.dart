import 'package:flutter/material.dart'; // 기본 머티리얼 디자인
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/splash.dart';
import 'util/const.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget? child) {
        return MaterialApp(
          key: appProvider.key,
          debugShowCheckedModeBanner: false,
          navigatorKey: appProvider.navigatorKey,
          title: Constants.appName,
          theme: Constants.lightTheme , // 라이트 테마를 사용
          themeMode: ThemeMode.light, // 앱을 라이트 모드로 강제 설정
           home: SplashScreen(),
        );
      },
    );
  }
}