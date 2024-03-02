import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'QuizManagerScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz App',
      home: QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final String _baseUrl = 'http://34.22.80.43:8080/api/quizzes';
  List _quizzes = [];
  Map<String, String> _answers = {};
  bool _issuperuser = false; // Add this line

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
    loadIsAdminStatus(); // initState에서 이 메서드를 호출
  }

  void loadIsAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool issuperuser = prefs.getBool('issuperuser') ??
        false; // SharedPreferences에서 is_admin 값을 로드
    setState(() {
      _issuperuser = issuperuser; // 상태 업데이트
    });
  }

  fetchQuizzes() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      setState(() {
        _quizzes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  void _navigateToQuizManagerScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => QuizManagerScreen()),
    );
  }

  void submitAllAnswers() async {
    // 모든 문제에 대한 답변이 입력되었는지 확인
    if (_answers.length < _quizzes.length) {
      // 답변이 누락된 경우 경고 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '경고',
              style: TextStyle(
                color: Colors.black, // 텍스트 색상을 검정으로 설정
                fontSize: 16.0, // 폰트 크기 설정
                fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
              ),
            ),
            content: Text('모든 문제의 답을 입력해주세요.'),
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
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
            ],
          );
        },
      );
      return; // 함수 종료
    }
    final url = Uri.parse('$_baseUrl/submit-responses');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    List responses = _answers.entries.map((entry) {
      // 정규 표현식을 사용해 답변에서 숫자만 추출
      String numericAnswer = entry.value.split('.').first.trim();
      return {
        'quizId': int.parse(entry.key),
        'userAnswer': numericAnswer,
      };
    }).toList();

    // 디버깅: 요청 본문 출력
    String requestBody = json.encode({'responses': responses});
    print('요청 본문: $requestBody');
    print('토큰: ${token}');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
      body: requestBody,
    );

    // 디버깅: 응답 상태 코드 및 본문 출력

    print('응답 상태 코드: ${response.statusCode}');
    print('응답 본문: ${response.body}');

    if (response.statusCode == 200) {
      fetchUserResults(); // 사용자 결과 조회 함수 호출
    } else {
      print('답변 제출 실패: ${response.body}');
    }
  }

  void fetchUserResults() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('jwtToken');
    final username = prefs.getString('username');
    final url = Uri.parse(
        'http://34.22.80.43:8080/api/users/$userId/quiz-details-and-score');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // 결과 데이터를 사용하여 다이얼로그 내용 구성
      final quizDetails = data['quizDetails'] as List;
      final totalScore = data['totalScore'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('퀴즈 결과'),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                  '사용자: $username', // 여기에서 username을 사용
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                  Text(
                    '총점: $totalScore점',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: quizDetails.length,
                      itemBuilder: (context, index) {
                        final detail = quizDetails[index];
                        // 옵션이 있는지 확인
                        bool hasOptions = detail['options'] != null &&
                            detail['options'].isNotEmpty;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text('질문: ${detail['question']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasOptions)
                                  Text('보기: ${detail['options']}'),
                                Text('당신의 답: ${detail['userAnswer']}'),
                                Text('정답: ${detail['correctAnswer']}'),
                                detail['isCorrect']
                                    ? Text('결과: 맞았습니다. 점수: ${detail['score']}',
                                        style: TextStyle(color: Colors.green))
                                    : Text('결과: 틀렸습니다.',
                                        style: TextStyle(color: Colors.red)),
                                Text('해설: ${detail['explanation']}'),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
            ],
          );
        },
      );
    } else {
      print('결과 조회 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('탄소중립 퀴즈'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: _quizzes.length,
        itemBuilder: (context, index) {
          var quiz = _quizzes[index];
          // 옵션 처리 로직 수정
          var options = quiz['options'] is String
              ? RegExp(r'(\d+)\.\s+([^1-9]*)')
                  .allMatches(quiz['options'])
                  .map(
                      (match) => '${match.group(1)}. ${match.group(2)?.trim()}')
                  .toList()
              : [];

          bool isOptionsEmpty = options == null || options.isEmpty;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quiz['questionText'],
                      style: Theme.of(context).textTheme.headline6),
                  SizedBox(height: 8),
                  Text(
                      '난이도: ${quiz['difficulty']} - 점수: ${quiz['score']}', // 난이도와 점수 표시
                      style: Theme.of(context).textTheme.bodyText1),
                  SizedBox(height: 8), // 옵션 또는 텍스트 필드 앞에 더 많은 여백
                  if (!isOptionsEmpty) // 옵션이 있는 경우
                    Column(
                      children: List<Widget>.generate(
                        options.length,
                        (optionIndex) => ListTile(
                          title: Text(options[optionIndex]),
                          leading: Radio<String>(
                            value: options[optionIndex],
                            groupValue: _answers[quiz['id'].toString()],
                            onChanged: (value) {
                              setState(() {
                                _answers[quiz['id'].toString()] = value!;
                              });
                            },
                              activeColor: Colors.black, // 여기서 원하는 색상으로 변경하세요.

                          ),
                        ),
                      ),
                    )
                  else // 옵션이 없는 경우 주관식 답변 입력 필드를 제공
                    TextField(
                      decoration:
                          InputDecoration(hintText: 'Enter your answer here'),
                          cursorColor: Colors.black,
                      onChanged: (value) {
                        setState(() {
                          _answers[quiz['id'].toString()] = value;
                        });
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      // 하단에 버튼 두 개 배치
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // "답변 제출" 버튼
            ElevatedButton.icon(
              icon: Icon(
                Icons.check,
                color: Colors.black, // 아이콘 색상을 검은색으로 설정
              ),
              label: Text(
                '답변 제출',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15.0,
                ),
              ),
              onPressed: submitAllAnswers,
              style: ElevatedButton.styleFrom(
                primary: Colors.grey[200], // 버튼 배경 색상
              ),
            ),

            // "퀴즈 관리" 버튼, _issuperuser이 true일 때만 표시
            if (_issuperuser)
              ElevatedButton.icon(
                icon: Icon(Icons.send),
                label: Text('퀴즈 관리'),
                onPressed: _navigateToQuizManagerScreen,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // 버튼 배경 색상
                ),
              ),
          ],
        ),
      ],
    );
  }
}