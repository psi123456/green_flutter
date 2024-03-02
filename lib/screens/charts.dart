import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PieModel {
  final int count;
  final Color color;

  PieModel({
    required this.count,
    required this.color,
  });
}

// 차량 분류별 카운트를 위한 함수
Map<String, int> countVehiclesByCategory(List<dynamic> data) {
  Map<String, int> categoryCounts = {
    '경차': 0,
    '승용차': 0,
    '화물차': 0,
    '승합차': 0,
    '건설차량': 0,
  };

  for (var item in data) {
    int carCode = item['carcode'] ?? 0; // carcode가 null일 경우 기본값으로 0을 사용
    switch (carCode) {
      case 0:
      case 1:
        categoryCounts['경차'] =
            (categoryCounts['경차'] ?? 0) + 1; // null 체크 후 기본값 0을 사용하고, 값을 1 증가
        break;
      case 2:
      case 3:
        categoryCounts['승용차'] = (categoryCounts['승용차'] ?? 0) + 1;
        break;
      case 4:
        categoryCounts['화물차'] = (categoryCounts['화물차'] ?? 0) + 1;
        break;
      case 5:
        categoryCounts['승합차'] = (categoryCounts['승합차'] ?? 0) + 1;
        break;
      case 6:
        categoryCounts['건설차량'] = (categoryCounts['건설차량'] ?? 0) + 1;
        break;
    }
  }

  return categoryCounts;
}

// 서버로부터 데이터를 가져오고 그래프 데이터 생성
Future<List<PieModel>> fetchAndCountVehicles(String managercode) async {
  var uri = Uri.parse(
      'http://34.22.80.43:8000/api/image-with-text/?managercode=$managercode');
  var response = await http.get(uri);
  print("managerCode 값: $managercode");

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    Map<String, int> vehicleCounts = countVehiclesByCategory(data);

    // 차트에 사용될 PieModel 리스트 생성
    List<PieModel> pieData = vehicleCounts.entries.map((entry) {
      return PieModel(
          count: entry.value, color: _getColorForCategory(entry.key));
    }).toList();

    return pieData;
  } else {
    throw Exception('Failed to load vehicle data');
  }
}

// 카테고리별 색상 지정
Color _getColorForCategory(String category) {
  switch (category) {
    case '경차':
      return Color(0xFF445C4C);
    case '승용차':
      return Color(0xFF508068);
    case '화물차':
      return Color(0xFF8AB6A9);
    case '승합차':
      return Color(0xFFD6E2E0);
    case '건설차량':
      return Color(0xFFBFC9CA);
    default:
      return Colors.black;
  }
}

class LegendWidget extends StatelessWidget {
  final Map<String, Color> categoryColorMap;

