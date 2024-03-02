import 'package:flutter/material.dart';
import 'package:greencraft/screens/login.dart';
import 'package:greencraft/screens/register.dart';
import 'package:flutter/services.dart';


class JoinApp extends StatefulWidget {
  @override
  _JoinAppState createState() => _JoinAppState();
} //이 위젯은 회원 가입 및 로그인을 관리하는 화면을 표시합니다.

class _JoinAppState extends State<JoinApp> with SingleTickerProviderStateMixin{

  late TabController _tabController;

 @override
void initState() {
  super.initState();
  _tabController = TabController(vsync: this, initialIndex: 0, length: 2);   
  // Login 탭을 기본 탭으로 설정
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
}//SystemChrome.setEnabledSystemUIMode를 사용하여 시스템 UI 모드를 설정합니다. 
 //이 설정은 시스템 UI(예: 네비게이션 바)를 사용자가 수동으로 제어할 수 있도록 합니다

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
          ),
          onPressed: ()=>Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
          tabs: <Widget>[
            Tab(
              text: "Login",
            ),
            Tab(
              text: "Register",
            ),
          ],
        ),
      ),

      body: TabBarView( //TabBarView 위젯은 실제 로그인 화면(LoginScreen)과 
                        //회원 가입 화면(RegisterScreen)을 표시하는 부분입니다.
        controller: _tabController,
        children: <Widget>[
          LoginScreen(),
          RegisterScreen(),
        ],
      ),


    ); //이 코드는 회원 가입과 로그인 화면을 탭으로 구분하여 표시하는 화면을 구성한 부분
  }
}
