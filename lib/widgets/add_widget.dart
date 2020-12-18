import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../ui-helper.dart';
import 'dart:math';
import '../location_helper.dart';
import '../crypto.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final double _expandedWidth = 392.0;
final double _retractedWidth = 120.0;

class AddWidget extends StatefulWidget {
  final Function addGeoPoint;
  final Function opacityCallback;
  final Function locationPickerCallback;
  //final LatLng pickedLocation;
  AddWidget(Key key, this.opacityCallback, this.locationPickerCallback,
      this.addGeoPoint)
      : super(key: key);
  @override
  AddWidgetState createState() => AddWidgetState();
}

class AddWidgetState extends State<AddWidget> with TickerProviderStateMixin {
  String dropdownValue = 'Einstiegsstelle';
  final storage = FlutterSecureStorage();

  bool _isSaving = false;

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
    getRenderBox(null);
    animationControllerAdd = AnimationController(
        duration: Duration(
            milliseconds: 1 +
                (800 * (isExpanded ? currentPercent : (1 - currentPercent)))
                    .toInt()),
        vsync: this);
    curve = CurvedAnimation(
        parent: animationControllerAdd, curve: Curves.easeOutQuart);

    animation = Tween(begin: _currentX, end: open ? _renderHeight - 80.0 : 0.0)
        .animate(curve)
          ..addListener(() {
            setState(() {
              widget.opacityCallback(currentPercent);
              _currentX = animation.value;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (open == false) {
                widget.opacityCallback(0.0);
              }
              isExpanded = open;
            }
          });
    animationControllerAdd.forward();
  }

  @override
  void initState() {
    super.initState();
  }

  void getRenderBox(_) {
    final RenderBox _renderBoxContainer =
        _containerKey.currentContext.findRenderObject();
    _renderHeight = _renderBoxContainer.size.height;
    print('RenderHeight:' + _renderHeight.toString());
    print('RenderWidth:' + _renderBoxContainer.size.width.toString());
  }

