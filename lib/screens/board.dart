import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greencraft/screens/board_screen.dart';
import 'package:greencraft/screens/boardcreate.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  List<dynamic> posts = []; // 게시글 목록을 저장할 리스트

  @override
  void initState() {
    super.initState();
    fetchPosts(); // 화면 로드 시 게시글 목록을 가져옵니다.
  }

  // 게시글 목록을 가져오는 함수
  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse('http://34.22.80.43:8080/boards'));

    if (response.statusCode == 200) {
      List<dynamic> fetchedPosts = json.decode(response.body);
      // 조회수(viewCount)에 따라 내림차순으로 정렬
      fetchedPosts.sort((a, b) => b['viewCount'].compareTo(a['viewCount']));
      setState(() {
        posts = fetchedPosts;
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text("게시판"),
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              child: ListTile(
                title: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style, // 기본 텍스트 스타일 적용
                    children: <TextSpan>[
                      TextSpan(
                          text: "${post['title']}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: " - 조회수: ${post['viewCount']}",
                        style: TextStyle(
                          fontWeight: FontWeight.w300, // 조회수 부분을 가벼운 글씨체로 변경
                          color: Colors.black.withOpacity(0.6), // 색상의 투명도 조절
                          fontSize: 12, // 글씨 크기를 작게 조절
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                    "글쓴이: ${post['username']}\n내용: ${post['content']}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoardDetailScreen(post: post),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BoardCreateScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: '글쓰기',
      ),
    );
  }
}
