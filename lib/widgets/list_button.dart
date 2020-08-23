import 'package:flutter/material.dart';
import '../ui-helper.dart';


class  ToggleButtonWidget extends StatelessWidget {

final bool isMap;
final Function onTap;
final Function onUpdate;
final Function onDispatch;
final double currentX;
ToggleButtonWidget({this.isMap, this.onTap, this.currentX, this.onUpdate, this.onDispatch});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: realH(803.0 - 150.0),
      left: !isMap ? null : currentX,
      right: !isMap?0.0:null,
      child: GestureDetector(
        onHorizontalDragUpdate: onUpdate,
        onHorizontalDragEnd: onDispatch,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
              borderRadius: BorderRadius.horizontal(
                  left: isMap ? Radius.zero : Radius.circular(40.0),
                  right: isMap ? Radius.circular(40.0) : Radius.zero)),
          width: realW(392 / 5.0),
          height: realH(70),
          padding: EdgeInsets.only(left:20.0, right: 20.0),
          child: Icon(isMap?Icons.format_list_numbered:Icons.location_on, size: realW(35.0),color: Colors.white,),
        ),
      ),
    );
  }


}
