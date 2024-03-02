import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:greencraft/screens/join.dart';
import 'package:greencraft/screens/googlesignuppage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  //회원가입 화면 정의
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameControl = new TextEditingController();
  final TextEditingController _emailControl = new TextEditingController();
  final TextEditingController _passwordControl = new TextEditingController();
  final TextEditingController _confirmPasswordControl =
      new TextEditingController();
  final TextEditingController _addressControl = new TextEditingController();
  final TextEditingController _phoneControl = new TextEditingController();
  final TextEditingController _managerCodeControl = new TextEditingController();
  final TextEditingController _comCodeControl = new TextEditingController();

  String _selectedSex = '남성'; // '남'을 기본값으로 설정
  bool _isCompanyMember = false; // 회원 유형(기업 회원 여부)
  int selectedYear = DateTime.now().year;
  int selectedMonth = 1;
  int selectedDay = 1;

  @override
  void initState() {
    super.initState();
    // 현재 연도를 기본값으로 설정
    selectedYear = DateTime.now().year;
    selectedMonth = 1; // 1월을 기본값으로 설정
    selectedDay = 1; // 1일을 기본값으로 설정
  }

  List<DropdownMenuItem<int>> getYears() {
    return List.generate(100, (index) {
      return DropdownMenuItem(
        value: DateTime.now().year - index,
        child: Text((DateTime.now().year - index).toString()),
      );
    });
  }

  List<DropdownMenuItem<int>> getMonths() {
    return List.generate(12, (index) {
      return DropdownMenuItem(
        value: index + 1,
        child: Text((index + 1).toString()),
      );
    });
  }

  List<DropdownMenuItem<int>> getDays() {
    return List.generate(31, (index) {
      return DropdownMenuItem(
        value: index + 1,
        child: Text((index + 1).toString()),
      );
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF7ed957), // 배경 색상 변경
          title: Text(
            '회원가입 완료',
            style: TextStyle(color: Colors.white), // 타이틀 텍스트 색상 변경
          ),
          content: Text(
            '회원가입이 성공적으로 완료되었습니다.',
            style: TextStyle(color: Colors.white), // 본문 텍스트 색상 변경
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // 버튼 배경색 변경
                onPrimary: Colors.black, // 버튼 텍스트 색상 변경
              ),
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _navigateToLoginPage(); // 로그인 페이지로 이동
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToLoginPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => JoinApp()), // JoinApp 로그인 페이지 위젯
    );
  }

