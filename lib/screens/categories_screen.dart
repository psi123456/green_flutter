// CategoriesScreen.dart
import 'package:flutter/material.dart';
import 'package:greencraft/screens/board.dart';
import 'package:greencraft/screens/board.dart';
import 'package:greencraft/widgets/badge.dart';
import 'package:greencraft/widgets/grid_product.dart';
import 'package:greencraft/util/cars.dart';

class CategoriesScreen extends StatefulWidget {
  final String selectedCategory;

  CategoriesScreen({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> filteredCars = [];

  @override
  void initState() {
    super.initState();
    _filterCars();
  }

  void _filterCars() {
    filteredCars = cars.where((car) {
      return car['type'] == widget.selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(widget.selectedCategory),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: IconBadge(icon: Icons.notifications, size: 22.0),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return BoardScreen
                    ();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 10.0),
            // 선택된 카테고리에 해당하는 차량을 그리드 뷰로 표시
            GridView.builder(
              shrinkWrap: true,
              primary: false,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 1.25),
              ),
              itemCount: filteredCars.length,
              itemBuilder: (BuildContext context, int index) {
                Map car = filteredCars[index];
                return GridProduct(
                  img: car['img'],
                  name: car['name'],
                  description: car['description'],  // 동적으로 설정되어야 합니다.
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}