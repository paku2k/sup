import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../ui-helper.dart';

final double _expandedWidth = 392.0;
final double _retractedWidth = 120.0;

class AddWidget extends StatefulWidget {
  AddWidget();
  @override
  _ToggleButtonWidgetState createState() => _ToggleButtonWidgetState();
}

class _ToggleButtonWidgetState extends State<AddWidget>
    with TickerProviderStateMixin {
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

  void animateAdd(bool open) {
    final RenderBox _renderBoxContainer =
        _containerKey.currentContext.findRenderObject();
    _renderHeight = _renderBoxContainer.size.height;
    animationControllerAdd = AnimationController(
        duration: Duration(
            milliseconds: 1 +
                (800 * (isExpanded ? currentPercent : (1 - currentPercent)))
                    .toInt()),
        vsync: this);
    curve = CurvedAnimation(parent: animationControllerAdd, curve: Curves.easeOutQuart);
    animation = Tween(begin: _currentX, end: open ? _renderHeight - 80.0 : 0.0)
        .animate(curve)
          ..addListener(() {
            setState(() {
              _currentX = animation.value;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              isExpanded = open;
            }
          });
    animationControllerAdd.forward();
  }

  void onAddVerticalUpdate(details) {
    _currentX -= details.delta.dy;
    if (_currentX > _renderHeight-80.0) {
      _currentX = _renderHeight-80.0;
    } else if (_currentX < 0) {
      _currentX = 0;
    }
    setState(() {});
  }

  void _dispatchDrag() {
    if (!isExpanded) {
      if (currentPercent < 0.3) {
        animateAdd(false);
      } else {
        animateAdd(true);
      }
    } else {
      if (currentPercent > 0.6) {
        animateAdd(true);
      } else {
        animateAdd(false);
      }
    }
  }

  AnimationController animationControllerAdd;
  CurvedAnimation curve;
  Animation animation;

  GlobalKey _containerKey = GlobalKey();
  double _renderHeight;

  List<File> _images = [];
  bool _imageDelete = false;
  bool _pickedImage = false;
  int _imageNumber = 0;
  bool isExpanded = false;
  bool _pickedLocation = true;
  bool _locationDelete = false;
  double _difficulty = 0.0;
  double _currentX = 0.0;

  double get currentPercent {
    return _currentX / _renderHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: realH(802.0 - 79.0),
      left: realW((392 / 2) - _expandedWidth / 2),
      child: Transform.translate(
        offset: Offset(0.0, -_currentX),
        child: Container(
          key: _containerKey,
          width: realW(_expandedWidth),
          decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage('sup_ultra_high.png'),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              )),
          child: GestureDetector(
            onTap: () {
              animateAdd(!isExpanded);
            },
            onVerticalDragUpdate: onAddVerticalUpdate,
            onVerticalDragEnd: (_) => _dispatchDrag(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Icon(
                    Icons.add,
                    size: realW(35.0),
                    color: Colors.white,
                  ),
                  SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          _buildLocationPicker(),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: realW(_expandedWidth * 0.65)),
                            child: TextField(
                              decoration: InputDecoration(hintText: "Title"),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: realW(_expandedWidth * 0.70)),
                            child: TextField(
                              decoration:
                                  InputDecoration(hintText: "Description"),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Center(
                              child: Text(
                            "Difficulty",
                            style: Theme.of(context).textTheme.headline6,
                          )),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: realW(_expandedWidth * 0.85)),
                            child: Slider(
                                inactiveColor: Colors.black,
                                activeColor: Colors.lightBlueAccent,
                                divisions: 4,
                                label: _sliderLabel,
                                value: _difficulty,
                                onChanged: (val) {
                                  setState(() {
                                    print(val);
                                    _difficulty = val;
                                  });
                                }),
                          ),
                          _buildImagePicker(),
                        ]),
                  )
                ]),
          ),
        ),
      ),
    );
  }

