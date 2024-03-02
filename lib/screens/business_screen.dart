import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginInfo(String userid, String managercode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userid', userid);
  await prefs.setString('managercode', managercode);
}

Future<DateTime?> selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(), // 초기 날짜 설정
    firstDate: DateTime(2000), // 시작 날짜
    lastDate: DateTime(2025), // 마지막 날짜
    cancelText: "취소", // 취소 버튼 텍스트 변경
    confirmText: "확인", // 확인 버튼 텍스트 변경
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Color(0xFF7ed957),
          // 이 부분에서 버튼 색상을 조정합니다.
          colorScheme: ColorScheme.light(
            primary: Colors.blue, // '확인' 버튼 색상
            onPrimary: Colors.black, // '확인' 버튼의 텍스트 색상
            secondary: Colors.red, // '취소' 버튼 색상
            onSecondary: Colors.black, // '취소' 버튼의 텍스트 색상
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              // 이 부분에서 '확인' 버튼의 스타일을 지정합니다.
              primary: Colors.black, // 텍스트 색상
            ),
          ),
        ),
        child: child!,
      );
    },
  );
  return picked;
}

class DateSelectionPage extends StatefulWidget {
  @override
  _DateSelectionPageState createState() => _DateSelectionPageState();
}

class _DateSelectionPageState extends State<DateSelectionPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? lastSavedId; // 마지막으로 저장된 데이터의 ID를 저장할 변수
  Map<String, dynamic>? lastSavedData; // 마지막으로 저장된 데이터를 저장할 변수
  double totalGas = 0.0;
  double totalCarbon = 0.0;

  Future<void> sendCarbonTaxRequest() async {
    if (_startDate != null && _endDate != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userIdStr = prefs.getString('userId');
      String? managercode = prefs.getString('managercode');

      if (userIdStr == null || managercode == null) {
        print('User ID or Manager Code not found in SharedPreferences');
        return;
      }

      int userId = int.tryParse(userIdStr) ?? 0;
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate!);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(_endDate!);

      var uri = Uri.parse('http://34.22.80.43:8000/manmodels/');
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json;charset=utf-8'},
        body: json.encode({
          'username': userId,
          'managercode': managercode,
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);
        setState(() {
          lastSavedId = data['id'].toString();
          // 서버로부터 받은 문자열을 double로 변환
          totalGas =
              num.tryParse(data['total_gas'].toString())?.toDouble() ?? 0.0;
          totalCarbon =
              num.tryParse(data['total_carbon'].toString())?.toDouble() ?? 0.0;

          // lastSavedData 업데이트
          lastSavedData = {
            'total_gas': totalGas, // 여기서는 변환된 값을 사용합니다.
            'total_carbon': totalCarbon, // 마찬가지로 변환된 값을 사용합니다.
          };
        });
        // 이 부분에서는 fetchLastSavedData를 호출할 필요가 없을 수 있습니다.
        // fetchLastSavedData(context, id); // 이 줄은 필요 없을 수 있습니다.
      } else {
        print(
            'Failed to fetch carbon tax data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Received id: ${lastSavedId}'); // 콘솔에 ID 출력
      }
    }
  }

  // void _onFetchAndDisplayPressed() {
  //   if (lastSavedId != null) {
  //     fetchLastSavedData(context, lastSavedId!);
  //   } else {
  //     // ID가 없을 때의 처리
  //     print('No ID available to fetch data.'); // 콘솔에 오류 메시지 출력
  //   }
  // } // 없어도 되는 함수로 보임 추후 삭제예정

  Future<void> fetchLastSavedData(BuildContext context, String id) async {
    var uri = Uri.parse('http://34.22.80.43:8000/manmodels/$id');
    var response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        lastSavedData = data; // 상태 업데이트로 데이터 저장
      });
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalGas = 0.0;
    double totalCarbon = 0.0;

    // lastSavedData가 null이 아닐 때 값을 할당합니다.
    if (lastSavedData != null) {
      totalGas = (lastSavedData!['total_gas'] as num?)?.toDouble() ?? 0.0;
      totalCarbon = (lastSavedData!['total_carbon'] as num?)?.toDouble() ?? 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '탄소세 계산',
          style: TextStyle(
            color: Colors.black, // 텍스트 색상을 검정으로 설정
            fontSize: 16.0, // 폰트 크기 설정
            fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
          ),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              '시작 날짜: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : '선택되지 않음'}',
              style: TextStyle(
                color: Colors.black, // 텍스트 색상을 검정으로 설정
                fontSize: 16.0, // 폰트 크기 설정
                fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
              ),
            ),
            onTap: () async {
              DateTime? startDate = await selectDate(context);
              if (startDate != null) {
                setState(() {
                  _startDate = startDate;
                });
              }
            },
          ),
          ListTile(
            title: Text(
              '종료 날짜: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : '선택되지 않음'}',
              style: TextStyle(
                color: Colors.black, // 텍스트 색상을 검정으로 설정
                fontSize: 16.0, // 폰트 크기 설정
                fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
              ),
            ),
            onTap: () async {
              DateTime? endDate = await selectDate(context);
              if (endDate != null) {
                setState(() {
                  _endDate = endDate;
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: sendCarbonTaxRequest,
            child: Text(
              '누적 주유와 탄소세 확인',
              style: TextStyle(
                color: Colors.black, // 텍스트 색상을 검정으로 설정
                fontSize: 16.0, // 폰트 크기 설정
                fontWeight: FontWeight.bold, // 폰트 두께를 굵게 설정
              ),
            ),
          ),
          if (lastSavedData != null) ...[
            CustomSlider(
              label: '주유 리터 총량',
              value: totalGas,
              maxValue: 1000,
              onValueChanged: (newValue) {
                setState(() {
                  totalGas = newValue;
                });
              },
              isActive: lastSavedData != null,
              unit: '리터', // 단위를 '리터'로 설정
            ),
            SizedBox(height:30,),
            CustomSlider(
              label: '탄소세 총금액',
              value: totalCarbon,
              maxValue: 50000,
              onValueChanged: (newValue) {
                setState(() {
                  totalCarbon = newValue;
                });
              },
              isActive: lastSavedData != null,
              unit: '원', // 단위를 '원'으로 설정
            ),
          ] else ...[
            CustomSlider(
              label: '주유 리터 총량',
              value: totalGas,
              maxValue: 1000,
              onValueChanged: (newValue) {
                setState(() {
                  totalGas = newValue;
                });
              },
              isActive: lastSavedData != null,
              unit: '리터', // 단위를 '리터'로 설정
            ),          
             SizedBox(height:40,),

            CustomSlider(
              label: '탄소세 총금액',
              value: totalCarbon,
              maxValue: 50000,
              onValueChanged: (newValue) {
                setState(() {
                  totalCarbon = newValue;
                });
              },
              isActive: lastSavedData != null,
              unit: '원', // 단위를 '원'으로 설정
            ),
          ]
        ],
      ),
    );
  }
}

class CustomSlider extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Function(double) onValueChanged;
  final bool isActive; // 슬라이더 활성화 여부
  final String unit; // 단위를 표시하기 위한 변수 추가

  CustomSlider({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.onValueChanged,
    this.isActive = false, // 기본값은 비활성화
    required this.unit, // 단위 인자 추가
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFF7ed957),
            inactiveTrackColor: Colors.green[100],
            trackShape: CustomTrackShape(),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
            trackHeight: 6.0,
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: Color(0xFF7ed957),
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          child: Slider(
            value: isActive ? value : 0,
            min: 0,
            max: maxValue,
            divisions: maxValue.toInt(),
            label: "${value.toStringAsFixed(2)} $unit", // 단위를 라벨에 추가
            onChanged: isActive ? onValueChanged : null,
          ),
        ),
        if (isActive)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "${value.toStringAsFixed(2)} $unit", // 출력 값 뒤에 단위 추가
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ),
      ],
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx + 16.0; // 슬라이더 시작 위치 조정
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth =
        parentBox.size.width - 32.0; // 좌우 여백을 줄여 슬라이더 길이를 조정
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
