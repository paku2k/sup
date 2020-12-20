import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../crypto.dart';

class CustomCardClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    Rect rect =
        Rect.fromLTRB(0.0, size.height / 2.0, size.width, size.height * 1.1);
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class Place {
  Place({this.id, this.name});
  String id;
  String name;
}

class FilterWidget extends StatefulWidget {
  final Function updateQuery;
  final Function finishFilter;
  Place _pickedPlace;
  FilterWidget({this.updateQuery, this.finishFilter});

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  final storage = new FlutterSecureStorage();


  TextEditingController _searchController = TextEditingController();
  Timer _throttle;
  int _calls = 0;

  String uuid;

  String _heading;
  final List<Place> _displayResults = [];
  final List<Widget> _displayResultsWidget = [];

  double radVal = 5.0;

  @override
  void initState() {
    super.initState();

    uuid = Uuid().v1();
    _heading = "Suggestions";
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _throttle.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
  }

  void _onSearchChanged() {
    if (_throttle?.isActive ?? false) _throttle.cancel();
    _throttle = Timer(const Duration(milliseconds: 400), () {
      getLocationResults(_searchController.text);
    });
  }

  void getLocationResults(String text) async {
    if (text.isEmpty) {
      setState(() {
        _heading = "Suggestions";
      });
      return;
    }
    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String type = '(regions)';
    String locRestr = 'location=50.748390, 9.935575&radius=600000&strictbounds';
    String request =
        '$baseUrl?input=$text&key=$PLACES_API&type=$type&$locRestr&sessiontoken=$uuid';
    print(request);
    Response response = await Dio().get(request);
    print(response);

    _calls++;

    final List<dynamic> predictions = response.data['predictions'];
    _displayResults.clear();
    predictions.forEach((element) {
      String id = element['place_id'];
      String name = element['description'];
      _displayResults.add(Place(name: name, id: id));
    });

    _displayResultsWidget.clear();
    _displayResults.forEach((element) {
      _displayResultsWidget.add(Padding(
        padding: EdgeInsets.only(bottom: 10, right: 15, top: 0, left: 15),
        child: RaisedButton(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () => _pickPlaceById(element.id),
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Text(element.name)),
          ]),
        ),
      ));
    });

    setState(() {
      _heading = "Results";
    });
  }

  void _pickPlaceById(String id) async {
    String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    String fields = 'geometry';
    String request =
        '$baseUrl?place_id=$id&key=$PLACES_API&fields=$fields&sessiontoken=$uuid';
    Response response = await Dio().get(request);

    final LatLng result = LatLng(
        (response.data['result']['geometry']['location']['lat']).toDouble(),
        (response.data['result']['geometry']['location']['lng']).toDouble());
    print(result.toString());
    widget.finishFilter(result);
  }

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 200,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(25.0))),
            padding: const EdgeInsets.symmetric(vertical: 00.0),
            child: Transform.translate(
              offset: Offset(0.0, -42.0),
              child: Card(
                color: Theme.of(context).buttonColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          child: Icon(
                        Icons.search,
                        color: Theme.of(context).buttonColor,
                        size: 35,
                      ))),
                ),
              ),
            ),
          ),

          Transform.translate(
            offset: Offset(0.0, -44.0),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: 'Suchen',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    fillColor: Color(0xFFEEEEEE),
                    filled: true),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0.0, -42.0),
            child: Container(
                color: Colors.white,
                child: Column(children: _displayResultsWidget)),
          ),
        ],
      ),
    );
  }
}
