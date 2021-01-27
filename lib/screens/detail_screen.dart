import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../providers/user.dart';
import '../model/review.dart';
import '../screens/list_screen.dart';
import '../widgets/reviews_sheet.dart';
import '../widgets/review_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  PersistentBottomSheetController sheetController;
  bool _visible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: FutureBuilder(
                future: Future.delayed(Duration(milliseconds: 250)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    _visible = false;
                  } else {
                    _visible = true;
                  }

                  return AnimatedOpacity(
                    opacity: _visible ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Card(
                      color: Colors.blueGrey,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(120))),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 130, bottom: 20, left: 20, right: 20),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                child: Text(
                              widget.item.title,
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            ))),
                      ),
                    ),
                  );
                }),
          ),
//
          Positioned(
            top: screenHeight * 0.33,
            left: 15,
            right: 15,
            child: FutureBuilder(
                future: Future.delayed(Duration(milliseconds: 250)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    _visible = false;
                  } else {
                    _visible = true;
                  }

                  return AnimatedOpacity(
                    opacity: _visible ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          GestureDetector(
                            onTap: () {
                              MapsLauncher.launchCoordinates(
                                  widget.item.location.latitude,
                                  widget.item.location.longitude);
                            },
                            child: Card(
                              color: Theme.of(context).buttonColor,
                              elevation: 15,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20, bottom: 20, left: 20, right: 20),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: screenWidth * 0.33,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Route  ",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          Icon(
                                            Icons.directions,
                                            color: Colors.white,
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showReview();
                            },
                            child: Card(
                              color: Theme.of(context).buttonColor,
                              elevation: 15,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20, bottom: 20, left: 20, right: 20),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: screenWidth * 0.33,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Bewerten  ",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          Icon(
                                            Icons.rate_review,
                                            color: Colors.white,
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),

          Positioned(
            top: screenHeight * 0.43,
            left: 30,
            right: 30,
            bottom: 80,
            child: Column(
              children: [
                Container(
                  width: screenWidth * 0.35,
                  child: FittedBox(
                    child: Text(
                      widget.item.type == '' ? '' : "SUP-${widget.item.type}",
                      style: TextStyle(
                          fontSize: 25, color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  child: Text(
                    widget.item.description ?? '',
                    textScaleFactor: 1.4,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: -5,
            left: 5,
            right: 5,
            height: screenHeight * 0.85,
            child: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('spots')
                  .doc(widget.item.id)
                  .collection('ratings')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasData && snapshot.data != null) {
                  List<QueryDocumentSnapshot> docs = snapshot.data.docs;
                  List<Review> reviews = [];

                  docs.forEach((QueryDocumentSnapshot e) {
                    reviews.add(Review(
                        text: e.data()['text'],
                        userName: e.data()['userName'],
                        uid: e.data()['user'],
                        rating: e.data()['rating']));
                  });
                  return DraggableScrollableSheet(
                      maxChildSize: 1.0,
                      minChildSize: 0.25,
                      initialChildSize: 0.29,
                      builder: (ctx, controller) {
                        return ReviewsSheet(
                          item: widget.item,
                          submit: () {},
                          scrollController: controller,
                          ratings: reviews,
                        );
                      });

                  //return DraggableScrollableSheet(builder: (ctx, controller){
                  //return Text(snapshot.data.toString());
                  // });
                } else {
                  return Text('No reviews yet');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void showReview() {
    showModalBottomSheet(

      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReviewWidget(
            submit: submitReview,
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),

        ],
      );}
    );
  }

  Future<void> submitReview(String text, double rating) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('spots')
        .doc(widget.item.id)
        .collection('ratings')
        .add({
      'text': text,
      'rating': rating,
      'user': uid,
      'userName': userName,
    });

    setState(() {
      widget.item.ratingNo++;
      widget.item.rating =
          (widget.item.rating * (widget.item.ratingNo - 1) + rating) /
              widget.item.ratingNo;
    });

    await firestore.collection('spots').doc(widget.item.id).update({
      'ratingNo': widget.item.ratingNo,
      'rating': widget.item.rating,
    });

    return;
  }
}
