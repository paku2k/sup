import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../ui-helper.dart';
import '../model/paddle_item.dart';
import '../model/review.dart';

class ReviewsSheet extends StatefulWidget {
  final Function submit;
  final PaddleItem item;
  final ScrollController scrollController;
  final List<Review> ratings;
  ReviewsSheet({this.submit, this.scrollController, this.ratings, this.item});
  @override
  _ReviewsSteetState createState() => _ReviewsSteetState();
}

class _ReviewsSteetState extends State<ReviewsSheet> {

  bool reviewLoading = false;
  double rating = 5.0;
  String reviewText = '';
  TextEditingController ratingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 30,
          bottom: 0,
          left: 0,
          right: 0,
          child: Card(
            elevation: 50,
            color: Theme.of(context).buttonColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overScroll) {
                overScroll.disallowGlow();
                return;
              },
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: widget.scrollController,
                  itemCount: widget.ratings.length + 1,
                  itemBuilder: (ctx, index) {
                    if (index == 0) {
                      return SizedBox(height: 25);
                    }
                    index = index - 1;
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 20.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        elevation: 5,
                        color: Colors.white,
                        child: ListTile(
                          title: RatingBarIndicator(
                            rating: widget.ratings[index].rating,
                            unratedColor: Colors.grey[400],
                            itemBuilder: (context, index) {
                              return Icon(
                                Icons.star,
                                color: Theme.of(context).accentColor,
                              );
                            },
                            itemCount: 5,
                            itemSize: 30.0,
                            direction: Axis.horizontal,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height:8),

                              Text(widget.ratings[index].text, style: Theme.of(context).textTheme.subtitle1,),
                            ],
                          ),
                          trailing: FittedBox(child: Text("~"+widget.ratings[index].userName, style: Theme.of(context).textTheme.subtitle1.copyWith(color: Theme.of(context).accentColor),), ),
                          leading: CircleAvatar(
                            child: Text(
                                widget.ratings[index].userName.substring(0, 1).toUpperCase()),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Card(
            color: Colors.blueGrey,
            elevation: 15,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.item.ratingNo.toString() + ' Bewertungen',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Container(
                      height: 60,
                      width: 60,
                      child: Stack(children: [
                        Icon(
                          Icons.star,
                          size: 60,
                          color: Theme.of(context).accentColor,
                        ),
                        widget.item.rating == -1.0
                            ? Center(
                                child: Text('-/-'),
                              )
                            : Center(child: Text('${widget.item.rating}')),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/*
import 'package:flutter/material.dart';
import '../model/review.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class ReviewsSheet extends StatefulWidget {
  List<Review> items;
  ReviewsSheet({this.items});

  @override
  _ReviewsSheetState createState() => _ReviewsSheetState();
}

class _ReviewsSheetState extends State<ReviewsSheet> {


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          print(widget.items[index].text);
          return Card(
            child: ListTile(
              title: RatingBarIndicator(
                rating: widget.items[index].rating,
                unratedColor: Colors.grey[400],
                itemBuilder: (context, index) {
                  return Icon(
                    Icons.star,
                    color: Theme.of(context).accentColor,
                  );
                },
                itemCount: 5,
                itemSize: 40.0,
                direction: Axis.horizontal,
              ),
              subtitle: Text(widget.items[index].text),
              leading: CircleAvatar(
                child: Text(
                    widget.items[index].userName.substring(0, 1)),
              ),
            ),
          );
        },
      ),
    );
  }
}*/