// Google 로그인 버튼 클릭 시 호출되는 함수
  Future<void> _openGoogleSignUpPage() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // Google 로그인 성공, 새로운 회원가입 페이지로 이동
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => GoogleSignUpPage(
            googleUser: googleUser, // Google 사용자 정보 전달
          ),
        ));
      }
    } catch (error) {
      print('Google sign in failed: $error');
    }
  }

  Future<void> registerUser() async {
    // 날짜 포매팅을 위한 함수 추가
    String formatDateTime(int year, int month, int day) {
      final formattedMonth = month.toString().padLeft(2, '0');
      final formattedDay = day.toString().padLeft(2, '0');
      return "$year-$formattedMonth-$formattedDay";
    }

    final birthdate = formatDateTime(selectedYear, selectedMonth, selectedDay);

    try {
      final url = Uri.parse('http://34.22.80.43:8000/users/'); // 서버 URL을 확인하세요

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": _usernameControl.text ?? '',
          "email": _emailControl.text ?? '',
          "password": _passwordControl.text ?? '',
          "address": _addressControl.text ?? '',
          "phone": _phoneControl.text ?? '',
          "comcode": _isCompanyMember, // comcode는 boolean 값
          "managercode": _isCompanyMember
              ? _managerCodeControl.text ?? ''
              : '', // _isCompanyMember가 true일 때만 managercode 전송
          "sex": _selectedSex ?? '',
          "birthdate": birthdate, // 수정된 부분
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        // 실패 처리
        print('Failed to register user. Status code: ${response.statusCode}');
        print("Request Data: $response");
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  // 입력 필드 관리 여기에 추가 가능
  String _passwordMatchStatus = ''; // 비밀번호 일치 상태 메시지

  void _checkPasswordMatch() {
    if (_passwordControl.text == _confirmPasswordControl.text) {
      setState(() {
        _passwordMatchStatus = '비밀번호가 일치합니다';
      });
    } else {
      setState(() {
        _passwordMatchStatus = '비밀번호가 불일치합니다';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 0, 20, 0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: 25.0,
            ),
            child: Text(
              "Create an account",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),

          SizedBox(height: 30.0),

          // Username 입력
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
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Username *",
                  prefixIcon: Icon(
                    Icons.perm_identity,
                    color: Colors.black,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                maxLines: 1,
                controller: _usernameControl,
              ),
            ),
          ),

          SizedBox(height: 10.0),

          // Email 입력
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
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Email *",
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: Colors.black,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                maxLines: 1,
                controller: _emailControl,
              ),
            ),
          ),

          SizedBox(height: 10.0),

          //Password 입력란
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
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Password *",
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
                onChanged: (text) {
                  _checkPasswordMatch();
                },
                controller: _passwordControl,
              ),
            ),
          ),

          SizedBox(height: 2.0),
          //Password 확인 입력란
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
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Password 확인 *",
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
                onChanged: (text) {
                  _checkPasswordMatch();
                },
                controller: _confirmPasswordControl,
              ),
            ),
          ),
          Text(
            _passwordMatchStatus,
            style: TextStyle(
              color: _passwordMatchStatus == '비밀번호가 일치합니다'
                  ? Color(0xFF7ed957)
                  : Colors.red,
            ),
          ),

          SizedBox(height: 10.0),

          // Phone 입력란
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
                keyboardType: TextInputType.number, // 숫자 키보드 설정
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Phone *  ' - ' 는 제거해주세요",
                  prefixIcon: Icon(
                    Icons.phone, // 아이콘을 전화기로 변경
                    color: Colors.black,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                obscureText: false,
                maxLines: 1,
                controller: _phoneControl,
              ),
            ),
          ),

          SizedBox(height: 10.0),

          // 주소 address 입력
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
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Address",
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Colors.black,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                maxLines: 1,
                controller: _addressControl,
              ),
            ),
          ),

          SizedBox(height: 10.0),

          // 기업 코드 입력
          Card(
            elevation: 3.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: DropdownButtonFormField<int>(
                value: _isCompanyMember ? 1 : 0, // 기본값 설정 (일반 회원: 0, 사업자 회원: 1)
                onChanged: (int? newValue) {
                  setState(() {
                    _isCompanyMember = newValue == 1; // 선택된 값에 따라 회원 유형 설정
                  });
                },
                items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text("일반 회원"),
                  ),
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text("사업자 회원"),
                  ),
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "회원 유형 선택 *",
                  prefixIcon: Icon(
                    Icons.business, // 회사 코드를 나타내는 아이콘으로 'business' 사용
                    color: Colors.black,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.0),

          // 사업자 코드 입력
          if (_isCompanyMember)
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
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    hintText: "사업자 코드 *",
                    prefixIcon: Icon(
                      Icons.vpn_key, // 관리자 코드를 나타내는 아이콘으로 'vpn_key' 사용
                      color: Colors.black,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  ),
                  cursorColor: Colors.black,
                  maxLines: 1,
                  controller: _managerCodeControl,
                ),
              ),
            ),

          SizedBox(height: 10.0),

          // 성별 입력
          Card(
            elevation: 3.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    '성별',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10.0), // '성별'과 드롭다운 메뉴 사이 간격
                  DropdownButton<String>(
                    value: _selectedSex,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSex = newValue!;
                      });
                    },
                    items: <String>['남성', '여성']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.0),

// 생년월일 입력 부분
          Card(
            elevation: 3.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.cake, // 생일 아이콘
                    color: Colors.black,
                  ),
                  SizedBox(width: 10.0), // 아이콘과 텍스트 사이 간격
                  Text(
                    "생년월일",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 20.0), // 텍스트와 드롭다운 사이 간격
                  DropdownButton<int>(
                    // 연도 선택 DropdownButton
                    value: selectedYear,
                    items: getYears(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    // 월 선택 DropdownButton
                    value: selectedMonth,
                    items: getMonths(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    // 일 선택 DropdownButton
                    value: selectedDay,
                    items: getDays(),
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40.0),

// Register 가입버튼
          Container(
            height: 50.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary, // 버튼의 배경색 설정
              ),
              child: Text(
                "Register".toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                registerUser();
              },
            ),
          ),

          SizedBox(height: 10.0),
          Divider(
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: 10.0),

          ElevatedButton(
            onPressed: _openGoogleSignUpPage, // Google 로그인 함수 연결
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 255, 255, 255),
              onPrimary: Colors.black87, // 글자색
              minimumSize: Size(double.infinity, 50), // 버튼의 최소 사이즈
              padding: EdgeInsets.symmetric(horizontal: 12), // 좌우 패딩
              elevation: 2, // 버튼의 그림자
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0), // 버튼의 모서리 둥글게
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // 버튼 내용의 최소 크기만큼만 차지
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/glogo.png', height: 24.0), // 로고 이미지
                SizedBox(width: 10), // 로고와 텍스트 사이 간격
                Text(
                  'Register with Google',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
