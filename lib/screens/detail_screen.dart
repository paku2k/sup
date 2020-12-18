import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../screens/list_screen.dart';

import '../model/paddle_item.dart';
import '../ui-helper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DetailScreen extends StatefulWidget {
  final PaddleItem item;
  DetailScreen(this.item);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _visible=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          Container(),


          Hero(
            tag: widget.item.id,
            child: Container(
                width: double.infinity,
                height: screenHeight * 0.38,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  image: new DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(1), BlendMode.dstATop),
                    image: widget.item.imageAsset.length == 0
                        ? AssetImage(
                            'Paddleboard.jpg',
                          )
                        : NetworkImage(widget.item.imageAsset[0]),
                  ),
                )),
          ),
          Positioned(
            top: -100,
            left: 15,
            right: 15,

            child: FutureBuilder(future: Future.delayed(Duration(milliseconds: 250)),
                builder: (context, snapshot) {
                  if(snapshot.connectionState==ConnectionState.waiting){
                    _visible=false;              }
                  else{
                    _visible=true;
                  }

                  return AnimatedOpacity(
                    opacity: _visible?1.0:0.0,
                    duration: Duration(milliseconds: 300),
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(120))),
                      child: Padding(
                        padding: EdgeInsets.only(top: 130, bottom: 20, left: 20, right: 20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                            child: Container(child: Text(widget.item.title, style: TextStyle(fontSize: 30,),textAlign: TextAlign.center, overflow: TextOverflow.visible,))

                        ),
                      ),
                    ),
                  );


                }
            ),
          ),
//
          Positioned(
            top: screenHeight * 0.33,
            left: 15,
            right: 15,

            child: FutureBuilder(future: Future.delayed(Duration(milliseconds: 250)),
              builder: (context, snapshot) {
              if(snapshot.connectionState==ConnectionState.waiting){
_visible=false;              }
              else{
                _visible=true;
              }

              return AnimatedOpacity(
                opacity: _visible?1.0:0.0,
                duration: Duration(milliseconds: 300),
                child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 22),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children:  [
                            Container(
                              width: screenWidth*0.35,
                              child: FittedBox(
                                child: Text(widget.item.type==''?'':
                                  "SUP-${widget.item.type}",
                                  style: TextStyle(
                                      fontSize: 25, color: Theme
                                      .of(context)
                                      .accentColor),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                    widget.item.ratingNo.toString() +
                                        ' Bewertungen'),
                                Container(
                                  height: 60,
                                  width: 60,
                                  child: Stack(children: [
                                    Icon(
                                      Icons.star,
                                      size: 60,
                                      color: Theme
                                          .of(context)
                                          .accentColor,
                                    ),
                                    widget.item.rating == -1.0
                                        ? Center(
                                      child: Text('-/-'),
                                    )
                                        : Center(
                                        child: Text('${widget.item.rating}')),
                                  ]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              );

              }
            ),
          ),

          Positioned(
            top: screenHeight*0.45,
            left: 30,
            right: 30,
            bottom: 80,
            child: SingleChildScrollView(
              child: Text(
                widget.item.description ?? '',
                textScaleFactor: 1.4,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            width: screenWidth,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () {
                      MapsLauncher.launchCoordinates(
                          widget.item.location.latitude,
                          widget.item.location.longitude);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Theme.of(context).accentColor),
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.06,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Route  ",
                             style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Icon(
                              Icons.directions,
                              color: Colors.white,
                            )
                          ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Theme.of(context).accentColor),
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.06,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Bewerten  ",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Icon(
                              Icons.rate_review,
                              color: Colors.white,
                            )
                          ]),
                    ),
                  )
                ]),
          ),
        ],
      ),
    );
  }
}
