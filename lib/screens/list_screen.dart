import 'package:flutter/material.dart';
import '../widgets/paddle_list_item.dart';
import '../model/paddle_item.dart';
import '../widgets/simple_button.dart';
import '../widgets/list_button.dart';
import '../ui-helper.dart';

class ListScreen extends StatefulWidget {
  final List<PaddleItem> items;
  ListScreen({this.items});

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  @override
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (ctx, index) {
              return PaddleListItem(widget.items[index]);
            },
          ),
        ),
        SimpleButtonWidget(
          onTap: () {},
          icon: Icons.filter_list,
          isTop: false,
          isLeft: true,
        ),
        SimpleButtonWidget(
          icon: Icons.settings,
          isTop: true,
          isLeft: true,
        ),

        SimpleButtonWidget(
            icon: Icons.map,
            isTop: false,
            isLeft: false,
            onTap: () => Navigator.of(context).pop(),
          onDrag:(_)=> Navigator.of(context).pop()//showFilter(),
        ),
      ]),
    );
  }
}
