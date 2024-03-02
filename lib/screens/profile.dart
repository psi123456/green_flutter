import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greencraft/providers/app_provider.dart';
import 'package:greencraft/screens/splash.dart';
import 'package:greencraft/util/const.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greencraft/screens/join.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String username = '';
  String email = '';
  String phone = '';
  String address = '';
  String sex = '';
  String birthDate = '';

  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  void dispose() {
    // 위젯이 dispose 될 때, 컨트롤러도 dispose 해주어야 합니다.
    passwordController.dispose();
    super.dispose();
  }

// 로그인 시 username 저장
  Future<void> saveLoginInfo(String username, String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('jwtToken', accessToken);
    print('Saved username: $username'); // 저장된 username 확인
  }

// _onUpdate 함수 내에서 토큰과 사용자 ID 불러오기
  void _onUpdate(
    String newEmail,
    String newPhone,
    String newAddress,
    String newSex,
    String newBirthdate,
    String Password, // 현재 비밀번호 확인용으로만 전달
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final username = prefs.getString('username');

    if (username == null || token == null) {
      print('로그인한 사용자 ID 또는 토큰을 찾을 수 없습니다. ID: $username, Token: $token');
      return;
    }

    final url = Uri.parse('http://34.22.80.43:8000/users/$username/');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "username": username,
        "email": newEmail,
        "phone": newPhone,
        "address": newAddress,
        "sex": newSex,
        "password": Password, // 현재 비밀번호 확인용으로만 전달
        "birthdate": newBirthdate, // 생년월일 업데이트
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        email = newEmail;
        phone = newPhone;
        address = newAddress;
        sex = newSex;
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken') ?? ''; // 'jwtToken'은 토큰을 저장할 때 사용한 키입니다.
  }

  Future<void> _showEditDialog() async {
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController phoneController = TextEditingController(text: phone);
    TextEditingController addressController =
        TextEditingController(text: address);
    TextEditingController sexController = TextEditingController(text: sex);
    TextEditingController passwordController =
        TextEditingController(); // 패스워드 입력 컨트롤러
    TextEditingController birthDateController =
        TextEditingController(text: birthDate);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '회원정보 수정 Edit Profile',
            style: TextStyle(color: Colors.white), // 타이틀 텍스트 색상을 흰색으로 변경
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildTextField(emailController, "Enter new email"),
                _buildTextField(phoneController, "Enter new phone"),
                _buildTextField(addressController, "Enter new address"),
                _buildTextField(sexController, "Enter new gender"),
                _buildTextField(birthDateController, "Enter new birthdate"),
                TextField(
                  controller: passwordController, // 패스워드 입력 필드
                  obscureText: true, // 입력 내용을 가리기 위해 true로 설정
                  decoration: InputDecoration(
                      hintText: "Enter password",
                      hintStyle: TextStyle(color: Colors.black)),
                      cursorColor: Colors.black,
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white, // 배경 색상 변경
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color:
                          Color.fromARGB(255, 4, 4, 4))), // 버튼 텍스트 색상을 흰색으로 변경
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor, // 버튼 배경색 설정
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update',
                  style: TextStyle(
                      color:
                          Color.fromARGB(255, 0, 0, 0))), // 버튼 텍스트 색상을 흰색으로 변경
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor, // 버튼 배경색 설정
              ),
              onPressed: () {
                _onUpdate(
                  emailController.text,
                  phoneController.text,
                  addressController.text,
                  sexController.text,
                  birthDateController.text, // 생년월일도 업데이트 함수에 전달
                  passwordController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black),
      ),
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black),
    );
  }

