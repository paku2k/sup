import 'package:flutter/material.dart';
import '../ui-helper.dart';


class  ToggleButtonWidget extends StatelessWidget {

final bool isMap;
final Function onTap;
final Function onDrag;
final Function onDispatch;
final double currentX;
ToggleButtonWidget({this.isMap, this.onTap, this.currentX, this.onDrag, this.onDispatch});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: realH(803.0 - 150.0),
      left: currentX,

      child: GestureDetector(
        onVerticalDragStart: onDrag,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
              borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(40.0))),
          width: realW(392 / 5.0),
          height: realH(70),
          padding: EdgeInsets.only(left:20.0, right: 20.0),
          child: Icon(Icons.format_list_numbered, size: realW(35.0),color: Colors.white,),
        ),
      ),
    );
  }


}
