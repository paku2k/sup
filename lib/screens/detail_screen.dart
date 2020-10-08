import 'package:flutter/material.dart';

import '../model/paddle_item.dart';

class DetailScreen extends StatefulWidget {
  final PaddleItem item;
  DetailScreen(this.item);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: widget.item.id,
            child: Container(
              height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              image: new DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.dstATop),
                image: widget.item.imageAsset.length == 0
                    ? AssetImage(
                  'Paddleboard.jpg',
                )
                    : NetworkImage(widget.item.imageAsset[0]),
              ),
            ),
          ),)
        ],
      ),
    );
  }
}
