import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  String _imageUrl = 'http://34.22.80.43:8000/api/image-with-text/'; // 이미지 URL을 저장할 변수

  // 서버로부터 이미지 URL을 가져오는 함수
  Future<void> fetchImageUrl() async {
    var uri = Uri.parse('http://34.22.80.43:8000/api/image-with-text/'); // 이미지 URL을 제공하는 서버의 API 주소
    var response = await http.get(uri); // HTTP GET 요청을 보냄

    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      
      setState(() {
        _imageUrl = decoded['imageUrl']; // 서버로부터 받은 이미지 URL을 저장
      });
    } else {
      setState(() {
        _imageUrl = ''; // 실패 시 URL을 빈 문자열로 설정
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchImageUrl(); // 위젯 초기화 시 이미지 URL 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('서버에서 이미지 가져오기'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        // 이미지 URL이 있으면 이미지를 표시하고, 없으면 로딩 인디케이터를 표시
        child: _imageUrl.isNotEmpty
            ? Image.network(_imageUrl)
            : CircularProgressIndicator(),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ImageScreen(),
  ));
}
