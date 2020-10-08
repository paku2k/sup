import 'package:flutter/material.dart';
import '../model/paddle_item.dart';
import '../widgets/paddle_list_item.dart';

class InfoDisplay extends StatelessWidget {
  final PaddleItem item;
  InfoDisplay(this.item);
  @override
  Widget build(BuildContext context) {
    return PaddleListItem(item);
  }
}