//  Widget _buildImagePicker() {
//    return _pickedImage
//        ? Padding(
//            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
//            child: GestureDetector(
//              onTap: () {
//                setState(() {
//                  _imageDelete = !_imageDelete;
//                });
//              },
//              child: Column(children: [
//
//                SizedBox(
//                  width: realW(_expandedWidth - 50.0),
//                  height: realH(200.0),
//                  child: Stack(children: [
//                    Image.asset(
//                      "assets/map.png",
//                      width: realW(_expandedWidth - 50.0),
//                      height: realH(200.0),
//                      fit: BoxFit.cover,
//                    ),
//                    _imageDelete
//                        ? BackdropFilter(
//                            filter: ImageFilter.blur(
//                              sigmaX: 10.0,
//                              sigmaY: 10.0,
//                            ),
//                            child: Container(
//                              width: realW(_expandedWidth - 50.0),
//                              height: realH(200.0),
//                              color: Colors.white.withOpacity(0.0),
//                            ))
//                        : Container(),
//                    if (_imageDelete)
//                      Align(
//                          alignment: Alignment.center,
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                            mainAxisSize: MainAxisSize.max,
//                            children: <Widget>[
//                              SizedBox(width: 20.0),
//                              Transform.scale(
//                                  scale: 1.2,
//                                  child: FloatingActionButton(
//                                    child: IconButton(
//                                        onPressed: () {
//                                          setState(() {
//                                            _pickedImage = false;
//                                          });
//                                        },
//                                        icon: Icon(Icons.delete)),
//                                  )),
//                              SizedBox(width: 20.0),
//                            ],
//                          ))
//                    else
//                      Container(),
//                  ]),
//                ),
//              ]),
//            ),
//          )
//        : SingleChildScrollView(
//            scrollDirection: Axis.horizontal,
//            child: Column(
//              mainAxisSize: MainAxisSize.max,
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: <Widget>[
//                Text(
//                  'Image',
//                  style: Theme.of(context).textTheme.headline6,
//                ),
//                SizedBox(height: 15.0),
//                Row(
//                  children: [
//                    FloatingActionButton(
//                      onPressed: (){},
//                      child:Icon(Icons.photo),
//                    ),
//                    SizedBox(width: 15.0),
//                    FloatingActionButton(
//                      onPressed: (){},
//                      child:Icon(Icons.camera_alt),
//                    ),
//                  ],
//                ),
//              ],
//            ),
//          );
//  }

  Widget _buildImagePicker() {
    return SizedBox(
      width: realW(_expandedWidth - 70.0),
      height: realH(250.0),
      child: Center(
        child: _pickedImage
            ? Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imageDelete = !_imageDelete;
                    });
                  },
                  child: Container(
                    height: realH(150.0),
                    child: Stack(children: [
                      ClipPath(
                        clipper: CustomClipImage(),
                        child: Image.asset(
                          _images[_imageNumber - 1].path,
                          width: realW(_expandedWidth - 50.0),
                          height: realH(200.0),
                          fit: BoxFit.cover,
                        ),
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
                                SizedBox(width: 20),
                                Transform.scale(
                                  scale: 1.2,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    child: Icon(Icons.add),
                                  ),
                                ),
                                SizedBox(width: 20.0),
                                Transform.scale(
                                  scale: 1.2,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        _pickedImage = false;
                                      });
                                    },
                                    child: Icon(Icons.delete),
                                  ),
                                ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Image',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        FloatingActionButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final _imageResource = await picker.getImage(
                                source: ImageSource.gallery,
                                maxWidth: 1000,
                                imageQuality: 50);
                            _images.add(File(_imageResource.path));
                            setState(() {
                              _imageNumber++;
                              _pickedImage = true;
                              _imageDelete = false;
                            });
                          },
                          child: Icon(Icons.image),
                        ),
                        SizedBox(width: 15.0),
                        FloatingActionButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final _imageResource = await picker.getImage(
                                source: ImageSource.camera,
                                maxWidth: 1000,
                                imageQuality: 50);
                            _images.add(File(_imageResource.path));
                            setState(() {
                              _imageNumber++;
                              _pickedImage = true;
                              _imageDelete = false;
                            });
                          },
                          child: Icon(Icons.camera_alt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return SizedBox(
      width: realW(_expandedWidth - 170.0),
      height: realH(200.0),
      child: Center(
        child: _pickedLocation
            ? Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _locationDelete = !_locationDelete;
                    });
                  },
                  child: Container(
                    width: realW(_expandedWidth - 170.0),
                    height: realH(150.0),
                    child: Stack(children: [
                      ClipPath(
                        clipper: CustomClipMap(),
                        child: Image.asset(
                          "assets/map.png",
                          width: realW(_expandedWidth - 50.0),
                          height: realH(200.0),
                          fit: BoxFit.cover,
                        ),
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
                                  ),
                                ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 30.0),
                    Row(
                      children: [
                        FloatingActionButton(
                          onPressed: () {},
                          child: Icon(Icons.location_on),
                        ),
                        SizedBox(width: 15.0),
                        FloatingActionButton(
                          onPressed: () {},
                          child: Icon(Icons.my_location),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class CustomClipMap extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.27, 0.0);
    path.quadraticBezierTo(
        size.width * 0.07, size.height / 2, 0.0, size.height);
    //path.arcTo(Rect.fromLTWH(0, 0, size.width*0.2*2, size.height*2), 3.14+1.57 , -0.8, true);
    path.lineTo(size.width, size.height);
    //path.arcTo(Rect.fromLTWH(size.width*0.6, 0, size.width*0.2*2, size.height*2), 3.14+3.14 ,-0.8, true);
    path.quadraticBezierTo(
        size.width * 0.93, size.height / 2, size.width * 0.73, 0.0);
    path.lineTo(size.width * 0.27, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CustomClipImage extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.025, 0.0);
    path.quadraticBezierTo(
        size.width * 0.005, size.height / 2, 0.0, size.height);
    //path.arcTo(Rect.fromLTWH(0, 0, size.width*0.2*2, size.height*2), 3.14+1.57 , -0.8, true);
    path.lineTo(size.width, size.height);
    //path.arcTo(Rect.fromLTWH(size.width*0.6, 0, size.width*0.2*2, size.height*2), 3.14+3.14 ,-0.8, true);
    path.quadraticBezierTo(
        size.width * 0.995, size.height / 2, size.width * 0.975, 0.0);
    path.lineTo(size.width * 0.025, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
