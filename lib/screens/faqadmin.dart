import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 변환을 위한 패키지
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>(); // 폼의 상태를 추적하는 키
  String? _question; // FAQ 질문
  String? _answer; // FAQ 답변

  List<Map<String, dynamic>> _faqList = []; // FAQ 목록을 저장할 리스트

  // 페이지가 로드될 때 FAQ 목록을 불러오는 함수
  @override
  void initState() {
    super.initState();
    _fetchFaqList();
  }

  // 서버에서 FAQ 목록을 가져오는 함수
  Future<void> _fetchFaqList() async {
  final url = 'http://34.22.80.43:8080/api/faq'; // 서버 API URL
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _faqList = data.map((item) => item as Map<String, dynamic>).toList();
        // 'no' 필드를 기준으로 오름차순 정렬
        _faqList.sort((a, b) => a['no'].compareTo(b['no']));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch FAQ list')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  // FAQ를 추가하고 서버에 저장하는 함수
Future<void> _addFaq() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    final url = 'http://34.22.80.43:8080/api/faq'; // 서버 API URL
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': _question, 'answer': _answer}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FAQ added successfully')),
        );
        _fetchFaqList();
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add FAQ')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
  void _editFaq(int index) async {
    Map<String, dynamic> selectedFaq = _faqList[index];
    _question = selectedFaq['question'];
    _answer = selectedFaq['answer'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit FAQ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
  initialValue: _question,
  onChanged: (value) {
  print("Question updated: $value");
  _question = value;
},
  decoration: InputDecoration(labelText: 'Question'),
  cursorColor: Colors.black,
),
TextFormField(
  initialValue: _answer,
  onChanged: (value) {
    print("answer updated: $value");
    _answer = value;
  },
  decoration: InputDecoration(labelText: 'Answer'),
  cursorColor: Colors.black,
),
            ],
          ),
          actions: [
            TextButton(
  onPressed: () {
    print("Update button pressed");
    _updateFaq(index);
    Navigator.of(context).pop();
  },
  style: TextButton.styleFrom(
    primary: Colors.black, // 텍스트 색상을 검정색으로 설정합니다.
  ),
  child: Text('Update'),
),
          
            TextButton(
  onPressed: () {
    _deleteFaq(index);
    Navigator.of(context).pop();
  },
  style: TextButton.styleFrom(
    primary: Colors.black, // 이 속성은 텍스트 색상을 설정합니다.
  ),
  child: Text('Delete'),
),
TextButton(
  onPressed: () => Navigator.of(context).pop(),
  style: TextButton.styleFrom(
    primary: Colors.black, // 이 속성은 텍스트 색상을 설정합니다.
  ),
  child: Text('Cancel'),
),
          ],
        );
      },
    );
  }

  Future<void> _updateFaq(int index) async {
  final url = 'http://34.22.80.43:8080/api/faq/${_faqList[index]['no']}';
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': _question, 'answer': _answer}),
    );
    // 서버 응답 로그 출력
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FAQ updated successfully')),
      );
      _fetchFaqList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update FAQ')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
Future<void> _deleteFaq(int index) async {
  final url = 'http://34.22.80.43:8080/api/faq/${_faqList[index]['no']}';
  try {
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FAQ deleted successfully')),
      );
      _fetchFaqList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete FAQ')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Question'),
                      cursorColor: Colors.black,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a question';
                        }
                        return null;
                      },
                      onSaved: (value) => _question = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Answer'),
                      cursorColor: Colors.black,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an answer';
                        }
                        return null;
                      },
                      onSaved: (value) => _answer = value,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
  onPressed: _addFaq,
  style: ElevatedButton.styleFrom(
    primary: Colors.white, // 여기에서 버튼의 배경색을 검정색으로 설정합니다.
    onPrimary: Colors.black, // 여기에서 버튼의 텍스트 색상을 흰색으로 설정합니다.
  ),
  child: Text('Add FAQ'),
),
                    ),
                  ],
                ),
              ),
              // FAQ 목록 출력
              SizedBox(height: 20),
              Text(
                'FAQ List',
                style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.w600,),
              ),
              SizedBox(height: 10),
              ListView.builder(
  physics: NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  itemCount: _faqList.length,
  itemBuilder: (context, index) {
    String faqTitle = "${_faqList[index]['no']}번 - ${_faqList[index]['question']}";
    return Card( // Card 위젯으로 감쌉니다.
      elevation: 4.0, // 카드의 그림자 깊이를 설정합니다.
      margin: EdgeInsets.symmetric(vertical: 8.0), // 카드 사이의 간격을 설정합니다.
      child: ListTile(
        title: Text(faqTitle),
        subtitle: Text(_faqList[index]['answer'] ?? ''),
        onTap: () => _editFaq(index),
      ),
    );
  },
),
            ],
          ),
        ),
      ),
    );
  }
}