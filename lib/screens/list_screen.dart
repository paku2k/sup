import 'package:flutter/material.dart';
import '../widgets/paddle_list_item.dart';
import '../model/paddle_item.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (ctx, index) {
        return PaddleListItem(PaddleItem(title: "Title Text", difficulty: "Easy", rating: 4.5));
      },
    );
  }
}
