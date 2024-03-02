import 'package:flutter/material.dart';
import 'package:greencraft/screens/main_screen.dart';
import 'package:greencraft/widgets/grid_product.dart';
import 'package:greencraft/widgets/home_category.dart';
import 'package:greencraft/util/cars.dart';
import 'package:greencraft/util/categories.dart';
import 'package:greencraft/screens/categories_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:greencraft/widgets/slider_item.dart';
import 'package:greencraft/util/homemodel.dart';
import 'package:greencraft/screens/businessmodel.dart';
import 'package:greencraft/screens/generalmodel.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home>{
  bool isComcode = false; // 기본값으로 false 설정
  late PageController _pageController; // PageController 선언

  // List<T> map<T>(List list, Function handler) {
  //   List<T> result = [];
  //   for (var i = 0; i < list.length; i++) {
  //     result.add(handler(i, list[i]));
  //   }
  //   return result;
  // }

  int _current = 0; 

  final List<String> carDescriptions = [
  "",
  "",
  "",
  "",
  "",
  "",
  "",
];

@override
  void initState() {
    super.initState();
    _loadComcode(); 
  }

Future<void> _loadComcode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final comcodePref = prefs.getBool('comcode') ?? false;
    setState(() {
      isComcode = comcodePref;
      _pageController = PageController(
      ); // 여기에서 _pageController를 초기화합니다.
    });
  }



@override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0,0,10.0,0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                
                Text(
                  "Car",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.0),

            //Slider Here

CarouselSlider(
  items: cars.asMap().entries.map((entry) {
    int idx = entry.key;
    Map car = entry.value;
    String description = (idx < carDescriptions.length) ? carDescriptions[idx] : '설명 없음';
    return Column(
      children: [
        SliderItem(
          img: car['img'],
          name: car['name'],
          description: car['description']
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }).toList(),
  options: CarouselOptions(
    height: MediaQuery.of(context).size.height * 0.41,
    autoPlay: true,
    viewportFraction: 1.0,
    onPageChanged: (index, reason) {
      setState(() {
        _current = index;
      });
    },
  ),
),



            SizedBox(height: 0),

            Text(
              "Car Categories",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10.0),

            Container(
  height: 65.0,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    shrinkWrap: true,
    itemCount: categories == null ? 0 : categories.length,
    itemBuilder: (BuildContext context, int index) {
      Map cat = categories[index];
      return
      HomeCategory(
  icon: cat['icon'],
  title: cat['name'],
  items: cat['items'].toString(),
  isHome: true,
  tap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return CategoriesScreen(selectedCategory: cat['name']);
        },
      ),
    );
  },
);
    
    },
  ),
),
SizedBox(height: 20.0),
 SizedBox(height: 0),
          _buildServiceSection("General Service", "나의 탄소세를 확인해보세요", onTapGeneralService),
          _buildServiceSection("Business Service", "들어온 차량을 확인해보세요", onTapBusinessService),
          _buildServiceSection("FAQ", "자주 묻는 질문", onTapFAQ),
          _buildServiceSection("Quiz", " 퀴즈풀기", onTapQuiz),


          ],
        ),
      ),
    );
  }

  Widget _buildServiceSection(String title, String subtitle, VoidCallback onTap) {
   if (title == "Business Service" && !isComcode) {
    return SizedBox(); // 일반 사용자에게는 아무것도 표시하지 않음
  }

  String displayTitle = isComcode ? "$title" : "$title";
  return ListTile(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text(subtitle),
    trailing: Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

void onTapGeneralService() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MainScreen(initialPage: 1), // 여기서 GeneralServiceScreen은 일반 서비스를 보여주는 화면의 위젯 클래스입니다.
    ),
  );
}
void onTapBusinessService() {
   if (isComcode) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MainScreen(initialPage: 2), // 0번 페이지로 초기 설정
    ),
  );
 } else {
      // 일반 사용자일 경우, 다른 화면으로 이동할 수 있음
      // 예: GeneralServiceScreen()
    }
  }

 void onTapFAQ() {
  if (isComcode) {
    // comcode가 true일 경우, MainScreen의 initialPage를 4로 설정
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialPage: 4),
      ),
    );
  } else {
    // comcode가 false일 경우 (일반 사용자), MainScreen의 initialPage를 1로 설정
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialPage: 2),
      ),
    );
  }
}

  void onTapQuiz() {
   if (isComcode) {
    // comcode가 true일 경우, MainScreen의 initialPage를 4로 설정
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialPage: 5),
      ),
    );
  } else {
    // comcode가 false일 경우 (일반 사용자), MainScreen의 initialPage를 1로 설정
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialPage: 3),
      ),
    );
  }
}






  @override
  bool get wantKeepAlive => true;
}