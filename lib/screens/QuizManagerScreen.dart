import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Quiz 모델
class Quiz {
  final int id;
  final String questionText;
  final String options;
  final String correctAnswer;
  final String difficulty;
  final int score;
  final String explanation;

  Quiz({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
    required this.score,
    required this.explanation,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? 0, // int는 null이 될 수 없으므로 기본값을 0으로 설정
      questionText: json['questionText'] as String? ?? '', // null이면 빈 문자열을 기본값으로 사용
      options: json['options'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'score': score,
      'explanation': explanation,
    };
  }
}

// Quiz 서비스
class QuizService {
  final String baseUrl = 'http://34.22.80.43:8080/api/quizzes';

  Future<List<Quiz>> fetchQuizzes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Quiz> quizzes = body.map((dynamic item) => Quiz.fromJson(item)).toList();
      return quizzes;
    } else {
      throw "퀴즈를 가져올 수 없습니다.";
    }
  }

  Future<Quiz?> createQuiz(Quiz quiz) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(quiz.toJson()),
    );
    if (response.statusCode == 201) {
      return Quiz.fromJson(jsonDecode(response.body));
    } else {
      throw "퀴즈 생성에 실패했습니다.";
    }
  }

  Future<Quiz?> updateQuiz(int id, Quiz quiz) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(quiz.toJson()),
    );
    if (response.statusCode == 200) {
      return Quiz.fromJson(jsonDecode(response.body));
    } else {
      throw "퀴즈 업데이트에 실패했습니다.";
    }
  }

  Future<void> deleteQuiz(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw "퀴즈 삭제에 실패했습니다.";
    }
  }

  // 전체 삭제 기능을 추가합니다.
  Future<void> deleteAllQuizzes() async {
    final response = await http.delete(Uri.parse(baseUrl));
    if (response.statusCode != 204) {
      throw "모든 퀴즈를 삭제하는 데 실패했습니다.";
    }
  }

  // QuizService 클래스 내에 추가
Future<void> deleteAllQuizResponses() async {
  final response = await http.delete(Uri.parse('http://34.22.80.43:8080/api/quiz-responses/all'));
  if (response.statusCode != 200) {
    throw "모든 퀴즈 응답을 삭제하는 데 실패했습니다.";
  }
}
}

// Quiz 관리 화면
class QuizManagerScreen extends StatefulWidget {
  @override
  _QuizManagerScreenState createState() => _QuizManagerScreenState();
}

class _QuizManagerScreenState extends State<QuizManagerScreen> {
  late List<Quiz> quizzes = [];
  final QuizService quizService = QuizService();

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() async {
    quizzes = await quizService.fetchQuizzes();
    setState(() {});
  }

