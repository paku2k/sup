import 'dart:typed_data';
import 'dart:ui' as ui;
import '../widgets/info_display.dart';

import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:platform/platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
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
import 'package:fluster/fluster.dart';

import '../model/custom_marker.dart';
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
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth;
  User userInfo;
  LatLng initPos;
  bool getFirstPosition;
  String userName;

  Widget markerWindow;
  Fluster<CustomMarker> fluster;
  Geoflutterfire geoflutterfire = Geoflutterfire();

  List<PaddleItem> paddleItems = [];

  BehaviorSubject<double> radius = BehaviorSubject();

  Stream<dynamic> query;
  GeoFirePoint center;

  BitmapDescriptor pinMarkerNorm;
  BitmapDescriptor clusterMarker;
  BitmapDescriptor pinMarkerVerbot;
  Uint8List rawImage;
  StreamSubscription subscription;

  Loc.Location location = Loc.Location();

  CustomAnimationControl _control = CustomAnimationControl.STOP;
  bool _isMap = true;
  double currentMapPosition = 0;
  List<CustomMarker> markers = [];
  double devicePixelRatio;
  double currentListPosition = -1.0;
  double zoomLevel;

  bool locationPickerMode = false;
  LatLng pickedLocation;
  double opacity = 0.0;
  bool markerWindowDirty = false;

  bool dirtyScreenPosition = true;
  double get _explorePercent {
    return screenWidth / currentMapPosition;
  }

  double get _listAbsolute {
    return screenWidth * currentListPosition + screenWidth;
  }

  @override
  void initState() {
    _initUser();
    radius.add(50.0);
    getFirstPosition = true;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'marker_zwei.png')
        .then((BitmapDescriptor value) => pinMarkerVerbot = value);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'marker_zwei.png')
        .then((value) => pinMarkerNorm = value);
    getBytesFromAsset('assets/m1.png', 200).then((value) {
      rawImage = value;
      clusterMarker = BitmapDescriptor.fromBytes(value);
    });

    super.initState();
  }

  void cameraStartedCallback() {
    if (markerWindow != null && !markerWindowDirty) {
      markerWindow = null;
    }
    _setFlusterMarkers();
    setState(() {
      dirtyScreenPosition = true;
    });
  }

  void cameraEndedCallback() {
    markerWindowDirty = false;
    _setFlusterMarkers();
    setState(() {
      dirtyScreenPosition = true;
    });
  }

  void _initUser() async {
    auth = FirebaseAuth.instance;
    userInfo = auth.currentUser;
    var userDoc = await firestore.collection('user').doc(userInfo.uid).get();
    userName = userDoc.data()['name'];
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

  void opacityCallback(double pcnt) {
    setState(() {
      opacity = pcnt;
    });
  }

  Future<double> _updateCenter(LatLng pos) async {
    LatLng screenPos;
    if (pos == null) {
      screenPos = await screenPosition();
    } else {
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
            FutureBuilder(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    getFirstPosition) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && getFirstPosition) {
                  var lat = snapshot.data.getDouble('userLat');
                  var lon = snapshot.data.getDouble('userLon');
                  if (lat != null && lon != null) {
                    initPos = LatLng(lat, lon);
                  }
                  getFirstPosition = false;
                }
                return MapScreen(
                  key: _mapKey,
                  locationPickerCallback: locationPickerCallback,
                  cameraEndedCallback: cameraEndedCallback,
                  locationPickerMode: locationPickerMode,
                  cameraStartedCallback: cameraStartedCallback,
                  startQuery: startQuery,
                  initialPosition: initPos,
                );
              },
            ),
            /*Transform.translate(
                offset: Offset(-(screenWidth - currentListPosition), 0),
                child: ListScreen(_listKey)),*/
            locationPickerMode
                ? Center(
                    child: Icon(
                    Icons.pin_drop,
                    color: Theme.of(context).accentColor,
                  ))
                : Container(),
            _isMap
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: _mapKey.currentState != null
                          ? locationPickerMode
                              ? RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  onPressed: _getScreenPosForAdd,
                                  child: Text("Choose this location"),
                                )
                              : dirtyScreenPosition
                                  ? RaisedButton(
                                      color: Theme.of(context).buttonColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      onPressed: () async {
                                        double visibleRadius =
                                            await _updateCenter(null);

                                        updateQuery(visibleRadius);
                                        setState(() {
                                          dirtyScreenPosition = false;
                                        });
                                      },
                                      child: Text("Search here"),
                                    )
                                  : Container()
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
            locationPickerMode
                ? Container()
                : ToggleButtonWidget(
                    currentX: _listAbsolute,
                    isMap: _isMap,
                    onDrag: (_) {
                      Navigator.of(context).push(_createRoute(paddleItems));
                    },
                    onTap: () {
                      Navigator.of(context).push(_createRoute(paddleItems));
                    },
                  ),
            opacity != 0
                ? BackdropFilter(
                    filter: ui.ImageFilter.blur(
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
            AddWidget(
              _addKey,
              opacityCallback,
              locationPickerCallback,
              addPaddleItem,
            ),
            markerWindow != null && !markerWindowDirty
                ? Positioned(
                    left: 0,
                    top: screenHeight * 0.5,
                    width: screenWidth,
                    child: markerWindow)
                : Container(),
          ]),
        ));
  }

  Route _createRoute(List<PaddleItem> items) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ListScreen(
          items: items,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        animation.addListener(() {
          setState(() {
            currentListPosition = animation.drive(tween).value.dx;
          });
        });
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
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
                _mapKey.currentState.cameraStopped = false;
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

  Future<void> addPaddleItem(LatLng pos, String name, String description,
      List<File> imageFile, String type) async {
    var uuid = Uuid();

    GeoFirePoint point =
        geoflutterfire.point(latitude: pos.latitude, longitude: pos.longitude);
    String imageId = uuid.v1();
    List<String> imageURLs = [];
    for (var i = 0; i < imageFile.length; i++) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('spot_images')
          .child(imageId)
          .child((i).toString() + '.jpg');
      await ref.putFile(imageFile[i]).onComplete;
      imageURLs.add(await ref.getDownloadURL());
    }

    await firestore.collection('spots').add({
      'imageURLs': imageURLs,
      'position': point.data,
      'title': name,
      'type': type,
      'description': description,
      'userId': userInfo.uid,
      'userName': userName,
      'rating': -1.0,
      'ratingNo': 0,
    });
    return;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _updateItems(List<DocumentSnapshot> docList) async {
    paddleItems.clear();
    markers.clear();
    print(docList);
    docList.forEach((DocumentSnapshot doc) {
      GeoPoint pos = doc.data()['position']['geopoint'];
      GeoFirePoint userLocation = GeoFirePoint(
          _mapKey.currentState.userLocation.latitude,
          _mapKey.currentState.userLocation.longitude);
      double distance =
          userLocation.distance(lat: pos.latitude, lng: pos.longitude);

      String title = doc.data()['title'];
      double rating = -1.0;
      if (doc.data()['rating'] != null) {
        rating = doc.data()['rating'].toDouble();
      }

      PaddleItem item = PaddleItem(
          distance: distance,
          id: doc.id,
          title: title,
          imageAsset: doc.data()['imageURLs'],
          description: doc.data()['description'],
          location: LatLng(pos.latitude, pos.longitude),
          userId: doc.data()['userId'],
          difficulty: doc.data()['difficulty'],
          rating: rating,
          ratingNo: doc.data()['ratingNo'],
          type: doc.data()['type'].toString(),
          userName: doc.data()['userName']);

      paddleItems.add(item);
    });
    paddleItems.forEach((element) {
      var marker = CustomMarker(
        onTap: () {
          setState(() {
            markerWindowDirty = true;

            markerWindow = InfoDisplay(element);
          });
        },
        id: element.id,
        position: element.location,
        icon: element.type == 'Verbot' ? pinMarkerVerbot : pinMarkerNorm,
      );
      markers.add(marker);
    });

    _setFlusterMarkers();
  }

  Future<void> _setFlusterMarkers() async {
    fluster = Fluster<CustomMarker>(
        minZoom: 0, // The min zoom at clusters will show
        maxZoom: 12, // The max zoom at clusters will show
        radius: 150, // Cluster radius in pixels
        extent: 1024, // Tile extent. Radius is calculated with it.
        nodeSize: 64, // Size of the KD-tree leaf node.
        points: markers, // The list of markers created before
        createCluster: (
          // Create cluster marker
          BaseCluster cluster,
          double lng,
          double lat,
        ) {
          return CustomMarker(
            id: cluster.id.toString(),
            position: LatLng(lat, lng),
            icon: clusterMarker,
            onTap: cluster.isCluster
                ? () {
                    var cu = CameraUpdate.newLatLngZoom(
                        LatLng(lat, lng), zoomLevel + 1.0);
                    _mapKey.currentState.mapController.animateCamera(cu);
                  }
                : null,
            isCluster: cluster.isCluster,
            clusterId: cluster.id,
            pointsSize: cluster.pointsSize,
            childMarkerId: cluster.childMarkerId,
          );
        });

    zoomLevel = await _mapKey.currentState.mapController.getZoomLevel();
    final List<Marker> googleMarkers = fluster
        .clusters([-180, -85, 180, 85], zoomLevel.round()).map((cluster) {
      return cluster.toMarker(
//              (){
//        //TODO: Add number of cluster children to image marker
//        var cu = CameraUpdate.newLatLngZoom(cluster.position, zoomLevel+1.0);
//        _mapKey.currentState.mapController.animateCamera(cu);}
          );
    }).toList();
    _mapKey.currentState.setItems(googleMarkers);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    print('Data: $data');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
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
