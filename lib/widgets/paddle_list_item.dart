import 'package:flutter/material.dart';
import '../model/paddle_item.dart';

class PaddleListItem extends StatefulWidget {
  final PaddleItem item;
  PaddleListItem(this.item);

  @override
  _PaddleListItemState createState() => _PaddleListItemState();
}

class _PaddleListItemState extends State<PaddleListItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(

      title: Text(widget.item.title),
      subtitle: Text(widget.item.difficulty),
      isThreeLine: _expanded,
      trailing: IconButton(
        icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
        onPressed: () => setState(() {
          _expanded = !_expanded;
        }),
      ),
      leading: CircleAvatar(
        maxRadius: 40,
        minRadius: 40,
        child: Text("4.2km")
      ),

    );
  }
}
