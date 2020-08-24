import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import '../animations/circleBoxAnimation.dart';
import '../ui-helper.dart';
import 'package:simple_animations/simple_animations.dart';
import '../widgets/list_button.dart';
import '../widgets/add_widget.dart';
import '../widgets/simple_button.dart';
import '../screens/map_screen.dart';
import '../screens/list_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MainScreen> {
  double opacity = 0.0;
  double get _explorePercent {
    return screenWidth / currentMapPosition;
  }

  void opacityCallback(double pcnt) {
    setState(() {
      opacity = pcnt;
    });
  }

  final _mapKey = GlobalKey<MapScreenState>();
  CustomAnimationControl _control = CustomAnimationControl.STOP;
  bool _isMap = true;
  double currentMapPosition = 0;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(children: [
        _isMap ? MapScreen(key: _mapKey) : ListScreen(),
        _isMap
            ? Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: RaisedButton(
                    color: Theme.of(context).buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    onPressed: () {
                      setState(() {
                        _isMap = !_isMap;
                      });
                    },
                    child: Text("Search Here"),
                  ),
                ),
              )
            : Container(),
        ToggleButtonWidget(
          currentX: 0,
          isMap: _isMap,
          onTap: () {
            setState(() {
              _isMap = !_isMap;
            });
          },
        ),
        SimpleButtonWidget(
          onTap: () {
            _mapKey.currentState.animateToUserLocation();
          },
          icon: _isMap ? Icons.my_location : Icons.filter_list,
          isTop: false,
          isLeft: false,
        ),
        SimpleButtonWidget(
          icon: Icons.settings,
          isTop: true,
          isLeft: true,
        ),
        SimpleButtonWidget(
          icon: Icons.search,
          isTop: true,
          isLeft: false,
        ),
        opacity != 0
            ? BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 10 * opacity, sigmaY: 10 * opacity),
                child: Container(
                  color: Colors.white.withOpacity(0.1 * opacity),
                  width: screenWidth,
                  height: screenHeight,
                ),
              )
            : const Padding(
                padding: const EdgeInsets.all(0),
              ),
        AddWidget(opacityCallback),
      ]),
    ));
  }

  void _dispatchExploreOffset(_) {
    if (!_isMap) {
      if (_explorePercent < 0.3) {
        _isMap = false;
      } else {
        _isMap = true;
      }
    } else {
      if (_explorePercent > 0.6) {
        _isMap = true;
      } else {
        _isMap = false;
      }
    }
    setState(() {});
  }
}