//삭제 함수
  // Future<void> _handleDeleteAccount() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('jwtToken');
  //   final username = prefs.getString('username');

  //   if (token == null || username == null) {
  //     print('Token or username not found');
  //     return;
  //   }

  //   final url = Uri.parse('http://10.0.2.2:8000/users/$username/');

  //   final response = await http.delete(
  //     url,
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200 || response.statusCode == 204) {
  //     // 회원 탈퇴 성공 처리
  //     // 예: 로그아웃 처리, 로그인 화면으로 이동 등
  //     await _handleLogout();
  //   } else {
  //     // 회원 탈퇴 실패 처리
  //     print('Failed to delete account. Status code: ${response.statusCode}');
  //   }
  // }
  Future<void> _deleteUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final username = prefs.getString('username');
    final fetchUrl = Uri.parse('http://34.22.80.43:8000/users/$username/');
    final fetchResponse = await http.get(
      fetchUrl,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (fetchResponse.statusCode == 200) {
      // 사용자 정보 확인 후 비밀번호 입력 다이얼로그 표시
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('회원탈퇴를 위한 비밀번호를 입력해주세요',
                      style: TextStyle(
                        color: Colors.black, // 텍스트 색상을 검정으로 설정
                        fontSize: 18.0, // 폰트 크기 설정
                        fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                      )),
                content: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                  cursorColor: Colors.black,
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black, // 텍스트 색상을 검정으로 설정
                        fontSize: 16.0, // 폰트 크기 설정
                        fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.black, // 텍스트 색상을 검정으로 설정
                        fontSize: 16.0, // 폰트 크기 설정
                        fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirmed) {
        // 비밀번호 확인 후 계정 삭제 요청
        final deleteResponse = await http.delete(
          fetchUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'password': passwordController.text, // 비밀번호 전송
          }),
        );

        if (deleteResponse.statusCode == 200 ||
            deleteResponse.statusCode == 204) {
          // 계정 삭제 성공 로직
          print('Account successfully deleted');
          Navigator.of(context).pop(); // 현재 다이얼로그 닫기
          _showDeleteSuccessDialog(); // 회원 탈퇴 완료 다이얼로그 표시
        } else {
          // 계정 삭제 실패 로직
          print('Failed to delete account');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account')),
          );
        }
      }
    } else {
      print('Failed to fetch user data');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data')),
      );
    }
  }

  Future<void> _showDeleteSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 사용자가 다이얼로그 바깥을 탭해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원 탈퇴 완료'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('회원 탈퇴가 정상적으로 처리되었습니다.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.black, // 텍스트 색상을 검정으로 설정
                  fontSize: 16.0, // 폰트 크기 설정
                  fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                ),
              ),
              onPressed: () {
                // 필요한 경우, 로그인 화면으로 리디렉션하는 로직 추가
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => JoinApp()));
              },
            ),
          ],
        );
      },
    );
  }

//
  Future<void> _fetchUserInfo() async {
    try {
      final token = await _getToken(); // 토큰을 가져오는 함수
      final url = Uri.parse('http://34.22.80.43:8000/user/profile/'); // 백엔드 URL
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // 헤더에 토큰 추가
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          username = data['username'];
          email = data['email'];
          phone = data['phone'];
          address = data['address'];
          sex = data['sex'] ?? '';
          birthDate = data['birthdate'] ?? ''; // 생년월일 정보 추가
        });
      } else {
        // 에러 처리
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // 예외 처리
      print('Exception: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Google 로그인 상태 확인
      if (await _googleSignIn.isSignedIn()) {
        // Google 로그아웃 처리
        await _googleSignIn.signOut();
      }

      // 일반 로그아웃 처리
      // 예: 사용자 세션 데이터 삭제, 로그인 화면으로 이동 등
      // ...

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => JoinApp()));
    } catch (error) {
      // 로그아웃 실패 처리
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("로그아웃 실패: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // 원형 이미지 틀로 설정
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // 그림자 색상
                          spreadRadius: 5, // 그림자 확산 범위
                          blurRadius: 7, // 그림자 흐림 정도
                          offset: Offset(0, 3), // 그림자 위치 (x, y)
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/cm4.jpeg",
                      fit: BoxFit.cover,
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            " ID : ${username}", // 서버로부터 받아온 사용자 이름
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            " Email : ${email}", // 서버로부터 받아온 이메일 주소
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: _handleLogout,
                            child: Text(
                              " Logout",
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.red,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  flex: 3,
                ),
              ],
            ),
            Divider(),
            Container(height: 15.0),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "Account Information".toUpperCase(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Email",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              subtitle: Text(email), // 서버로부터 받아온 사용자 이름 사용
            ),
            ListTile(
              title: Text(
                "Phone",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(phone),
            ),
            ListTile(
              title: Text(
                "Address",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(address),
            ),
            ListTile(
              title: Text(
                "Gender",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(sex),
            ),
            ListTile(
              title: Text(
                "생년월일",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(birthDate),
            ),
            ElevatedButton(
              onPressed: _showEditDialog,
              child: Text('회원정보 수정'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                elevation: 5, // 버튼의 그림자 강도 설정
                shape: RoundedRectangleBorder(
                  // 버튼의 모양을 둥근 모서리 직사각형으로 설정
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                      color: Colors.black, width: 2), // 테두리를 검정색으로 설정
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _deleteUserAccount,
              child: Text('회원탈퇴'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                elevation: 5, // 버튼의 그림자 강도 설정
                shape: RoundedRectangleBorder(
                  // 버튼의 모양을 둥근 모서리 직사각형으로 설정
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                      color: Colors.black, width: 2), // 테두리를 검정색으로 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
