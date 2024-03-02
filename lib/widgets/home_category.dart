import 'package:flutter/material.dart';
import 'package:greencraft/screens/categories_screen.dart';


class HomeCategory extends StatefulWidget {
  final IconData icon;
  final String title;
  final String items;
  final void Function()? tap; // 변경된 부분
  final bool isHome;

  HomeCategory({
    Key? key,
    required this.icon,
    required this.title,
    required this.items,
    required this.tap, // 변경된 부분
    required this.isHome,
  }) : super(key: key);

  @override
  _HomeCategoryState createState() => _HomeCategoryState();
}

class _HomeCategoryState extends State<HomeCategory> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isHome ? () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              // 'selectedCategory' 매개변수로 'title'을 전달합니다.
              return CategoriesScreen(selectedCategory: widget.title);
            },
          ),
        );
      } : widget.tap,
      child: Card(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10.0)),
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 0.0, right: 10.0),
                child: Icon(
                  widget.icon,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Text(
                    "${widget.title}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),

                  Text(
                    "${widget.items} Items",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
              SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}