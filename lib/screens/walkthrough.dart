import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:greencraft/screens/join.dart';

class Walkthrough extends StatefulWidget {
  @override
  _WalkthroughState createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  List pageInfos = [
    {
      "title": "GreenTax Station ",
      "body": "안녕하세요, 2050 차량 탄소 중립 서비스입니다.\n2050년까지 차량으로 인한 탄소 배출을\n'넷 제로(Net-Zero)'\n만들기 위한 목표를 실현하기 위해 노력합니다. ",
      "img": "assets/logo2.jpg",
    },
    {
      "title": "GreenTax Station",
      "body": "유류세를 사용하여 환경 정책을 지원하고 온실 가스 배출을 줄이는 방향으로 지원합니다.\n 친환경 연료에 대한 세제 혜택을 제공하거나, 환경 보호 프로젝트를 자금 지원할 수 있습니다.",
      "img": "assets/logo4.png",
    },
    {
      "title": "GreenTax Station",
      "body": "유류세 부과 방식과 세율은 지역에 따라 다를 수 있으며, 국가의 경제 상황,\n교통 정책, 환경 목표 및 예산 요구에 따라 변동합니다.\n유류세는 주로 휘발유, 디젤 연료, 항공유, 천연가스 등 다양한 연료 유형에 부과되며,\n이러한 수입은 국가의 재정 체계와 세금 제도의 중요한 부분을 형성합니다.",
      "img": "assets/logo3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<PageViewModel> pages = [
      for (int i = 0; i < pageInfos.length; i++)
        _buildPageModel(pageInfos[i], i)
    ];

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: IntroductionScreen(
            pages: pages,
            onDone: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return JoinApp();
                  },
                ),
              );
            },
            onSkip: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return JoinApp();
                  },
                ),
              );
            },
            showSkipButton: true,
            skip: const Text("Skip", 
                style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,  // Example color
              ),
            ),
            next: const Text(
              "Next",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF7ed957),  // Example color
              ),
            ),
            done: const Text(
              "Done",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF7ed957), // Example color
              ),
            ),
          ),
        ),
      ),
    );
  }

_buildPageModel(Map item, int pageIndex) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  double imageWidth = 400.0; // 기본 이미지 너비
  double imageHeight = 350.0; // 기본 이미지 높이

  // 첫 번째 페이지의 이미지만 위로 조금 올립니다.
  EdgeInsets imageMargin = EdgeInsets.only(top: pageIndex == 0 ? 10.0 : 20.0);
  EdgeInsets titlePadding = EdgeInsets.only(top: pageIndex == 0 ? 0.0 : 24.0);
  EdgeInsets bodyPadding = EdgeInsets.only(top: pageIndex == 0 ? 6.0 : 16.0);

  // 두 번째 및 세 번째 페이지의 이미지를 화면에 꽉 차게 조정하고 패딩을 조절합니다.
  if (pageIndex == 1 || pageIndex == 2) {
  imageWidth = screenWidth * 0.8; // 화면 너비의 90%
  imageHeight = screenHeight * 0.8; // 화면 높이의 90%
  titlePadding = const EdgeInsets.only(top: 0.0); // 제목 패딩을 줄임
  bodyPadding = const EdgeInsets.only(top: 6.0); // 본문 패딩을 줄임
}

  return PageViewModel(
    titleWidget: Padding(
      padding: titlePadding,
      child: Text(
        item['title'],
        style: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    ),
    bodyWidget: Padding(
      padding: bodyPadding,
      child: Text(
        item['body'],
        style: TextStyle(fontSize: 15.0),
        textAlign: TextAlign.center,
      ),
    ),
    image: Container(
      margin: imageMargin,
      child: Image.asset(
        item['img'],
        width: imageWidth,
        height: imageHeight,
        fit: (pageIndex == 1 || pageIndex == 2) ? BoxFit.cover : BoxFit.fitHeight, // 두 번째 및 세 번째 페이지는 cover, 나머지는 fitHeight
      ),
    ),
    decoration: PageDecoration(
      pageColor: Colors.white,
      bodyFlex: 3,
      imageFlex: 5,
    ),
  );
}}