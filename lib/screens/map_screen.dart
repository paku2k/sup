import 'package:flutter/material.dart';
import 'package:sup/ui-helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../model/paddle_item.dart';
import '../widgets/simple_button.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  final bool locationPickerMode;
  final Function cameraStartedCallback;
  final Function startQuery;
  final Function locationPickerCallback;
  final Function cameraEndedCallback;
  final LatLng initialPosition;
  MapScreen(
      {Key key,
        this.cameraEndedCallback,
      this.locationPickerMode,
      this.locationPickerCallback,
      this.startQuery,
      this.cameraStartedCallback,
      this.initialPosition})
      : super(key: key);
  @override
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  bool cameraStopped = false;
  Location location = Location();
  LatLng userLocation;
  Set<Marker> markers = {};
  double zoomLevel=10;

  SharedPreferences prefs;

  GoogleMapController mapController;
  LocationData pos;

  Future<LocationData> animateToUserLocation() async {
    pos = await location.getLocation();
    userLocation=LatLng(pos.latitude, pos.longitude);
    prefs.setDouble('userLat', pos.latitude);
    prefs.setDouble('userLon', pos.longitude);

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(pos.latitude, pos.longitude), zoom: 13.0),
      ),
    );
    return pos;
  }

  void setItems(List<Marker> m) {
    markers.clear();
    m.forEach((element) {
      markers.add(element);
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userLocation=widget.initialPosition;
    return GoogleMap(
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      markers: markers,
      onTap: (_){
        widget.cameraStartedCallback();
      },
      onCameraMoveStarted: () {

        widget.cameraStartedCallback();
      },

      onCameraIdle: () {


          widget.cameraEndedCallback();

        cameraStopped = true;
      },

      myLocationEnabled:
          true, // Add little blue dot for device location, requires permission from user
      mapType: MapType.normal,

      initialCameraPosition: widget.initialPosition == null
          ? CameraPosition(target: LatLng(24.150, -110.32), zoom: 10)
          : CameraPosition(
              target: LatLng(widget.initialPosition.latitude,
                  widget.initialPosition.longitude),
              zoom: 13.0),
      onMapCreated: (controller) async {
        prefs = await SharedPreferences.getInstance();
        setState(() {
          mapController = controller;
        });
        final pos = await animateToUserLocation();
        widget.startQuery(LatLng(pos.latitude, pos.longitude));
      },
    );
  }
}