  // QuizManagerScreen 클래스 내에 추가
void _showDeleteAllQuizResponsesConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("모든 퀴즈 응답 삭제"),
        content: Text("정말로 모든 퀴즈 응답을 삭제하시겠습니까?"),
        actions: <Widget>[
          TextButton(
  onPressed: () => Navigator.of(context).pop(),
  child: Text(
    "취소",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
),
TextButton(
  onPressed: () async {
    await quizService.deleteAllQuizResponses();
    Navigator.of(context).pop(); // 대화상자 닫기
  },
  child: Text(
    "삭제",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
),
        ],
      );
    },
  );
}

  void _showAddEditQuizDialog({BuildContext? context, Quiz? quiz}) {
    if (context == null) return;
    final _formKey = GlobalKey<FormState>();
    final questionTextController = TextEditingController(text: quiz?.questionText ?? '');
    final optionsController = TextEditingController(text: quiz?.options ?? '');
    final correctAnswerController = TextEditingController(text: quiz?.correctAnswer ?? '');
    final difficultyController = TextEditingController(text: quiz?.difficulty ?? '');
    final scoreController = TextEditingController(text: quiz?.score.toString() ?? '');
    final explanationController = TextEditingController(text: quiz?.explanation ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(quiz == null ? "퀴즈 추가" : "퀴즈 수정"),
          content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text("문제:")),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: questionTextController,
                        decoration: InputDecoration(hintText: "Question Text"),
                        cursorColor: Colors.black,
                        maxLines: null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '문제를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text("보기:")),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: optionsController,
                        decoration: InputDecoration(hintText: "1. apple 2. 바나나"),
                        cursorColor: Colors.black,
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text("정답:")),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: correctAnswerController,
                        decoration: InputDecoration(hintText: "Correct Answer"),
                        cursorColor: Colors.black,
                        maxLines: null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '정답을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text("난이도:")),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: difficultyController,
                        decoration: InputDecoration(hintText: "상 중 하"),
                        cursorColor: Colors.black,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '난이도를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text("점수:")),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: scoreController,
                        decoration: InputDecoration(hintText: "Score"),
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '점수를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text("해설:")),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: explanationController,
                        decoration: InputDecoration(hintText: "Explanation"),
                        cursorColor: Colors.black,
                        maxLines: null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '해설을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          actions: <Widget>[
            TextButton(
  child: Text(
    "취소",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
  onPressed: () {
    Navigator.of(context).pop();
  },
),
TextButton(
  child: Text(
    quiz == null ? "추가" : "저장",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      final Quiz newQuiz = Quiz(
        id: quiz?.id ?? 0,
        questionText: questionTextController.text,
        options: optionsController.text,
        correctAnswer: correctAnswerController.text,
        difficulty: difficultyController.text,
        score: int.tryParse(scoreController.text) ?? 0,
        explanation: explanationController.text,
      );

      if (quiz == null) {
        await quizService.createQuiz(newQuiz);
      } else {
        await quizService.updateQuiz(quiz.id, newQuiz);
      }

      Navigator.of(context).pop();
      _loadQuizzes();
    }
  },
),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int quizId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("퀴즈 삭제"),
          content: Text("이 퀴즈를 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
  onPressed: () => Navigator.of(context).pop(),
  child: Text(
    "취소",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
),
TextButton(
  onPressed: () async {
    await quizService.deleteQuiz(quizId);
    _loadQuizzes(); // 퀴즈 목록 새로고침
    Navigator.of(context).pop(); // 대화상자 닫기
  },
  child: Text(
    "삭제",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
),
          ],
        );
      },
    );
  }

  // 전체 삭제 확인 대화상자를 보여주는 함수
  void _showDeleteAllConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("모든 퀴즈 삭제"),
          content: Text("모든 퀴즈를 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
  onPressed: () => Navigator.of(context).pop(),
  child: Text(
    "취소",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
),
TextButton(
  onPressed: () async {
    await quizService.deleteAllQuizzes();
    _loadQuizzes(); // 퀴즈 목록 새로고침
    Navigator.of(context).pop(); // 대화상자 닫기
  },
  child: Text(
    "삭제",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
),
          ],
        );
      },
    );
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('퀴즈 관리'),
    ),
    body: quizzes.isEmpty
        ? Center(child: Text("퀴즈가 없습니다."))
        : ListView.builder(
  itemCount: quizzes.length,
  itemBuilder: (context, index) {
    final quiz = quizzes[index];
    return Card(
      margin: EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () {
                      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => QuizDetailScreen(
      quiz: quiz,
      onEdit: () {
        _showAddEditQuizDialog(context: context, quiz: quiz);
      },
      onDelete: () async {
        await quizService.deleteQuiz(quiz.id);
        _loadQuizzes();
        Navigator.of(context).pop(); // 상세 화면 닫기
      },
    ),
  ),
);
                    },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      quiz.questionText,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '난이도: ${quiz.difficulty}, 점수: ${quiz.score}',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmationDialog(quiz.id),
              ),
            ],
          ),
        ),
      ),
    );
  },
),
    floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showAddEditQuizDialog(context: context),
            child: Icon(Icons.add),
            tooltip: '퀴즈 추가',
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            onPressed: () => _showDeleteAllConfirmationDialog(),
            child: Icon(Icons.delete_sweep),
            tooltip: '모든 퀴즈 삭제',
            backgroundColor: Colors.red,
          ),
           SizedBox(height: 20),
    FloatingActionButton(
      onPressed: _showDeleteAllQuizResponsesConfirmationDialog,
      child: Icon(Icons.delete_forever),
      tooltip: '모든 퀴즈 응답 삭제',
      backgroundColor: Colors.redAccent,
    ),
        ],
      ),
  );
}
}
// 퀴즈 상세 화면
class QuizDetailScreen extends StatelessWidget {
  final Quiz quiz;
  final Function onEdit;
  final Function onDelete;

  QuizDetailScreen({Key? key, required this.quiz, required this.onEdit, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈 상세'),
        backgroundColor: Colors.deepPurple, // 앱 바 색상 변경
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.yellow),
            onPressed: () => onEdit(),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("퀴즈 삭제"),
                  content: Text("이 퀴즈를 삭제하시겠습니까?"),
                  actions: <Widget>[
                    TextButton(
  onPressed: () => Navigator.of(context).pop(),
  child: Text(
    "취소",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
),
TextButton(
  onPressed: () {
    onDelete();
    Navigator.of(context).pop();
  },
  child: Text(
    "삭제",
    style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 16.0, // 폰트 크기 설정
      fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
    ),
  ),
),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            infoSection('문제', quiz.questionText, Colors.lightBlue[50]!),
            quiz.options.isNotEmpty ? infoSection('보기', quiz.options, Colors.green[50]!) : Container(),
            infoSection('정답', quiz.correctAnswer, Colors.yellow[50]!),
            infoSection('난이도', quiz.difficulty, Colors.orange[50]!),
            infoSection('점수', quiz.score.toString(), Colors.red[50]!),
            infoSection('해설', quiz.explanation, Colors.purple[50]!),
          ],
        ),
      ),
    );
  }

  Widget infoSection(String title, String content, Color color) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 18, color: Colors.black)),
        ],
      ),
    );
  }
}

