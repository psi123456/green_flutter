import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CarImageResponse 모델
class CarImageResponse {
  final String? vehicleType;
  final String? licensePlateText;
  final String? secondModelImageUrl;
  final String? licensePlateImageUrl;
  final String? licensePlateVehicleType;
  final String? gPrint;
  final String originalImageUrl;
  final double? displacement;
  final double? carbon_tax;
  final double? carbon_emission;
  final String? class_label;
  final String username; // 추가: 사용자 이름
  final int id; // 추가: 사용자 이름


  CarImageResponse({
    required this.vehicleType,
    required this.licensePlateText,
    required this.secondModelImageUrl,
    required this.licensePlateImageUrl,
    required this.licensePlateVehicleType,
    required this.gPrint,
    required this.originalImageUrl,
    required this.displacement,
    required this.carbon_tax,
    required this.carbon_emission,
    required this.class_label,
    required this.username, // 초기화
    required this.id
  });

  factory CarImageResponse.fromJson(Map<String, dynamic> json) {
    return CarImageResponse(
      vehicleType: json['vehicle_type'],
      licensePlateText: json['license_plate_text'],
      secondModelImageUrl: json['second_model_image_url'],
      licensePlateImageUrl: json['license_plate_image_url'],
      licensePlateVehicleType: json['LICENSE_PLATE_VEHICLE_TYPE'],
      gPrint: json['g_print'],
      originalImageUrl: json['original_image_url'],
      displacement: json['displacement'], // 수정: JSON 값이 정수로 오는 경우가 있어서 toDouble 처리
      carbon_tax: json['carbon_tax'],
      carbon_emission: json['carbon_emission'],
      class_label: json['class_label'],
      username: json['username'], // JSON 응답에 username 포함되어야 함
      id: json['id'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Processor',
      home: ModelListPage(), // 변경: 사용자 이미지 목록 화면으로 시작
    );
  }
}



// 사용자 이미지 목록 화면
class ModelListPage extends StatefulWidget {
  @override
  _ModelListPageState createState() => _ModelListPageState();
}
const String serverBaseURL = 'http://34.22.80.43:8000'; // 서버 주소 변경 가능

class _ModelListPageState extends State<ModelListPage> {
  Future<List<CarImageResponse>> fetchUserImages() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwtToken');

  if (token == null) {
    print('토큰이 존재하지 않습니다.');
    return []; // 토큰이 없으면 빈 리스트 반환
  }

  var url = Uri.parse('$serverBaseURL/api/process-image2/');
  try {
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((data) => CarImageResponse.fromJson(data)).toList();
    } else {
      print('Server error: ${response.statusCode}');
      return []; // 서버 에러 발생 시 빈 리스트 반환
    }
  } catch (e) {
    print('Error occurred: $e');
    return []; // 예외 발생 시 빈 리스트 반환
  }
}

  Future<void> deleteImage(int imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print('토큰이 존재하지 않습니다.');
      return;
    }

    var url = Uri.parse('$serverBaseURL/api/process-image3/$imageId/');
    try {
      var response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        print('이미지 삭제 성공');
        // 이미지 삭제 후 화면 갱신
        setState(() {});
      } else {
        print('서버 에러: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text('Your Processed Images'),
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<List<CarImageResponse>>(
        future: fetchUserImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
            } else if (snapshot.data!.isEmpty) {
          // When the list is empty, display the welcoming message image
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/usemodel.webp'), // Update with your local image path
                ],
              ),
            ),
          );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                CarImageResponse image = snapshot.data![index];
                return ListTile(
                  title: Text('객체탐지된 차종: ${image.vehicleType}'),
                  subtitle: Text('번호판: ${image.licensePlateText} by ${image.username}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Delete Image',
              style: TextStyle(
                color: Colors.black, // 텍스트 색상을 검정으로 설정
                fontSize: 16.0, // 폰트 크기 설정
                fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
              ),
            ),
            content: Text('정말 삭제하시겠습니까?'),
            actions: <Widget>[
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
              TextButton(
  onPressed: () {
    Navigator.of(context).pop();
    deleteImage(image.id);
  },
  child: Text(
    '삭제',
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
                      
                    },
                  ),
                  // ModelListPage 클래스 내부의 onTap 수정
onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ImageDetailScreen(imageResponse: image),
    ),
  );

  // 삭제 성공 시 목록 새로고침
  if (result == 'deleted') {
    setState(() {
      fetchUserImages(); // 이미지 목록을 새로고침하는 함수 호출
    });
  }
},
                );
              },
            );
          }
        },
      ),
    );
  }
}

Widget informationCard(String title, String value) {
  return Card(
    elevation: 4.0,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 14),
      ),
    ),
  );
}

// 이미지 상세 정보 화면
class ImageDetailScreen extends StatelessWidget {
  final CarImageResponse imageResponse;

  ImageDetailScreen({required this.imageResponse});
  
  Future<void> deleteImage(BuildContext context, int imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print('토큰이 존재하지 않습니다.');
      return;
    }

    var url = Uri.parse('$serverBaseURL/api/process-image3/$imageId/');
    try {
      var response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        print('이미지 삭제 성공');
        Navigator.pop(context, 'deleted'); // 상세 페이지 닫기
      } else {
        print('서버 에러: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Delete Image',
              style: TextStyle(
                color: Colors.black, // 텍스트 색상을 검정으로 설정
                fontSize: 16.0, // 폰트 크기 설정
                fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
              ),
            ),
            content: Text('정말 삭제하시겠습니까?'),
            actions: <Widget>[
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
              TextButton(
  onPressed: () {
    Navigator.of(context).pop();
    deleteImage(context, imageResponse.id);
  },
  child: Text(
    '삭제',
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
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: <Widget>[
        // 원본 이미지 표시
        Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(imageResponse.originalImageUrl),
          ),
        ),
        SizedBox(height: 10),
        // 두 번째 모델 이미지 URL
        Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(imageResponse.secondModelImageUrl ?? 'http://34.22.80.43:8000/media/license_plate_images/license_plate_image_CqsX5tJ.png'),
          ),
        ),
        SizedBox(height: 10),
        // 번호판 이미지 URL
        Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(imageResponse.licensePlateImageUrl ?? 'http://34.22.80.43:8000/media/license_plate_images/license_plate_image_CqsX5tJ.png'),
          ),
        ),
        SizedBox(height: 10),
        // 정보 카드
        informationCard('객체탐지 인식 차종', imageResponse.vehicleType ?? "N/A"),
        informationCard('번호판 인식 Text', imageResponse.licensePlateText ?? "N/A"),
        informationCard('번호판 인식 차종', imageResponse.licensePlateVehicleType ?? "N/A"),
        informationCard('배기량 ', imageResponse.displacement?.toString() ?? "N/A"),
        informationCard('탄소세', imageResponse.carbon_tax?.toString() ?? "N/A"),
        informationCard('탄소배출량', imageResponse.carbon_emission?.toString() ?? "N/A"),
        informationCard('구분된 클래스', imageResponse.class_label ?? "N/A"),
        // G-Print 정보 카드
          informationCard('GPT서비스', imageResponse.gPrint ?? "N/A"),
          SizedBox(height: 20),
      ],
    ),
  ),
),


    );
  }
}