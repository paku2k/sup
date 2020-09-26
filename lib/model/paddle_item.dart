import 'package:google_maps_flutter/google_maps_flutter.dart';

class PaddleItem{
  int type; //0=Einsetzstelle, 1=Shop, 2=Verleih, 3=Kurs, 4=Verbot, 5=Tour
  LatLng location;
  Marker marker;
  String title;
  String description;
  double difficulty;
  String userName;
  String userId;
  List<String> imageAsset;
  String id;
  double rating;
  int ratingNo;
  PaddleItem({this.title, this.description, this.difficulty, this.id, this.imageAsset, this.rating, this.ratingNo, this.userName,this.location, this.userId, this.type, this.marker});
}