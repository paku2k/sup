import 'package:flutter/material.dart';
import '../ui-helper.dart';

class SimpleButtonWidget extends StatefulWidget {
  final bool isLeft;
  final Function onTap;
  final bool isTop;
  final IconData icon;
  SimpleButtonWidget({this.onTap, this.isLeft, this.isTop, this.icon});
  @override
  _ToggleButtonWidgetState createState() => _ToggleButtonWidgetState();
}

class _ToggleButtonWidgetState extends State<SimpleButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.isTop?realH(803.0 - 260.0):realH(803.0-150.0),
      left: !widget.isLeft ? null : 0.0,
      right: !widget.isLeft?0.0:null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
              borderRadius: BorderRadius.horizontal(
                  left: widget.isLeft ? Radius.zero : Radius.circular(40.0),
                  right: widget.isLeft ? Radius.circular(40.0) : Radius.zero)),
          width: realW(392 / 5.0),
          height: realH(70),
          padding: EdgeInsets.only(left:20.0, right: 20.0),
          child: Icon(widget.icon, size: realW(35.0),color: Colors.white,),
        ),
      ),
    );
  }
}