  void onAddVerticalUpdate(details) {
    _currentX -= details.delta.dy;
    if (_currentX > _renderHeight - 80.0) {
      _currentX = _renderHeight - 80.0;
    } else if (_currentX < 0) {
      _currentX = 0;
    }
    widget.opacityCallback(currentPercent);
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

  Location locationHandle = Location();

  AnimationController animationControllerAdd;
  CurvedAnimation curve;
  Animation animation;

  final GlobalKey<FormState> _formKey = GlobalKey();

  GlobalKey _containerKey = GlobalKey();
  double _renderHeight;

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  LatLng location;

  List<File> _images = [];
  bool _imageDelete = false;
  bool _pickedImage = false;
  int _imageNumber = 0;
  bool isExpanded = false;
  String _type = 'Einstiegsstelle';

  bool _locationDelete = false;
  double _difficulty = 0.0;
  double _currentX = 0.0;
  String _title;
  String _description;

  AnimationController fabController;
  AnimationController fab2Controller;

  double get currentPercent {
    return _currentX / _renderHeight;
  }

  @override
  Widget build(BuildContext context) {
    fabController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..forward();
    fab2Controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..forward();

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
            onVerticalDragStart: getRenderBox,
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
                  _currentX != -1.0
                      ? SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height: 5,
                                ),
                                _buildLocationPicker(),
                                Form(
                                  key: _formKey,
                                  child: Column(children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              realW(_expandedWidth * 0.7)),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                          color: Colors.white,
                                        ),
                                        child: TextFormField(
                                          validator: (value) {
                                            Future.delayed(
                                              Duration(milliseconds: 20),
                                            ).then((value) => animateAdd(true));
                                            if (value.isEmpty) {
                                              return 'Bitte lege einen Titel fest';
                                            }

                                            return null;
                                          },
                                          onSaved: (value) => _title = value,
                                          controller: _titleController,
                                          decoration: InputDecoration(
                                            hintText: "Titel",
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              realW(_expandedWidth * 0.70)),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          color: Colors.white,
                                        ),
                                        child: TextFormField(
                                          onSaved: (value) =>
                                              _description = value,
                                          controller: _descriptionController,
                                          scrollPhysics:
                                              BouncingScrollPhysics(),
                                          minLines: 3,
                                          maxLines: 5,
                                          decoration: InputDecoration(
                                            hintText: "Beschreibung",
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: realW(_expandedWidth * 0.7)),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            "Type",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600]),
                                          ),
                                          SizedBox(width: 40),
                                          DropdownButton<String>(
                                            value: dropdownValue,
                                            icon: Icon(Icons.arrow_drop_down),
                                            iconSize: 20,
                                            elevation: 12,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor,
                                                fontSize: 18),
                                            underline: Container(
                                              height: 2,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                            onChanged: (String val) {
                                              setState(() {
                                                dropdownValue = val;
                                                _type = val;
                                              });
                                            },
                                            items: <String>[
                                              'Einstiegsstelle',
                                              'Tour',
                                              'Verleih',
                                              'Kurs',
                                              'Shop',
                                              'Verbot'
                                            ]
                                                .map<DropdownMenuItem<String>>(
                                                    (e) => DropdownMenuItem<
                                                            String>(
                                                          value: e,
                                                          child: Text(e),
                                                        ))
                                                .toList(),
                                          )
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                /* ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: realW(_expandedWidth * 0.85),
                                maxHeight: 30),
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
                          ),*/
                                _buildImagePicker(),
                                RaisedButton(
                                  color: Theme.of(context)
                                      .floatingActionButtonTheme
                                      .backgroundColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  onPressed: () async {
                                    if (location == null ||
                                        !_formKey.currentState.validate()) {
                                      _formKey.currentState.validate();
                                      if (location == null) {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Bitte lege einen Standort fest'),
                                          duration:
                                              Duration(milliseconds: 2000),
                                        ));
                                      }
                                    } else {
                                      setState(() {
                                        _isSaving = true;
                                      });
                                      _formKey.currentState.save();
                                      await widget.addGeoPoint(
                                        LatLng(location.latitude,
                                            location.longitude),
                                        _title,
                                        _description,
                                        _images,
                                        _type,
                                      );
                                      print('finished');
                                      _isSaving = false;
                                      animateAdd(false);
                                      _formKey.currentState.reset();
                                      _pickedImage=false;
                                      _images=[];
                                      _imageNumber=0;
                                      _imageDelete=false;
                                      _locationDelete=false;
                                      _descriptionController.text="";
                                      _titleController.text="";
                                      _title="";
                                      _description="";
                                      _type="Einstiegsstelle";
                                      location=null;
                                    }
                                    setState(() {});
                                  },
                                  child: _isSaving
                                      ? Transform.scale(
                                          scale: 0.7,
                                          child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,))
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                              Text("Fertig"),
                                              Icon(Icons.check)
                                            ]),
                                ),
                              ]),
                        )
                      : SizedBox(
                          height: screenHeight - 55,
                          width: 10,
                        ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    //TODO: Build a carousel with more than one image
    return SizedBox(
      width: realW(_expandedWidth - 70.0),
      height: realH(200.0),
      child: Center(
        child: _pickedImage
            ? Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      fabController.forward();
                      _imageDelete = !_imageDelete;
                    });
                  },
                  child: Container(
                    height: realH(200.0),
                    child: Stack(children: [
                      ClipPath(
                        clipper: CustomClipImage(),
                        child: Image.file(
                          _images[_imageNumber - 1],
                          width: realW(_expandedWidth - 50.0),
                          height: realH(200.0),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_imageDelete)
                        Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                SizedBox(width: 20),
                                AnimatedBuilder(
                                  animation: fabController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: fabController.value * 1.2,
                                      child: Transform.rotate(
                                        angle: fabController.value * 1.0 * pi,
                                        child: FloatingActionButton(
                                          heroTag: null,
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: Icon(Icons.add),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 20.0),
                                AnimatedBuilder(
                                  animation: fabController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: fabController.value * 1.2,
                                      child: Transform.rotate(
                                        angle: (fabController.value + 1) *
                                            1.0 *
                                            pi,
                                        child: FloatingActionButton(
                                          heroTag: null,
                                          onPressed: () {
                                            setState(() {
                                              _pickedImage = false;
                                              _imageDelete=false;
                                            });
                                          },
                                          child: Icon(Icons.delete),
                                        ),
                                      ),
                                    );
                                  },
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
                      'Bild',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        FloatingActionButton(
                          heroTag: null,
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final _imageResource = await picker.getImage(
                                source: ImageSource.gallery,
                                maxWidth: 1000,
                                imageQuality: 50);
                            if (_imageResource != null) {
                              _images.add(File(_imageResource.path));
                              setState(() {
                                _imageNumber++;
                                _pickedImage = true;
                                _imageDelete = false;
                              });
                            }
                          },
                          child: Icon(Icons.image),
                        ),
                        SizedBox(width: 15.0),
                        FloatingActionButton(
                          heroTag: null,
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final _imageResource = await picker.getImage(
                                source: ImageSource.camera,
                                maxWidth: 1000,
                                imageQuality: 50);
                            if (_imageResource != null) {
                              _images.add(File(_imageResource.path));
                              setState(() {
                                _imageNumber++;
                                _pickedImage = true;
                                _imageDelete = false;
                              });
                            }
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
        child: location != null
            ? Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      fab2Controller.forward();
                      _locationDelete = !_locationDelete;
                    });
                  },
                  child: Container(
                    width: realW(_expandedWidth - 170.0),
                    height: realH(150.0),
                    child: Stack(children: [
                      ClipPath(
                        clipper: CustomClipMap(),
                        child: Stack(children: [
                          Center(
                            child: Image.network(
                              LocationHelper.generateLocationPreviewImage(
                                  lat: location.latitude,
                                  lon: location.longitude,
                                  GOOGLE_API_KEY: GOOGLE_API),
                              width: realW(_expandedWidth - 50.0),
                              height: realH(200.0),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Center(
                              child: Transform.translate(
                            offset: Offset(0, -20),
                            child: Image.asset(
                              dropdownValue == 'Verbot'
                                  ? 'verbot-pin.png'
                                  : 'marker_zwei.png',
                              height: 50,
                            ),
                          )),
                        ]),
                      ),
                      if (_locationDelete)
                        Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                SizedBox(width: 20.0),
                                AnimatedBuilder(
                                  animation: fab2Controller,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: fab2Controller.value * 1.2,
                                      child: Transform.rotate(
                                        angle: (fab2Controller.value + 1) *
                                            1.0 *
                                            pi,
                                        child: FloatingActionButton(
                                          heroTag: null,
                                          onPressed: () {
                                            setState(() {
                                              location = null;
                                              _locationDelete=false;
                                            });
                                          },
                                          child: Icon(Icons.delete),
                                        ),
                                      ),
                                    );
                                  },
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
                      'Lage',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 30.0),
                    Row(
                      children: [
                        FloatingActionButton(
                          heroTag: null,
                          onPressed: () {
                            animateAdd(false);
                            widget.locationPickerCallback();
                          },
                          child: Icon(Icons.location_on),
                        ),
                        SizedBox(width: 15.0),
                        FloatingActionButton(
                          heroTag: null,
                          onPressed: () async {
                            var pos = await locationHandle.getLocation();
                            setState(() {
                              location = LatLng(pos.latitude, pos.longitude);
                            });
                          },
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
