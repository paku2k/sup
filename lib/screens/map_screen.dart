import 'package:flutter/material.dart';
import 'package:sup/ui-helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../model/paddle_item.dart';
import '../widgets/simple_button.dart';
import 'dart:ui';

class MapScreen extends StatefulWidget {
  final bool locationPickerMode;
  final Function cameraStoppedCallback;
  final Function startQuery;
  final Function locationPickerCallback;
  MapScreen(
      {Key key,
      this.locationPickerMode,
      this.locationPickerCallback,
      this.startQuery, this.cameraStoppedCallback})
      : super(key: key);
  @override
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  bool cameraStopped = false;
  Location location = Location();
  Set<Marker> markers = {};

  GoogleMapController mapController;
  LocationData _pos;

  Future<LocationData> animateToUserLocation() async {
    _pos = await location.getLocation();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(_pos.latitude, _pos.longitude), zoom: 13.0),
      ),
    );
    return _pos;
  }

  void setItems(List<PaddleItem> m) {
    markers.clear();
    m.forEach((element) {
      markers.add(element.marker);
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      markers: markers,
      onCameraMoveStarted: () {
        print('camera started');
        setState(() {
          cameraStopped = false;
        });

      },
      onCameraIdle: () {
        print('camera idle');
        setState(() {
          cameraStopped = true;
          widget.cameraStoppedCallback();
        });

      },
      myLocationEnabled:
          true, // Add little blue dot for device location, requires permission from user
      mapType: MapType.normal,

      initialCameraPosition: _pos == null
          ? CameraPosition(target: LatLng(24.150, -110.32), zoom: 10)
          : CameraPosition(target: LatLng(_pos.latitude, _pos.longitude)),
      onMapCreated: (controller) async {
        setState(() {
          mapController = controller;
        });
        final pos = await animateToUserLocation();
        widget.startQuery(LatLng(pos.latitude, pos.longitude));
      },
    );
  }
}
