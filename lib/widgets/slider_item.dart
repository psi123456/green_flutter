import 'package:flutter/material.dart';
import 'package:greencraft/screens/details.dart';

class SliderItem extends StatelessWidget {
  final String name;
  final String img;
  final String? description; // 타입을 bool에서 String으로 변경

  SliderItem({
    Key? key,
    required this.name,
    required this.img,
    this.description, // 타입 변경에 따른 수정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListView(
        shrinkWrap: true,
        primary: false,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 3.2,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    img, // "$img"에서 따옴표 제거
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 여기에 필요한 UI 구성 코드를 추가하세요.
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 2.0, top: 8.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
            ),
          ),
          // 여기에 추가적인 UI 구성 코드를 추가하세요.
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ProductDetails(
                name: name,
                img: img,
                description: description ?? '설명이 없습니다.',
              );
            },
          ),
        );
        
      },
    );
  }
}