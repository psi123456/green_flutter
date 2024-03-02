import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greencraft/screens/main_screen.dart';

class BoardUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  BoardUpdateScreen({Key? key, required this.post}) : super(key: key);

  @override
  _BoardUpdateScreenState createState() => _BoardUpdateScreenState();
}

class _BoardUpdateScreenState extends State<BoardUpdateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 컨트롤러
  final TextEditingController _usernameController = TextEditingController(); // 글쓴이 컨트롤러

 @override
void initState() {
  super.initState();
  _titleController.text = widget.post['title'] ?? ''; // 기본값으로 빈 문자열 제공
  _contentController.text = widget.post['content'] ?? ''; // 기본값으로 빈 문자열 제공
  _usernameController.text = widget.post['username'] ?? ''; // 글쓴이 필드 초기화, 기본값으로 빈 문자열 제공
  // 비밀번호는 initState에서 초기화하지 않을 수도 있습니다. 필요에 따라 추가하세요.
}


  Future<void> updatePost() async {
    final Uri url = Uri.parse('http://34.22.80.43:8080/boards/${widget.post['no']}');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': _titleController.text,
        'content': _contentController.text,
        'password': _passwordController.text, // 비밀번호 추가
        'username': _usernameController.text, // 글쓴이 추가
      }),
    );

    if (response.statusCode == 200) {
  // 홈 화면으로 직접 네비게이트
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => MainScreen()), // `HomeScreen`은 홈 화면 위젯의 클래스명으로 가정
  );
}
 else {
      // 실패 처리
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update the post.'),
            actions: <Widget>[
              TextButton(
                child: Text('Close',
                      style: TextStyle(
                        color: Colors.black, // 텍스트 색상을 검정으로 설정
                        fontSize: 16.0, // 폰트 크기 설정
                        fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                      ),),
                onPressed: () {
                    Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              cursorColor: Colors.black,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 8.0),
            Row(
  children: <Widget>[
    Expanded( // Row의 가능한 모든 공간을 차지하도록 함
      child: TextField(
        controller: _passwordController,
        decoration: InputDecoration(labelText: 'Password'),
        cursorColor: Colors.black,
        obscureText: true,
      ),
    ),
  ],
),

            SizedBox(height: 24),
            ElevatedButton(
              onPressed: updatePost,
              child: Text('Update',
                      style: TextStyle(
                        color: Colors.black, // 텍스트 색상을 검정으로 설정
                        fontSize: 16.0, // 폰트 크기 설정
                        fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                      ),),
            ),
          ],
        ),
      ),
    );
  }
}