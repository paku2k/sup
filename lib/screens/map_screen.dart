import 'package:flutter/material.dart';
import 'package:sup/ui-helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../widgets/simple_button.dart';
import 'dart:ui';

class MapScreen extends StatefulWidget {
  MapScreen({Key key}):super(key:key);
  @override

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {

  Location location = Location();
  GoogleMapController mapController;

  void animateToUserLocation() async {
    var pos = await location.getLocation();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 17.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationEnabled:
          true, // Add little blue dot for device location, requires permission from user
      mapType: MapType.hybrid,

      initialCameraPosition:
          CameraPosition(target: LatLng(24.150, -110.32), zoom: 10),
      onMapCreated: (controller) {
        setState(() {
          mapController = controller;
        });
      },
    );
  }
}
