import 'package:flutter/material.dart';
import 'package:drawerbehavior/drawerbehavior.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/paddle_item.dart';
import '../screens/list_screen.dart';

class SliderMenu extends StatelessWidget {
  final List<PaddleItem> items;
  SliderMenu(this.items);

  Widget _buildListTile(String title, IconData iconData, Function tapHandler, BuildContext context) {


    return ListTile(
      onTap: tapHandler,
      leading: Icon(
        iconData,
        size: 26,
          color: Theme.of(context).accentColor
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Stack(
        children: [
          Positioned(
            top: 100,
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              SizedBox(
                height: 20,
              ),
              _buildListTile('Favoriten', Icons.star,
                      () async {showDialog(context: context, builder: (context) => AlertDialog(
                    title: Text('Hier werden bald deine Favoriten erscheinen'),
                    actions: [
                      FlatButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close),
                        label: Text('Nein'),
                      ),
                      FlatButton.icon(
                        onPressed: () { FirebaseAuth.instance.signOut();
                        Navigator.of(context).pop();},
                        icon: Icon(Icons.check),
                        label: Text('Ja'),
                      ),
                    ],
                  ),);}, context),
              _buildListTile('Meine Spots', Icons.location_on,
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListScreen(items: items, isOwnSpots: true),)), context),
              _buildListTile(
                  'Ausloggen',
                  Icons.exit_to_app,
                  () async {showDialog(context: context, builder: (context) => AlertDialog(
                            title: Text('Möchtest du dich ausloggen?'),
                            actions: [
                              FlatButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(Icons.close),
                                label: Text('Nein'),
                              ),
                              FlatButton.icon(
                                onPressed: () { FirebaseAuth.instance.signOut();
                                Navigator.of(context).pop();},
                                icon: Icon(Icons.check),
                                label: Text('Ja'),
                              ),
                            ],
                          ),);}, context)
            ],
        ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -100,
            child: Card(
              color: Theme.of(context).buttonColor,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(120))),
              child: Padding(
                padding: EdgeInsets.only(top: 130, bottom: 20, left: 20, right: 20),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(child: Text('Einstellungen', style: TextStyle(fontSize: 30,),textAlign: TextAlign.center, overflow: TextOverflow.visible,))

                ),
              ),
            ),
          ),]
      ),
    );
  }
}