  const LegendWidget({
    Key? key,
    required this.categoryColorMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16.0), // 왼쪽 패딩을 줘서 오른쪽으로 이동
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 항목들을 왼쪽 정렬
        children: categoryColorMap.entries.map((entry) {
          return Row(
            children: <Widget>[
              Container(
                width: 24,
                height: 24,
                color: entry.value,
              ),
              SizedBox(width: 8), // 아이콘과 텍스트 사이의 공간
              Text(entry.key),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class PainterAnimationPieChartScreen extends StatefulWidget {
  const PainterAnimationPieChartScreen({Key? key}) : super(key: key);

  @override
  State<PainterAnimationPieChartScreen> createState() =>
      _PainterAnimationPieChartScreenState();
}

class _PainterAnimationPieChartScreenState
    extends State<PainterAnimationPieChartScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late List<PieModel> model = []; // 초기 모델을 빈 리스트로 설정
  String managerCode = ''; // managerCode 상태 변수

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animationController.forward();
    _loadManagerCode();

    // 서버로부터 데이터를 가져와서 모델 업데이트
    fetchAndCountVehicles("your_manager_code_here").then((pieData) {
      setState(() {
        model = pieData;
      });
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  Future<void> _loadManagerCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString('managercode'); // managercode를 불러옵니다.
    if (code != null) {
      if (mounted) {
        setState(() {
          managerCode = code; // 상태 변수에 저장
        });
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text(managerCode.isNotEmpty ? "$managerCode 님, 환영합니다!" : "차트 페이지"),
      ),
      body: SingleChildScrollView(
        // 스크롤 가능한 뷰 추가
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                elevation: 4.0, // 카드에 그림자를 줍니다.
                color: Colors.white, // 카드 배경색을 흰색으로 설정
                child: Padding(
                  padding: EdgeInsets.all(16.0), // 카드 내부 패딩
                  child: Column(
                    children: [
                      Text(
                        '차종의 비중 원형 그래프',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          if (animationController.value < 0.1 ||
                              model.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return CustomPaint(
                            size: Size(MediaQuery.of(context).size.width,
                                MediaQuery.of(context).size.width),
                            painter:
                                _PieChart(model, animationController.value),
                          );
                        },
                      ),
                      SizedBox(height: 1), // 그래프와 범례 사이의 공간
                      LegendWidget(
                        categoryColorMap: {
                          '경차': Color(0xFF445C4C),
                          '승용차': Color(0xFF508068),
                          '화물차': Color(0xFF8AB6A9),
                          '승합차': Color(0xFFD6E2E0),
                          '건설차량': Color(0xFFBFC9CA),
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4.0,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('차종별 수량 막대 그래프',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      SizedBox(
                        child: FutureBuilder<List<BarModel>>(
                          future: fetchAndCountVehiclesForBarChart(
                              "your_manager_code_here"),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return buildBarChart(snapshot.data!);
                              } else {
                                return Text('데이터를 불러오는데 실패했습니다.');
                              }
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // 범례 위젯을 추가할 수 있습니다.
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    // Column 위젯 추가
                    crossAxisAlignment: CrossAxisAlignment.start, // 내부 항목 왼쪽 정렬
                    children: [
                      Text('일별 주유리터 합계 곡선 그래프',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)), // 제목 추가
                      SizedBox(height: 16), // 제목과 차트 사이의 여백 추가
                      FutureBuilder<Map<DateTime, double>>(
                        future: fetchAndProcessData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 300.0,
                                child: FuelConsumedLineChart(
                                    fuelConsumedData: snapshot.data!),
                              );
                            } else {
                              return Text('데이터를 불러오는데 실패했습니다.');
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieChart extends CustomPainter {
  final List<PieModel> data;
  final double value;

  _PieChart(this.data, this.value);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = (size.width / 2) * 0.8;
    double total = data.fold(0, (sum, item) => sum + item.count);
    double _startPoint = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final currentData = data[i];
      double _count = currentData.count.toDouble();
      double sweepAngle = (2 * math.pi * (_count / total)) * value;

      Path path = Path()
        ..moveTo(size.width / 2, size.width / 2)
        ..arcTo(
          Rect.fromCircle(
              center: Offset(size.width / 2, size.width / 2), radius: radius),
          _startPoint,
          sweepAngle,
          false,
        )
        ..close();

      // 카테고리별 색상 적용
      Paint paint = Paint()..color = currentData.color;

      // 그림자 그리기
      canvas.drawShadow(path, Colors.black, 3.0, false);

      // 섹션 그리기
      canvas.drawPath(path, paint);

      _startPoint += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// PieModel과 비슷한 구조를 가진 BarModel 클래스를 정의합니다.
class BarModel {
  final String category;
  final int count;
  final Color color;

  BarModel({required this.category, required this.count, required this.color});
}

// 서버로부터 데이터를 가져와서 막대 그래프 데이터를 생성하는 함수
Future<List<BarModel>> fetchAndCountVehiclesForBarChart(
    String managercode) async {
  var uri = Uri.parse(
      'http://34.22.80.43:8000/api/image-with-text/?managercode=$managercode');
  var response = await http.get(uri);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    Map<String, int> vehicleCounts = countVehiclesByCategory(data);

    // 차트에 사용될 BarModel 리스트 생성
    List<BarModel> barData = vehicleCounts.entries.map((entry) {
      return BarModel(
          category: entry.key,
          count: entry.value,
          color: _getColorForCategory(entry.key));
    }).toList();

    return barData;
  } else {
    // 여기서 예외를 발생시키거나 빈 리스트를 반환할 수 있습니다.
    throw Exception('Failed to load vehicle data');
    // 또는
    // return <BarModel>[];
  }
}

// 막대 그래프를 생성하는 위젯
Widget buildBarChart(List<BarModel> barData) {
  // 차트에 사용될 시리즈 정의
  List<charts.Series<BarModel, String>> series = [
    charts.Series<BarModel, String>(
      id: 'Vehicles',
      data: barData,
      domainFn: (BarModel model, _) => model.category,
      measureFn: (BarModel model, _) => model.count,
      colorFn: (BarModel model, _) =>
          charts.ColorUtil.fromDartColor(model.color),
    ),
  ];

  // 차트를 고정된 높이를 가진 SizedBox 안에 배치하여 크기를 제한
  return SizedBox(
    height: 200.0, // 막대 그래프의 높이 설정
    child: charts.BarChart(
      series,
      animate: true, // 애니메이션 효과 활성화
      vertical: false, // 가로 막대 그래프를 그릴지 여부
      barRendererDecorator: charts.BarLabelDecorator<String>(), // 막대 위에 라벨 표시
      domainAxis: charts.OrdinalAxisSpec(
        // X축 설정
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            // X축 라벨 스타일 설정
            fontSize: 10, // 글자 크기
            color: charts.MaterialPalette.black, // 글자 색상
          ),
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        // Y축 설정
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            // Y축 라벨 스타일 설정
            fontSize: 10, // 글자 크기
            color: charts.MaterialPalette.black, // 글자 색상
          ),
        ),
      ),
    ),
  );
}

class FuelData {
  final DateTime date;
  final double fuelConsumed;
  final String managerCode;

  FuelData(
      {required this.date,
      required this.fuelConsumed,
      required this.managerCode});

  factory FuelData.fromJson(Map<String, dynamic> json) {
    return FuelData(
      date: DateTime.parse(json['date']),
      fuelConsumed: double.parse(json['fuel_consumed']),
      managerCode: json['managercode'],
    );
  }
}

Future<Map<DateTime, double>> fetchAndProcessData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // SharedPreferences에서 managerCode를 불러옵니다.
  String managerCode = prefs.getString('managercode') ?? 'default_manager_code';
  print("Using managerCode: $managerCode");

  final response =
      await http.get(Uri.parse('http://34.22.80.43:8000/api/image-with-text'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    List<FuelData> dataList =
        jsonData.map((json) => FuelData.fromJson(json)).toList();

    Map<DateTime, double> fuelConsumedByDate = {};
    for (var data
        in dataList.where((data) => data.managerCode == managerCode)) {
      DateTime dateOnly =
          DateTime(data.date.year, data.date.month, data.date.day);
      if (fuelConsumedByDate.containsKey(dateOnly)) {
        fuelConsumedByDate[dateOnly] =
            (fuelConsumedByDate[dateOnly] ?? 0) + data.fuelConsumed;
      } else {
        fuelConsumedByDate[dateOnly] = data.fuelConsumed;
      }
    }
    // 로그를 찍어서 데이터가 정상적으로 처리되었는지 확인합니다.
    print('Processed Data: $fuelConsumedByDate');
    return fuelConsumedByDate;
  } else {
    // 에러 발생시 콘솔에 에러를 출력합니다.
    print('Failed to load data: ${response.body}');
    throw Exception('Failed to load data');
  }
}

class FuelConsumedLineChart extends StatelessWidget {
  final Map<DateTime, double> fuelConsumedData;

  FuelConsumedLineChart({Key? key, required this.fuelConsumedData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = fuelConsumedData.entries.map((entry) {
      return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value);
    }).toList();

    // 시간 순서대로 점들을 정렬합니다.
    spots.sort((a, b) => a.x.compareTo(b.x));

    // 격자의 간격을 설정합니다.
    final double xInterval =
        Duration(days: 2).inMilliseconds.toDouble(); // 5일 간격
    final double yInterval = 20; // 10리터 간격

    // 최대 y값을 찾아 차트의 maxY로 설정합니다.
    double maxY = fuelConsumedData.values.reduce(math.max);
    double minY = 0; // y축의 최소값은 0으로 설정합니다.

    // maxY를 yInterval의 가장 가까운 배수로 올립니다.
    maxY = (maxY / yInterval).ceil() * yInterval;

    // x축 라벨을 위한 포맷터를 설정합니다 (단, 일자만 표시).
    final DateFormat dateFormatter = DateFormat('MM/dd');

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            colors: [Color(0xFF508068)],
            barWidth: 4,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return dateFormatter.format(date); // 'MM/dd' 포맷에서 'dd' 부분만 표시
            },
            interval: xInterval,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTitles: (value) => '${value.toInt()}L',
            interval: yInterval,
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: yInterval,
          drawVerticalLine: true,
          verticalInterval: xInterval,
          checkToShowHorizontalLine: (value) => value % yInterval == 0,
          checkToShowVerticalLine: (value) => value % xInterval == 0,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xffe7e8ec),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: const Color(0xffe7e8ec),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: minY,
        maxY: maxY,
      ),
    );
  }
}
