import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greencraft/screens/QuizManagerScreen.dart';
import 'package:greencraft/screens/generalmodel.dart';
import 'package:greencraft/screens/businessmodel.dart';
import 'package:greencraft/screens/home.dart';
import 'package:greencraft/screens/board.dart';
import 'package:greencraft/screens/profile.dart';
import 'package:greencraft/screens/faq.dart';
import 'package:greencraft/util/const.dart';
import 'package:greencraft/widgets/badge.dart';
import 'package:greencraft/screens/ModelListPage.dart';
import 'package:greencraft/screens/QuizScreen.dart';
import 'package:greencraft/screens/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final int initialPage;

  MainScreen({this.initialPage = 0}); // 기본값은 2로 설정, 필요에 따라 변경 가능

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _page = 0;
  bool comcode = false; // comcode 추가
  // 클래스 내부에 goToHomeScreen 함수를 정의합니다.
  void goToHomeScreen() {
    _pageController.jumpToPage(0);
  }


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _page = widget.initialPage;
WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(widget.initialPage);
    }
  });
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final comcodePref =
        prefs.getBool('comcode') ?? false; // null일 경우 기본값 false 사용
    if (mounted) {
      setState(() {
        comcode = comcodePref;
      });
    }
  }

  
@override
  Widget build(BuildContext context) {
    List<Widget> pages;
    List<IconData> icons;

    if (comcode) {
      // 사업자 페이지일 때
      pages = [
        Home(),
        GeneralModel(),
        ImageScreen(), // 사업자 페이지
        PainterAnimationPieChartScreen(),
        FAQScreen(),
        QuizScreen(),
        Profile(),
      ];
      icons = [
        Icons.home,
        Icons.car_rental, // ImageScreen() 아이콘
        Icons.local_gas_station,// GeneralModel() 아이콘
        Icons.insert_chart, // ModelListPage() 아이콘
        Icons.question_answer, // FAQScreen() 아이콘
        Icons.quiz, // QuizScreen() 아이콘
        Icons.person, // Profile() 아이콘
      ];
    } else {
      // 일반 사용자 페이지일 때
      pages = [
        Home(),
        GeneralModel(),
        FAQScreen(),
        QuizScreen(),
        Profile(),
      ];
      icons = [
        Icons.home,
        Icons.car_rental, // GeneralModel() 아이콘
        Icons.question_answer,
        Icons.quiz,
        Icons.person, // Profile() 아이콘
      ];
    }

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(Constants.appName),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.message,
                size: 22.0,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return BoardScreen();
                    },
                  ),
                );
              },
              tooltip: "board",
            ),
          ],
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: pages,
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors
              .grey[200], // Set the bottom navigation bar color to light gray
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(pages.length, (index) {
              IconData iconData =
                  icons[index]; // Use the correct icon for each tab
              return IconButton(
                icon: Icon(
                  iconData,
                  size: 30.0,
                  color: _page == index
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).textTheme.caption?.color,
                ),
                onPressed: () {
                setState(() { // setState를 호출하여 UI를 갱신합니다.
                  _pageController.jumpToPage(index);
                });
              },
            );
          }),
        ),
      ),
    ),
  );
}



  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }




  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}