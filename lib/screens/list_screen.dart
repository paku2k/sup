import 'package:flutter/material.dart';
import '../widgets/paddle_list_item.dart';
import '../model/paddle_item.dart';
import '../widgets/simple_button.dart';
import '../widgets/list_button.dart';
import '../ui-helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/slider_menu.dart';

class ListScreen extends StatefulWidget {
  final List<PaddleItem> items;
  final bool isOwnSpots;
  ListScreen({this.items, this.isOwnSpots});

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<PaddleItem> stateItems;

  @override
  void initState() {
    super.initState();
    widget.isOwnSpots
        ? stateItems = widget.items
            .where((element) =>
                element.userId == FirebaseAuth.instance.currentUser.uid)
            .toList()
        : stateItems = [...widget.items];
    _filterList();
  }

  String dropdownValue = 'Distance';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.isOwnSpots ? null : SliderMenu(stateItems),
      body: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: stateItems.length + 2,
              itemBuilder: (ctx, index) {
                if (index == 0) {
                  return Container(
                    height: 80,
                    width: double.infinity,
                  );
                }
                if(index == stateItems.length+1){
                  return Container(
                    height: 280,
                    width: double.infinity,
                  );
                }
                return PaddleListItem(stateItems[index - 1]);
              },
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: 15,
          right: 15,
          child: Card(
            color: Theme.of(context).buttonColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(120))),
            child: Padding(
              padding:
                  EdgeInsets.only(top: 130, bottom: 20, left: 20, right: 20),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      child: Text(
                        widget.isOwnSpots?'Deine Spots':
                    'Spots in der Nähe',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ))),
            ),
          ),
        ),
        SimpleButtonWidget(
          onTap: () {
            showFilter();
          },
          icon: Icons.filter_list,
          isTop: false,
          isLeft: true,
        ),
        widget.isOwnSpots
            ? SimpleButtonWidget(
                heroTag: 'back',
                icon: Icons.arrow_back,
                isTop: true,
                isLeft: true,
                onTap: () => Navigator.of(context).pop(),
              )
            : SimpleButtonWidget(
                heroTag: 'settings',
                icon: Icons.settings,
                isTop: true,
                isLeft: true,
                onTap: () => _scaffoldKey.currentState.openDrawer(),
              ),
        widget.isOwnSpots
            ? Container()
            : SimpleButtonWidget(
                heroTag: 'search',
                icon: Icons.search,
                isTop: true,
                isLeft: false,
                onTap: () => Navigator.of(context).pop(true),
                onDrag: (_) => Navigator.of(context).pop(true)),
        widget.isOwnSpots
            ? Container()
            : SimpleButtonWidget(
                icon: Icons.map,
                isTop: false,
                isLeft: false,
                onTap: () => Navigator.of(context).pop(false),
                onDrag: (_) => Navigator.of(context).pop(false) //showFilter(),
                ),
      ]),
    );
  }

  void showFilter() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0))),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                        child: Icon(
                      Icons.filter_list,
                      color: Colors.black54,
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: dropDownSort(),
                  ),
                ],
              ),
            ));
  }

  void _filterList() {
    if (dropdownValue == 'Distance') {
      stateItems.sort((PaddleItem a, PaddleItem b) {
        return ((a.distance - b.distance) * 1000).round();
      });
    }
    if (dropdownValue == 'Rating (value)') {
      stateItems.sort((PaddleItem a, PaddleItem b) {
        return ((a.rating - b.rating) * 1000).round();
      });
    }
    if (dropdownValue == 'Rating (number)') {
      stateItems.sort((PaddleItem a, PaddleItem b) {
        return ((a.ratingNo - b.ratingNo) * 1000).round();
      });
    }
    setState(() {
      print(stateItems);
    });
  }

  Widget dropDownSort() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.white,
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 20,
              elevation: 12,
              style:
                  TextStyle(color: Theme.of(context).accentColor, fontSize: 18),
              underline: Container(
                height: 2,
                color: Theme.of(context).accentColor,
              ),
              onChanged: (String val) {
                setState(() {
                  dropdownValue = val;
                  _filterList();
                });
              },
              items: <String>[
                'Distance',
                'Rating (value)',
                'Rating (number)',
              ]
                  .map<DropdownMenuItem<String>>(
                      (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ))
                  .toList(),
            )
          ]),
    );
  }
}

/*
* Custom container: width: 35, height:110
* erster punkt:
* control: (0,0.0727h) end: (0.286w, 0.1454h)
* zweiter punkt:
* control: (w-0.028w, h/2 - 0.1818h) end: (w, h/2)
* dritter punkt:
* control: (w+0.028w, h/2+0.1818h) end: (0.286w, h-0.1454h)
* vierter punkt:
* control: (0, h-0.0727h) end:(0, h)
* */

class CustomTitleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final w = size.width;
    final h = size.height;

    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(0.0727 * w, 0, 0.1454 * w, 0.286 * h);
    path.quadraticBezierTo(w / 2 - 0.1818 * w, h - 0.028 * h, w / 2, h);
    path.quadraticBezierTo(
        w / 2 + 0.1818 * w, h + 0.028 * h, w - 0.1454 * w, 0.286 * h);
    path.quadraticBezierTo(w - 0.0727 * w, 0, w, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
