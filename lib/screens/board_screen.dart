import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greencraft/screens/board_update.dart';
import 'package:greencraft/screens/main_screen.dart';

class BoardDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  BoardDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _BoardDetailScreenState createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  // 조회수를 증가시키는 함수
  Future<void> increaseViewCount() async {
    final response = await http.put(
      Uri.parse('http://34.22.80.43:8080/boards/${widget.post['no']}/view'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to increase views');
    }
  }

  // 게시글 삭제 함수 - 비밀번호 입력 다이얼로그 표시 기능 포함
  Future<void> deletePost() async {
    // 비밀번호 입력 다이얼로그 표시
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('비밀번호 입력'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: '비밀번호'),
            cursorColor: Colors.black,
            obscureText: true, // 비밀번호를 숨김 처리
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '삭제',
                style: TextStyle(
                  color: Colors.black, // 텍스트 색상을 검정으로 설정
                  fontSize: 16.0, // 폰트 크기 설정
                  fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                final String password = passwordController.text;
                // 비밀번호를 JSON 본문으로 포함하여 삭제 요청 전송
                final response = await http.delete(
                  Uri.parse('http://34.22.80.43:8080/boards/${widget.post['no']}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: json.encode({'password': password}), // 비밀번호를 JSON으로 전송
                );

                if (response.statusCode == 200) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainScreen()), // `HomeScreen`은 홈 화면 위젯의 클래스명으로 가정
                  ); // 성공적으로 삭제되면 이전 화면으로 돌아가면서 true 반환
                } else {
                  // 비밀번호 불일치 또는 기타 오류 처리
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          '오류',
                          style: TextStyle(
                            color: Colors.black, // 텍스트 색상을 검정으로 설정
                            fontSize: 16.0, // 폰트 크기 설정
                            fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                          ),
                        ),
                        content: Text('게시글 삭제에 실패했습니다. 비밀번호를 확인해주세요.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              '닫기',
                              style: TextStyle(
                                color: Colors.black, // 텍스트 색상을 검정으로 설정
                                fontSize: 16.0, // 폰트 크기 설정
                                fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MainScreen()), // `HomeScreen`은 홈 화면 위젯의 클래스명으로 가정
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(
                  color: Colors.black, // 텍스트 색상을 검정으로 설정
                  fontSize: 16.0, // 폰트 크기 설정
                  fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    increaseViewCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post['title']),
        backgroundColor: Colors.grey[200], // 앱 바 색상 변경
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post['title'],
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black, // 제목 색상 변경
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              "글쓴이: ${widget.post['username']}",
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic, // 글쓴이 스타일 변경
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              "조회수: ${widget.post['viewCount']}",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[600], // 조회수 색상 변경
              ),
            ),
            SizedBox(height: 8.0),
            Divider(),
            Text(
              widget.post['content'],
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: 0.5, // 글자 간격 조정
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "edit",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BoardUpdateScreen(post: widget.post),
                ),
              );
            },
            child: Icon(Icons.edit),
            backgroundColor: Colors.blue, // 수정 버튼 색상 변경
            tooltip: 'Edit Post',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "delete",
            onPressed: () => deletePost(),
            backgroundColor: Colors.red, // 삭제 버튼 색상 변경
            child: Icon(Icons.delete),
            tooltip: 'Delete Post',
          ),
        ],
      ),
    );
  }
}
