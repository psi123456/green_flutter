import 'package:flutter/material.dart'; // 기본 디자인 패키지
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // fontAwesome아이콘 패키지
import 'package:greencraft/screens/main_screen.dart';// 로그인 성공후 이동할 화면 파일경로
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
} // LoginScreen 클래스 StatefulWidget 클래스를 상속 Flutter에서 화면 상태를 관리

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameControl = new TextEditingController();
  final TextEditingController _passwordControl = new TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
 
// Google 로그인 처리 후 비밀번호 입력 화면으로 이동하는 함수
Future<void> _handleGoogleSignIn() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      // Google 로그인 성공. 비밀번호 입력 화면으로 이동
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PasswordInputScreen(email: googleUser.email),
      ));
    }
  } catch (error) {
    String errorMessage = '로그인 실패: ';

    if (error is http.ClientException) {
      // HTTP 클라이언트 오류 처리
      errorMessage += '네트워크 연결 문제';
    } else if (error is TimeoutException) {
      // 타임아웃 오류 처리
      errorMessage += '서버 응답 시간 초과';
    } else if (error is SocketException) {
      // 소켓 오류 처리
      errorMessage += '인터넷 연결을 확인해주세요';
    } else {
      // 기타 오류 처리
      errorMessage += '알 수 없는 오류가 발생했습니다';
    }

    print("Google 로그인 실패: $errorMessage");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}

  Future<void> loginUser() async {
  var url = Uri.parse('http://34.22.80.43:8000/login/'); // 서버의 로그인 API URL

  try {
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameControl.text,
        'password': _passwordControl.text,
      }),
    );

    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      var data = json.decode(decodedBody);

      if (data != null && data['access'] != null) {
        var accessToken = data['access'];
        var username = data['username'].toString(); // 서버에서 받은 username
        var isStaff = data['is_staff'];
        var issuperuser = data['is_superuser'];
        var managercode = data['managercode'];
        var userId = data['userId'].toString(); // 서버에서 받은 userId를 String으로 변환
        var comcode = data['comcode']; // 서버에서 받은 userId를 String으로 변환

        // 정보 출력 및 SharedPreferences에 저장
        print('Logged in user: $username');
        print('ManagerCode: $managercode'); // 여기에 프린트문을 추가하여 managercode 출력

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', accessToken);
        await prefs.setString('username', username);
        await prefs.setBool('isStaff', isStaff);
        await prefs.setBool('issuperuser', issuperuser);
        await prefs.setString('managercode', managercode);
        await prefs.setString('userId', userId); // userId를 String으로 저장
        await prefs.setBool('comcode', comcode);

        // 메인 화면으로 이동
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('로그인 오류: 서버로부터 응답이 올바르지 않습니다.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('로그인 실패: 잘못된 사용자 이름 또는 비밀번호'),
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('로그인 오류: $e'),
    ));
  }
}




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0,0,20,0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[ // build 메서드는 화면을 빌드하는 부분입니다. 
        //ListView 위젯을 사용하여 스크롤 가능한 화면을 생성하고, 
        //그 안에 다양한 위젯들을 배치합니다.

          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: 25.0,
            ),
            child: Text(
              "Log in to your account",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ), // 위 부분은 화면 상단에 로그인 제목을 표시하는 부분입니다.


          SizedBox(height: 30.0),

          Card(
            elevation: 3.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: TextField(
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.white,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Username",
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                  prefixIcon: Icon(
                    Icons.perm_identity,
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                maxLines: 1,
                controller: _usernameControl,
              ),
            ),
          ),
          //위 부분은 사용자 이름을 입력받는 텍스트 필드를 구성합니다. 
          //Card 위젯으로 감싸여 그림자 효과를 주고, 
          //TextField 위젯을 사용하여 텍스트 입력을 받습니다.

          SizedBox(height: 10.0), // 다음 위젯과의 간격을 조절

          Card(
            elevation: 3.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: TextField(
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.white,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Password",
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.black,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                obscureText: true,
                maxLines: 1,
                controller: _passwordControl,
              ),
            ),
          ),

          //위 부분은 비밀번호를 입력받는 텍스트 필드를 구성합니다. 
          //사용자 이름과 유사한 방식으로 구성되어 있지만, 
          //비밀번호 입력 필드이며 비밀번호를 가리키도록 obscureText 속성이
          // true로 설정되어 있습니다.

          SizedBox(height: 10.0),
 
          SizedBox(height: 30.0),

          Container(
             height: 50.0,
             child: ElevatedButton(
               style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary, // 버튼 배경색
               ),
             child: Text(
                "LOGIN".toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
               ),
             ),
             onPressed: (){ 
              loginUser();
            },
           ),
          ),


          SizedBox(height: 10.0),
          Divider(color: Theme.of(context).colorScheme.secondary,),
          SizedBox(height: 10.0),
          //위 부분은 간격을 조절하고 화면 하단에 구분선을 표시합니다.

ElevatedButton(
  onPressed: _handleGoogleSignIn, // 함수 참조 수정
  style: ElevatedButton.styleFrom(
    primary: Color.fromARGB(255, 255, 255, 255),
    onPrimary: Colors.black87,
    minimumSize: Size(double.infinity, 50),
    padding: EdgeInsets.symmetric(horizontal: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset('assets/glogo.png', height: 24.0),
      SizedBox(width: 10),
      Text(
        'Login with Google',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 15.0,
        ),
      ),
    ],
  ),
),


           //구글 아이콘을 포함하고 있습니다.

          SizedBox(height: 20.0), // 간격

        ],
      ),
    );
  }
}
// 비밀번호 입력 화면 (PasswordInputScreen)class PasswordInputScreen extends StatefulWidget {
class PasswordInputScreen extends StatefulWidget {
  final String email;

  PasswordInputScreen({required this.email});

  @override
  _PasswordInputScreenState createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min, // 최소 크기로 정렬
        children: [
          Image.asset('assets/glogo.png', height: 24.0), // Google 로고 이미지
          SizedBox(width: 8.0), // 이미지와 텍스트 사이의 간격
          Text(
            "Login with Google",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card 스타일의 Text 위젯 추가
          Card(
  elevation: 3.0,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0), // padding 수정
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5.0),
      border: Border.all(color: Colors.black54),
    ),
    child: Row(
      children: [
        Icon(
          Icons.perm_identity, // 아이콘 종류 변경 가능
          color: Colors.black,
        ),
        SizedBox(width: 10.0), // 아이콘과 텍스트 사이 간격
        Text(
          "이메일: ${widget.email}",
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.black,
          ),
        ),
      ],
    ),
  ),
),

          SizedBox(height: 20.0), // 간격 추가
          // 기존의 TextField 표시
            TextField(
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.white,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Password",
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.black,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                obscureText: true,
                maxLines: 1,
                controller: _passwordController,
              ),
            ElevatedButton(
               style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary, // 버튼 배경색
               ),
             child: Text(
                "LOGIN".toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
               ),
             ),
             onPressed: (){ 
                _login(widget.email, _passwordController.text, context);
            },
           ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(String username, String password, BuildContext context) async {
    var url = Uri.parse('http://34.22.80.43:8000/login/'); // 서버의 로그인 API URL

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,  // 'username'을 이메일이 아닌 일반유저의 id로 설정
          'password': password,  // 'password'를 사용자 입력 값으로 설정
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null && data['access'] != null) {
          var accessToken = data['access'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwtToken', accessToken);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('로그인 오류: 서버로부터 응답이 올바르지 않습니다.'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('로그인 실패: 잘못된 사용자 이름 또는 비밀번호'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('로그인 오류: $e'),
      ));
    }
  }
}
 