import 'package:flutter/material.dart';
import 'package:greencraft/screens/details.dart';
import 'package:greencraft/screens/generalmodel.dart';

class GridProduct extends StatelessWidget {
  final String name;
  final String img;
  final String? description;
  final bool isModelService; // 추가된 매개변수

  GridProduct({
    Key? key,
    required this.name,
    required this.img,
    this.description,
    this.isModelService = false, // 기본값은 false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isModelService) {
          // Model Services 섹션에서 사용될 경우 GeneralModel 페이지로 이동
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return GeneralModel();
              },
            ),
          );
        } else {
          // Car Categories 섹션에서 사용될 경우 ProductDetails 페이지로 이동
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return ProductDetails(
                  name: name,
                  img: img,
                  description: description ?? '설명이 없습니다.', // null 체크 추가
                );
              },
            ),
          );
        }
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                img,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}