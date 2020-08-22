import 'dart:ui';

import 'package:flutter/material.dart';
import '../ui-helper.dart';

final double _expandedWidth = 392.0;
final double _retractedWidth = 120.0;

class AddWidget extends StatefulWidget {
  AddWidget();
  @override
  _ToggleButtonWidgetState createState() => _ToggleButtonWidgetState();
}

class _ToggleButtonWidgetState extends State<AddWidget> {
  String get _sliderLabel {
    if (_difficulty == 0.0) {
      return "Easy";
    }
    if (_difficulty == 0.25) {
      return "Intermediate";
    }
    if (_difficulty == 0.5) {
      return "Medium";
    }
    if (_difficulty == 0.75) {
      return "Advanced";
    }
    if (_difficulty == 1.0) {
      return "Hard";
    }
    return "";
  }
  bool _imageDelete = false;
  bool _pickedImage = true;
  bool isExpanded = false;
  bool _pickedLocation = true;
  bool _locationDelete = false;
  double _difficulty = 0.0;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: isExpanded ? 0.0 : null,
      top: isExpanded ? null : realH(802.0 - 60.0),
      left: realW(isExpanded
          ? (392 / 2) - _expandedWidth / 2
          : (392 / 2) - _retractedWidth / 2),
      child: Transform.translate(
        offset: Offset(0.0, isExpanded ? 0.0 : 0.0),
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
              borderRadius: BorderRadius.vertical(
                  top: isExpanded
                      ? Radius.circular(20.0)
                      : Radius.circular(70.0),
                  bottom: Radius.zero)),
          width: realW(isExpanded ? _expandedWidth : _retractedWidth),
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(height: 10),
            IconButton(
              icon: Icon(
                Icons.add,
                size: realW(35.0),
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
            SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildLocationPicker(),
                    TextField(
                      decoration: InputDecoration(hintText: "Title"),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: "Description"),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(child: Text("Difficulty",style:  Theme.of(context).textTheme.headline6,)),
                    Slider(
                        inactiveColor: Colors.black,
                        activeColor: Theme.of(context).accentColor,
                        divisions: 4,
                        label: _sliderLabel,
                        value: _difficulty,
                        onChanged: (val) {
                          setState(() {
                            print(val);
                            _difficulty = val;
                          });
                        }),
                    _buildImagePicker(),
                  ]),
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildImagePicker(){
    return _pickedImage
        ? Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _imageDelete = !_imageDelete;
          });
        },
        child: Column(
          children: [SizedBox(
            width: realW(_expandedWidth - 50.0),
            height: realH(200.0),
            child: Stack(children: [
              Image.asset(
                "assets/map.png",
                width: realW(_expandedWidth - 50.0),
                height: realH(200.0),
                fit: BoxFit.cover,
              ),
              _imageDelete
                  ? BackdropFilter(

                  filter: ImageFilter.blur(
                    sigmaX: 10.0,
                    sigmaY: 10.0,
                  ),
                  child: Container(
                    width: realW(_expandedWidth - 50.0),
                    height: realH(200.0),
                    color: Colors.white.withOpacity(0.0),
                  ))
                  : Container(),
              if (_imageDelete)
                Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(width: 20.0),
                        Transform.scale(
                            scale: 1.2,
                            child: FloatingActionButton(
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _pickedImage = false;
                                    });
                                  },
                                  icon: Icon(Icons.delete)),
                            )),
                        SizedBox(width: 20.0),
                      ],
                    ))
              else
                Container(),
            ]),
          ),]
        ),
      ),
    )
        : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Row(
              children: [
                Icon(Icons.camera_enhance),
                SizedBox(
                  width: 10.0,
                ),
                Text("Take Picture")
              ],
            ),
            color: Theme.of(context).buttonColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
          ),
          SizedBox(width: 15.0),
          RaisedButton(
            child: Row(
              children: [
                Icon(Icons.photo_library),
                SizedBox(
                  width: 10.0,
                ),
                Text("Pick"),
              ],
            ),
            color: Theme.of(context).buttonColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
          )
        ],
      ),
    );

  }

  Widget _buildLocationPicker() {
    return _pickedLocation
        ? Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _locationDelete = !_locationDelete;
                });
              },
              child: SizedBox(
                width: realW(_expandedWidth - 50.0),
                height: realH(200.0),
                child: Stack(children: [
                  Image.asset(
                    "assets/map.png",
                    width: realW(_expandedWidth - 50.0),
                    height: realH(200.0),
                    fit: BoxFit.cover,
                  ),
                  _locationDelete
                      ? BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10.0,
                            sigmaY: 10.0,
                          ),
                          child: Container(
                            width: realW(_expandedWidth - 50.0),
                            height: realH(200.0),
                            color: Colors.white.withOpacity(0.0),
                          ))
                      : Container(),
                  if (_locationDelete)
                    Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            SizedBox(width: 20.0),
                            Transform.scale(
                                scale: 1.2,
                                child: FloatingActionButton(
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _pickedLocation = false;
                                        });
                                      },
                                      icon: Icon(Icons.delete)),
                                )),
                            SizedBox(width: 20.0),
                          ],
                        ))
                  else
                    Container(),
                ]),
              ),
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text("Location")
                    ],
                  ),
                  color: Theme.of(context).buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                ),
                SizedBox(width: 15.0),
                RaisedButton(
                  child: Row(
                    children: [
                      Icon(Icons.my_location),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text("Current"),
                    ],
                  ),
                  color: Theme.of(context).buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                )
              ],
            ),
          );
  }
}
