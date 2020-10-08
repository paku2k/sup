import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sup/model/custom_marker.dart';

class PaddleItem{
  String type; //0=Einsetzstelle, 1=Shop, 2=Verleih, 3=Kurs, 4=Verbot, 5=Tour
  LatLng location;
  double distance;
  CustomMarker marker;
  String title;
  String description;
  double difficulty;
  String userName;
  String userId;
  List<dynamic> imageAsset;
  String id;
  double rating;
  int ratingNo;
  PaddleItem({this.distance,this.title, this.description, this.difficulty, this.id, this.imageAsset, this.rating, this.ratingNo, this.userName,this.location, this.userId, this.type, this.marker});
}