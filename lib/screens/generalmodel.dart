// 필요한 패키지 임포트
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greencraft/screens/ModelListPage.dart';

// CarImageResponse 모델
class CarImageResponse {
  // ... (이전에 정의한 CarImageResponse 모델 코드)

  final List<String> vehicleType;
  final List<String> licensePlateText;
  final String secondModelImageUrl;
  final String licensePlateImageUrl;
  final String licensePlateVehicleType;
  final String gPrint;
  final String originalImageUrl;
  final double displacement;
  final double carbon_tax;
  final double carbon_emission;
  final String class_label;

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
  });

  factory CarImageResponse.fromJson(Map<String, dynamic> json) {
  return CarImageResponse(
    vehicleType: List<String>.from(json['vehicle_type'] ?? []),
    licensePlateText: List<String>.from(json['license_plate_text'] ?? []),
    secondModelImageUrl: json['second_model_image_url'] ?? '',
    licensePlateImageUrl: json['license_plate_image_url'] ?? '',
    licensePlateVehicleType: json['LICENSE_PLATE_VEHICLE_TYPE'] ?? '',
    gPrint: json['g_print'] ?? '',
    originalImageUrl: json['original_image_url'] ?? '',
    displacement: json['displacement']?.toDouble() ?? 0.0,
    carbon_tax: json['carbon_tax']?.toDouble() ?? 0.0,
    carbon_emission: json['carbon_emission']?.toDouble() ?? 0.0,
    class_label: json['class_label'] ?? '',
  );
}
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Processor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GeneralModel(),
    );
  }
}

class GeneralModel extends StatefulWidget {
  @override
  _GeneralModelState createState() => _GeneralModelState();
}

const String serverBaseURL = 'http://34.22.80.43:8000'; // 서버 주소 변경 가능

class _GeneralModelState extends State<GeneralModel> {
  String _imageBase64 = '';
  CarImageResponse? _response;
  File? _image; // 선택한 이미지 파일을 저장할 변수
  bool _isLoading = false; // 로딩 상태를 추적하는 변수

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      const maxBytes = 17 * 1024 * 1024; // 17MB를 바이트 단위로 변환

      if (bytes.length <= maxBytes) {
        setState(() {
          _image = file; // 선택한 이미지 파일 저장
          _imageBase64 = base64Encode(bytes);
        });
        uploadImage(_imageBase64);
      } else {
        // 파일 크기가 17MB를 초과하는 경우 경고 메시지 표시
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'The file is too large. Please select a file smaller than 17MB.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                ),
              ],
            );
          },
        );
        print('The file is too large. Please select a file smaller than 17MB.');
      }
    } else {
      print('No image selected.');
    }
  }

// 서버와 통신하는 기능
  Future<void> uploadImage(String base64Image) async {
    setState(() {
      _isLoading = true; // 요청 전에 로딩 상태를 true로 설정
    });
    var url = Uri.parse('http://34.22.80.43:8000/api/process-image/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken'); // 저장된 토큰을 불러옵니다.

    if (token == null) {
      setState(() {
      _isLoading = false; // 로딩 상태 업데이트
    });
      print('토큰이 존재하지 않습니다.');
      return;
    }
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        }, // JWT 토큰을 사용하여 인증 헤더를 추가합니다.},
        body: json.encode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        var decodedResponse = utf8.decode(response.bodyBytes);
        setState(() {
          _response = CarImageResponse.fromJson(json.decode(decodedResponse));
          _isLoading = false; // 응답을 받으면 로딩 상태를 false로 설정
        });
        print('받아온값: ${decodedResponse}');
      } else {
        setState(() {
          _isLoading = false; // 오류 발생 시에도 로딩 상태를 false로 설정
        });
        print('Server error: ${response.body}');
      }
    } catch (e) {
      setState(() {
      _isLoading = false;
    });
      print('Error occurred: $e');
    }
  }

  String getImageUrl(String relativePath) {
    return serverBaseURL + relativePath;
  }

// UI 위젯
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 화면의 너비를 가져옵니다.

    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload & Processing'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: screenWidth,
                  child: _image != null
                      ? Image.file(
                          _image!,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          'assets/upload.png',
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              SizedBox(height: 20),
              if (_isLoading)
                Center(
                    child: CircularProgressIndicator(color: Color(0xFF7ed957))),
              if (_response != null) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Image.network(
                                  getImageUrl(_response!.secondModelImageUrl))),
                          SizedBox(height: 10),
                          Center(
                              child: Image.network(getImageUrl(
                                  _response!.licensePlateImageUrl))),
                          SizedBox(height: 10),
                          informationCard(
                              '번호판 인식 차종', _response!.licensePlateVehicleType),
                          informationCard(
                              '배기량', _response!.displacement.toString()),
                          informationCard(
                              '탄소세 백분율', _response!.carbon_tax.toString()),
                          informationCard(
                              '탄소 배출량', _response!.carbon_emission.toString()),
                          informationCard('GPT의 탄소중립방안', _response!.gPrint),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0), // Adjust the left padding as needed
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(' Model List Data',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold)), // 목록 제목
                      ElevatedButton(
                        onPressed: () {
                          // ModelListPage로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ModelListPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5, // 버튼의 그림자 강도 설정
                          shape: RoundedRectangleBorder(
                            // 버튼의 모양을 둥근 모서리 직사각형으로 설정
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                color: Colors.black, width: 2), // 테두리를 검정색으로 설정
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.grey, // 기본 텍스트 색상
                            ),
                            children: <TextSpan>[
                              TextSpan(text: 'Go to Model List Page : '),
                              TextSpan(
                                text: '목록',
                                style: TextStyle(
                                    color: Colors.black), // '목록'에 대한 스타일
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
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