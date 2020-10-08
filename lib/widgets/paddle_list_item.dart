import 'package:flutter/material.dart';
import '../model/paddle_item.dart';
import '../screens/detail_screen.dart';
import 'package:sup/ui-helper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PaddleListItem extends StatefulWidget {
  final PaddleItem item;
  PaddleListItem(this.item);

  @override
  _PaddleListItemState createState() => _PaddleListItemState();
}

class _PaddleListItemState extends State<PaddleListItem>
    with TickerProviderStateMixin {
  double width = screenWidth * 0.5;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                      maxRadius: 30,
                      minRadius: 30,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          widget.item.distance.toStringAsFixed(1) + '\nkm',
                          textAlign: TextAlign.center,
                        ),
                      )),
                  SizedBox(
                    width: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: width,
                          child: Text(
                            widget.item.title,
                            style: Theme.of(context).textTheme.headline6,
                          )),
                      Text(
                        widget.item.type,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Theme.of(context).accentColor),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: Icon(_expanded
                              ? Icons.expand_less
                              : Icons.expand_more),
                          onPressed: () => setState(() {
                            _expanded = !_expanded;
                          }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
              height: _expanded ? 220 : 0.0,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  GestureDetector(
                    onTap:(){Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>DetailScreen(widget.item)));},
                    child: Hero(
                      tag: widget.item.id,
                      child: Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(20)),
                            color: Colors.white,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.dstATop),
                              image: widget.item.imageAsset.length == 0
                                  ? AssetImage(
                                      'Paddleboard.jpg',
                                    )
                                  : NetworkImage(widget.item.imageAsset[0]),
                            ),
                          )),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        widget.item.description ?? '',
                        textScaleFactor: 1.3,
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Row(children: [
                      RatingBarIndicator(
                        rating: widget.item.rating == -1.0
                            ? 0.0
                            : widget.item.rating,
                        unratedColor: widget.item.rating == -1.0
                            ? Colors.black54
                            : Colors.grey[400],
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
                      SizedBox(width: 10),
                      widget.item.rating == -1.0
                          ? Text('(No votes)')
                          : Text('(${widget.item.rating})'),
                    ]),
                  ),
                ],
              ),
            )
          ])),
    );
  }
}
