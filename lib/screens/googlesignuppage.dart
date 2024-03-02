import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:greencraft/screens/join.dart';
import 'package:greencraft/screens/googlesignuppage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignUpPage extends StatefulWidget {
  final GoogleSignInAccount googleUser;

  GoogleSignUpPage({Key? key, required this.googleUser}) : super(key: key);

  @override
  _GoogleSignUpPageState createState() => _GoogleSignUpPageState();
}

class _GoogleSignUpPageState extends State<GoogleSignUpPage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordControl;
  late TextEditingController _confirmPasswordControl;
  late TextEditingController _addressControl;
  late TextEditingController _phoneControl;
  late TextEditingController _managerCodeControl;
  late TextEditingController _comCodeControl;
  late TextEditingController _sexControl;
  late String _passwordMatchStatus;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.googleUser.email);
    _passwordControl = TextEditingController();
    _confirmPasswordControl = TextEditingController();
    _addressControl = TextEditingController();
    _phoneControl = TextEditingController();
    _managerCodeControl = TextEditingController();
    _comCodeControl = TextEditingController();
    _sexControl = TextEditingController();
    _passwordMatchStatus = '';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF7ed957),
          title: Text('회원가입 완료', style: TextStyle(color: Colors.white)),
          content: Text('회원가입이 성공적으로 완료되었습니다.',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white, onPrimary: Colors.black),
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLoginPage();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToLoginPage() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => JoinApp()));
  }

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

  Future<void> _registerUser() async {
    try {
      final url = Uri.parse('http://34.22.80.43:8000/users/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": _usernameController.text, // 사용자가 입력한 사용자 이름
          "email": widget.googleUser.email, // Google 계정의 이메일
          "password": _passwordControl.text,
          "address": _addressControl.text,
          "phone": _phoneControl.text,
          "managercode": _managerCodeControl.text,
          "comcode": _comCodeControl.text,
          "sex": _sexControl.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        print('Failed to register user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 20),
            // 비밀번호 입력란
            TextField(
              controller: _passwordControl,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              cursorColor: Colors.black,
              onChanged: (text) {
                _checkPasswordMatch();
              },
            ),

            TextField(
              controller: _confirmPasswordControl,
              obscureText: true,
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
              maxLines: 1,
              onChanged: (text) {
                _checkPasswordMatch();
              },
            ),
            Text(
              _passwordMatchStatus,
              style: TextStyle(
                color: _passwordMatchStatus == '비밀번호가 일치합니다'
                    ? Colors.green
                    : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            TextField(
              controller: _addressControl,
              decoration: InputDecoration(labelText: 'Address'),
              cursorColor: Colors.black,
            ),
            TextField(
              controller: _phoneControl,
              decoration: InputDecoration(labelText: 'Phone'),
              cursorColor: Colors.black,
            ),
            TextField(
              controller: _managerCodeControl,
              decoration: InputDecoration(labelText: 'Manager Code'),
              cursorColor: Colors.black,
            ),
            TextField(
              controller: _comCodeControl,
              decoration: InputDecoration(labelText: 'Company Code'),
              cursorColor: Colors.black,
            ),
            TextField(
              controller: _sexControl,
              decoration: InputDecoration(labelText: 'Gender'),
              cursorColor: Colors.black,
            ),
            ElevatedButton(
              onPressed: _registerUser,
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary, // 버튼의 배경색 설정
              ),
              child: Text(
                "Register".toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
