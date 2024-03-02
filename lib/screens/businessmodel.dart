import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greencraft/screens/business_screen.dart';
import 'package:greencraft/screens/charts.dart';

class ImageWithText {
  final String carImg;
  final String bunhoImg;
  final String managercode;
  final String bunhoClass;
  final String bunhoText;
  final String carClass;
  final String date;
  final String refuelAmount;
  final String fuelConsumed;
  final String carbonTax;

  ImageWithText({
    required this.carImg,
    required this.bunhoImg,
    required this.managercode,
    required this.bunhoClass,
    required this.bunhoText,
    required this.carClass,
    required this.date,
    required this.refuelAmount,
    required this.fuelConsumed,
    required this.carbonTax,
  });

  factory ImageWithText.fromJson(Map<String, dynamic> json) {
    return ImageWithText(
      carImg: json['car_img'] ?? '',
      bunhoImg: json['bunho_img'] ?? '',
      bunhoClass: json['bunho_class'] ?? '',
      bunhoText: json['bunho_text'] ?? '',
      carClass: json['car_class'] ?? '',
      date: json['date'] ?? '',
      managercode: json['managercode'].toString(),
      refuelAmount: json['refuel_amount']?.toString() ?? '0',
      fuelConsumed: json['fuel_consumed']?.toString() ?? '0.00',
      carbonTax: json['carbon_tax']?.toString() ?? '0.00',
    );
  }
}

Map<String, List<ImageWithText>> groupImagesByDate(List<ImageWithText> images) {
  Map<String, List<ImageWithText>> grouped = {};
  for (var image in images) {
    String formattedDate =
        DateFormat('yyyy-MM-dd').format(DateTime.parse(image.date));
    if (!grouped.containsKey(formattedDate)) {
      grouped[formattedDate] = [];
    }
    grouped[formattedDate]!.add(image);
  }
  return grouped;
}

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  List<ImageWithText> _imagesWithText = [];
  String managercode = '';
  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    // 원하는 형식으로 날짜 및 시간을 포매팅합니다.
    return DateFormat('yyyy년 MM월 dd일 HH시 mm분 ss초').format(dateTime);
  }

  bool _comcode = false; // Add a new variable to keep track of the user's role

  @override
  void initState() {
    super.initState();
    _checkIfUserIsStaff(); // initState에서 데이터를 가져오는 함수 호출
  }

  void _checkIfUserIsStaff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('managercode') ?? ''; // 'managercode' 값을 가져옴

    print("Stored managercode: $code");
  setState(() {
    managercode = code; // 클래스의 상태 변수를 업데이트합니다.
    _comcode = prefs.getBool('comcode') ?? false;
    if (_comcode) {
      fetchImagesWithText(managercode); // 여기에서 managercode를 인자로 전달
    }
  });
}

  Future<void> fetchImagesWithText(String managercode) async {
    var uri = Uri.parse(
        'http://34.22.80.43:8000/api/image-with-text/?managercode=$managercode');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);

      // managercode와 일치하는 데이터만 필터링
      List<dynamic> filteredData = data
          .where((item) => item['managercode'].toString() == managercode)
          .toList();

      if (filteredData.isNotEmpty) {
        // 날짜 기준으로 데이터 정렬 (내림차순)
        filteredData.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date']);
          DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA); // 최신 날짜가 먼저 오도록 정렬
        });

        // 가장 최신 데이터 추출
        var latestData = filteredData.first;

        // 최신 데이터를 ImageWithText 객체로 변환
        ImageWithText latestImageWithText = ImageWithText.fromJson(latestData);

        // 최신 데이터만 상태에 설정
        setState(() {
          _imagesWithText = [latestImageWithText];
        });
      } else {
        // 일치하는 데이터가 없는 경우 상태 초기화
        setState(() {
          _imagesWithText = [];
        });
      }
    } else {
      // 요청 실패 시 상태 초기화
      setState(() {
        _imagesWithText = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   
    Map<String, List<ImageWithText>> groupedImages =
        groupImagesByDate(_imagesWithText);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _comcode // _comcode 상태 변수를 확인합니다.
          ? Text('안녕하세요 $managercode 회원님 !', // _comcode가 true면 사업자 코드를 표시합니다.
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ))
        : Text('Business Service',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
            )),
        backgroundColor: Colors.white,
      ),
      body: _imagesWithText.isNotEmpty
        ? ListView.builder(
            itemCount: _imagesWithText.length,
            padding: EdgeInsets.only(top: 0 , bottom:80), // 상단 여백을 10으로 설정
            itemBuilder: (context, index) {
              var image = _imagesWithText[index];
              return Card(
                margin: EdgeInsets.all(20),
                elevation: 20,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.all(13),
                  child: Column(
                    children: [
                      Text('차량 주유 현황', style: Theme.of(context).textTheme.headline6),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailItem(context, '금액', image.refuelAmount),
                          _buildDetailItem(context, '리터', image.fuelConsumed),
                          _buildDetailItem(context, '탄소세', image.carbonTax),
                        ],
                      ),
                        SizedBox(height: 20),
                Image.network(image.carImg, fit: BoxFit.cover),
                SizedBox(height: 20),
                // 차종을 표시하는 타원형 위젯
                buildItemWithLine(context, '차종', image.carClass),
                SizedBox(height: 10), // 차종과 번호 사이의 간격
                // 번호를 표시하는 타원형 위젯
                buildItemWithLine(context, '번호', image.bunhoText),
                SizedBox(height: 10), // 번호와 날짜 사이의 간격
                // 날짜를 표시하는 타원형 위젯
                buildItemWithLine(context, '날짜', formatDateTime(image.date)),
              ],
            ),
          ),
        );
      },
    )
  : Center(
      child: Text('No data available', style: TextStyle(fontSize: 18)),
    ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // Align buttons to the end (right side)
          mainAxisSize:
              MainAxisSize.min, // Minimize the row size to fit the content
          children: [
            SizedBox(width: 8), // Provide some spacing between the buttons
            // First button, now positioned second
            ButtonTheme(
              minWidth: 160.0, // Ensure the same size for this button
              height: 36.0, // Ensure the same size for this button
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DateSelectionPage()),
                  );
                },
                child: Text('누적 탄소세 확인하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  elevation: 5, // 버튼의 그림자 강도 설정
                  shape: RoundedRectangleBorder(
                    // 버튼의 모양을 둥근 모서리 직사각형으로 설정
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                        color: Colors.black, width: 2), // 테두리를 검정색으로 설정
                  ),
                ),
              ),
            ),
            
            
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailItem(BuildContext context, String label, String value) {
  return Column(
    children: [
      SizedBox(height: 0),
      Container(
        width: 100,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.green, // 테두리 색상
            width: 2, // 테두리 두께
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
            ),
          ],
        ),
      ),
      SizedBox(height: 5), // 금액과 구분선 사이의 공간
    ],
  );
}

Widget buildItemWithLine(BuildContext context, String label, String value) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
        children: [
          Text(
            "$label  :   $value", // 라벨과 값 표시
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 14, // 폰트 크기를 14로 설정
            ),
          ),
        ],
      ),
      SizedBox(height: 8), // 텍스트와 구분선 사이의 간격
      Container(
        height: 2, // 구분선 높이
        width: 280, // 구분선 너비를 최대로 설정
        color: Colors.green, // 구분선 색상 설정
      ),
      SizedBox(height: 8), // 구분선과 다음 텍스트 사이의 간격
    ],
  );
}

void main() {
  runApp(MaterialApp(
    home: ImageScreen(),
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}