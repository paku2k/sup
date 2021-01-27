import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../ui-helper.dart';



class ReviewWidget extends StatefulWidget {
  final Function submit;
  final ScrollController scrollController;
  ReviewWidget({this.submit, this.scrollController});
  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {

  bool reviewLoading = false;
  double rating = 5.0;
  String reviewText = '';
  double stateRating=4.5;
  TextEditingController ratingController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return StatefulBuilder(builder: (ctx, setState) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          color: Colors.white,
        ),
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
                          Icons.rate_review,
                          size: 35,
                        ))),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(children: [
                Transform.translate(
                  offset: Offset(0.0, -42.0),
                  child: Container(
                      color: Colors.white,
                      child: StatefulBuilder(
                        builder: (ctx, setState){ return Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RatingBar(

                                    itemSize: screenWidth / 8.0,
                                    initialRating: 4.5,
                                    minRating: 0,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Theme.of(context).accentColor,
                                        ),
                                    onRatingUpdate: (rating) {

                                      print(
                                       "called state rating"
                                      );
                                      setState(() {

                                        stateRating = rating;
                                      });
                                    }),
                                GestureDetector(
                                  child: Text(
                                    stateRating.toString(),
                                    textScaleFactor: 1.4,
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),
                                )
                              ]);}
                      ),
                      ),
                ),
                SizedBox(
                  height: 30,
                ),
                Transform.translate(
                  offset: Offset(0.0, -42.0),
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          reviewText = value;
                        });
                      },
                      scrollPadding: EdgeInsets.all(5),
                      minLines: 1,
                      maxLines: 10,
                      controller: ratingController,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 20),
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Bewerten...',
                        icon: reviewLoading
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                SizedBox(
                                  width: 6,
                                ),
                                CircularProgressIndicator(),
                                SizedBox(
                                  width: 6,
                                )
                              ])
                            : reviewText != ''
                                ? IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        this.reviewLoading = true;
                                      });
                                      await widget.submit(
                                        this.reviewText,
                                        this.rating,
                                      );

                                      setState(() {
                                        this.reviewLoading = false;
                                      });
                                      await Future.delayed(
                                          Duration(milliseconds: 500));
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(
                                      Icons.check,
                                      size: 40,
                                    ),
                                    color: Colors.green,
                                  )
                                : IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.create,
                                      size: 40,
                                    ),
                                    color: Theme.of(context).buttonColor,
                                  ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                              style: BorderStyle.solid),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: Theme.of(context).buttonColor,
                              width: 2.0,
                              style: BorderStyle.solid),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      ),
                    ),
                  ),
                ),
              ]),
            )
          ],
        ),

      );
  }
    );
  }
}
