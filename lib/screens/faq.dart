import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greencraft/screens/main_screen.dart';
import 'package:greencraft/screens/faqadmin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FAQScreen(),
    );
  }
}

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<Map<String, dynamic>> faqList = [];
  bool _issuperuser = false; // 관리자 여부를 저장하는 변수

  @override
  void initState() {
    super.initState();
    _checkStaffStatus(); // 관리자 여부를 확인
    fetchData(); // FAQ 데이터 불러오기
  }
  
  void _checkStaffStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool issuperuser = prefs.getBool('issuperuser') ?? false;
    print('Is superuser: $issuperuser'); // 디버그를 위한 출력
    setState(() {
      _issuperuser = issuperuser;
    });
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://34.22.80.43:8080/api/faq'), headers: {"Content-Type": "application/json;charset=utf-8"});
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        setState(() {
          faqList = List<Map<String, dynamic>>.from(decodedData);
        });
      } else {
        print('Failed to load FAQ data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
        'FAQ',style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
    ))),
      body: faqList.isNotEmpty
          ? ListView.builder(
              itemCount: faqList.length,
              itemBuilder: (BuildContext context, int index) {
                var faq = faqList[index];
                return ExpansionTile(
                  title: Text(
                    'Q: ${faq['question']}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q: ${faq['question']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 20
                          ),
                          Text(
                            'A: ${faq['answer']}',
                            style: TextStyle(
                              fontSize: 14,
                      fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: _issuperuser ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add New FAQ',
      ) : null,
    );
  }
}