import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
class CustomMarker extends Clusterable {
  final String id;
  final LatLng position;
  final BitmapDescriptor icon;
  final InfoWindow infoWindow;
  final Function onTap;
  CustomMarker({
    this.onTap,
    this.infoWindow,
    @required this.id,
    @required this.position,
    @required this.icon,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
    markerId: id,
    latitude: position.latitude,
    longitude: position.longitude,
    isCluster: isCluster,
    clusterId: clusterId,
    pointsSize: pointsSize,
    childMarkerId: childMarkerId,
  );
  Marker toMarker() {
    return Marker(

    infoWindow: infoWindow,
    onTap: onTap,
    markerId: MarkerId(id),
    position: LatLng(
      position.latitude,
      position.longitude,
    ),
    icon: icon,
  );}
}