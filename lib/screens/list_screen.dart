import 'package:flutter/material.dart';
import '../widgets/paddle_list_item.dart';
import '../model/paddle_item.dart';

class ListScreen extends StatefulWidget {
  ListScreen(Key key) : super(key: key);

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> with AutomaticKeepAliveClientMixin  {

@override
// TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: 20,
        itemBuilder: (ctx, index) {
          return PaddleListItem(
              PaddleItem(title: "Title Text", difficulty: 0.0, rating: 4.5));
        },
      ),
    );
  }
}
