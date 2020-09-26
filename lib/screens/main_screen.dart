import 'dart:ui';

import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:platform/platform.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import '../animations/circleBoxAnimation.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as Loc;
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import '../widgets/filter_sheet.dart';
import '../ui-helper.dart';
import 'package:simple_animations/simple_animations.dart';
import '../widgets/list_button.dart';
import '../widgets/add_widget.dart';
import '../widgets/simple_button.dart';
import '../model/paddle_item.dart';
import '../screens/map_screen.dart';
import '../screens/list_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MainScreen> {
  Firestore firestore = Firestore();
  FirebaseAuth auth;
  UserInfo userInfo;
  String userName;
  Geoflutterfire geoflutterfire = Geoflutterfire();

  List<PaddleItem> paddleItems = [];

  BehaviorSubject<double> radius = BehaviorSubject();

  Stream<dynamic> query;
  GeoFirePoint center;

  BitmapDescriptor pinMarker;
  StreamSubscription subscription;

  Loc.Location location = Loc.Location();

  CustomAnimationControl _control = CustomAnimationControl.STOP;
  bool _isMap = true;
  double currentMapPosition = 0;
  double currentListPosition = 0;
  Set<Marker> markers = {};
  double devicePixelRatio;

  bool locationPickerMode = false;
  LatLng pickedLocation;
  double opacity = 0.0;
  bool cameraStopped=false;
  double get _explorePercent {
    return screenWidth / currentMapPosition;
  }

  double get _listPercent {
    return screenWidth / currentListPosition;
  }



  @override
  void initState() {
    _initUser();
    radius.add(50.0);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'marker_zwei.png')
        .then((value) => pinMarker = value);
    super.initState();
  }

  void cameraStoppedCallback(){
    setState(() {
      cameraStopped=true;
    });
  }

  void _initUser() async {
    auth = FirebaseAuth.instance;
    userInfo = await auth.currentUser();
    var userDoc =
        await firestore.collection('user').document(userInfo.uid).get();
    userName = userDoc.data['name'];
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  void locationPickerCallback() {
    setState(() {
      locationPickerMode = true;
      _isMap = true;
    });
  }

  void listOnDragUpdate(DragUpdateDetails position) {
    setState(() {
      currentListPosition = currentListPosition + position.delta.dx;
    });
  }

  void opacityCallback(double pcnt) {
    setState(() {
      opacity = pcnt;
    });
  }

  Future<double> _updateCenter(LatLng pos) async {
    LatLng screenPos;
    if(pos==null){
      screenPos = await screenPosition();

    }
    else{
      screenPos = pos;
    }
    final LatLngBounds zoomLevel =
        await _mapKey.currentState.mapController.getVisibleRegion();
    setState(() {
      center = geoflutterfire.point(
          latitude: screenPos.latitude, longitude: screenPos.longitude);
    });
    return calculateDistance(
            zoomLevel.southwest.latitude,
            zoomLevel.southwest.longitude,
            zoomLevel.northeast.latitude,
            zoomLevel.northeast.longitude) /
        2.0;
  }

  final _mapKey = GlobalKey<MapScreenState>();
  final _addKey = GlobalKey<AddWidgetState>();
  final _listKey = GlobalKey<ListScreenState>();

  @override
  Widget build(BuildContext context) {
    devicePixelRatio = TargetPlatform.android == Theme.of(context).platform
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(children: [
            MapScreen(
              key: _mapKey,
              locationPickerCallback: locationPickerCallback,
              locationPickerMode: locationPickerMode,
              cameraStoppedCallback: cameraStoppedCallback,
              startQuery: startQuery,
            ),
            Transform.translate(
                offset: Offset(-(screenWidth - currentListPosition), 0),
                child: ListScreen(_listKey)),
            locationPickerMode
                ? Center(child: Icon(Icons.pin_drop))
                : Container(),
            _isMap
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: _mapKey.currentState != null
                          ? locationPickerMode
                              ? RaisedButton(
                                  color: Theme.of(context).buttonColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  onPressed: _getScreenPosForAdd,
                                  child: Text("Choose this location"),
                                )
                              : RaisedButton(
                                  color: Theme.of(context).buttonColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  onPressed: () async {
                                    double visibleRadius =
                                        await _updateCenter(null);

                                    updateQuery(visibleRadius);
                                  },
                                  child: Text("Search here"),
                                )
                          : Container(),
                    ),
                  )
                : Container(),
            SimpleButtonWidget(
              onTap: _isMap
                  ? () {
                      _mapKey.currentState.animateToUserLocation();
                    }
                  : () {
                      showFilter();
                    },
              icon: _isMap ? Icons.my_location : Icons.filter_list,
              isTop: false,
              isLeft: false,
            ),
            locationPickerMode
                ? Container()
                : SimpleButtonWidget(
                    icon: Icons.settings,
                    isTop: true,
                    isLeft: true,
                  ),
            SimpleButtonWidget(
              icon: Icons.search,
              isTop: true,
              isLeft: false,
              onTap: () => showFilter(),
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
            locationPickerMode
                ? Container()
                : ToggleButtonWidget(
                    currentX: currentListPosition,
                    isMap: _isMap,
                    onUpdate: listOnDragUpdate,
                    onTap: () {
                      setState(() {
                        _isMap = !_isMap;
                      });
                    },
                  ),
            AddWidget(_addKey, opacityCallback, locationPickerCallback,
                addPaddleItem),
          ]),
        ));
  }

  void showFilter() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FilterWidget(
              updateQuery: updateQuery,
              finishFilter: (LatLng target) async {
                Navigator.of(context).pop();
                _mapKey.currentState.cameraStopped=false;
                _mapKey.currentState.mapController
                    .animateCamera(CameraUpdate.newLatLngZoom(target, 11.50));


                final radius = await _updateCenter(target);
                updateQuery(10.0);

              },
            ));
  }

  void updateQuery(double value) {
    setState(() {
      radius.add(value);
    });
  }

  void startQuery(LatLng centerPosition) async {
    double lat = centerPosition.latitude;
    double lon = centerPosition.longitude;

    var ref = firestore.collection('spots');
    center = geoflutterfire.point(latitude: lat, longitude: lon);

    subscription = radius.switchMap((rad) {
      print(
          'Resubscribing: Center point: ${center.latitude.toString()}, ${center.longitude.toString()}, and radius: ${rad.toString()}');
      return geoflutterfire.collection(collectionRef: ref).within(
          center: center, radius: rad, field: 'position', strictMode: true);
    }).listen(_updateItems);
  }

  Future<DocumentReference> addPaddleItem(LatLng pos, String name,
      String description, double difficulty, int type) async {
    GeoFirePoint point =
        geoflutterfire.point(latitude: pos.latitude, longitude: pos.longitude);

    return firestore.collection('spots').add({
      'position': point.data,
      'title': name,
      'type': type,
      'description': description,
      'difficulty': difficulty,
      'userId': userInfo.uid,
      'userName': userName,
      'rating': -1.0,
      'ratingNo': 0,
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _updateItems(List<DocumentSnapshot> docList) {
    paddleItems.clear();
    docList.forEach((DocumentSnapshot doc) {
      GeoPoint pos = doc.data['position']['geopoint'];
      String title = doc.data['title'];
      double rating;
      if (doc.data['rating'] != null) {
        double rating = doc.data['rating'].toDouble();
      }
      var marker = Marker(
        markerId: MarkerId(doc.documentID),
        position: LatLng(pos.latitude, pos.longitude),
        icon: pinMarker,
        infoWindow: InfoWindow(title: title, snippet: doc.data['description']),
      );

      PaddleItem item = PaddleItem(
          id: doc.documentID,
          marker: marker,
          title: title,
          description: doc.data['description'],
          location: LatLng(pos.latitude, pos.longitude),
          userId: doc.data['userId'],
          difficulty: doc.data['difficulty'],
          rating: rating,
          ratingNo: doc.data['ratingNo'],
          type: doc.data['type'],
          userName: doc.data['userName']);

      paddleItems.add(item);
    });
    _mapKey.currentState.setItems(paddleItems);
    print(paddleItems.toString());
  }

  Future<LatLng> screenPosition() {
    if (_mapKey.currentState.mapController != null) {
      return _mapKey.currentState.mapController.getLatLng(ScreenCoordinate(
          x: (_mapKey.currentState.context.size.width * devicePixelRatio) ~/
              2.0,
          y: (_mapKey.currentState.context.size.height * devicePixelRatio) ~/
              2.0));
    } else {
      return null;
    }
  }

  void _getScreenPosForAdd() async {
    final screenPos = await screenPosition();

    setState(() {
      pickedLocation = screenPos;
      _addKey.currentState.location = pickedLocation;
      _addKey.currentState.animateAdd(true);
      locationPickerMode = false;
    });
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
