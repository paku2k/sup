import 'package:flutter/material.dart';
import '../animations/FadeAnimation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:sup/ui-helper.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin<AuthScreen> {
  List<DocumentSnapshot> usernameSnapshot = [];
  bool isSignup;
  bool isLoading;
  String _email;
  String _password;
  String _userName;
  final _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _userNameKey = GlobalKey<FormFieldState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  void _signIn(BuildContext buildContext) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    try {
      setState(() {
        isLoading = true;
      });
      if (isSignup) {
        final _authResult = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        await Firestore.instance
            .collection('user')
            .document(_authResult.user.uid)
            .setData({'name': _userName});
      } else {
        await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      }
    } on PlatformException catch (error) {
      setState(() {
        isLoading = false;
      });
      var message = 'An error occured, please check your credentials';

      if (error.message != null) {
        message = error.message;
      }

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    isSignup = false;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: screenHeight, maxWidth: screenWidth),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                  child: Container(
                width: screenWidth,
                height: screenHeight,
              )),
              Positioned(
                top: 328,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF3DBCCD), Color(0x6CE0EAFF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                height: 330,
                width: screenWidth,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'Paddleboard.jpg',
                          ),
                          fit: BoxFit.cover)),
                ),
              ),
              Positioned(
                top: 120,
                left: 82,
                height: 100,
                width: 65,
                child: FadeAnimationApple(
                    2,
                    Container(
                      transform: new Matrix4.identity()
                        ..rotateZ(-15 * 3.1415927 / 180),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('marker_zwei.png'),
                              fit: BoxFit.contain)),
                    )),
              ),
              Positioned(
                top: 320,
                left: 50,
                child: FadeAnimation(
                    1.5,
                    Text(
                      isSignup ? "Sign Up" : "Login",
                      style: TextStyle(
                          color: Color.fromRGBO(49, 39, 79, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    )),
              ),
              Positioned(
                top: 360,
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      FadeAnimation(
                          1.7,
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue[100],
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  )
                                ]),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  AnimatedContainer(
                                    curve: Curves.easeOut,
                                    height: isSignup ? 70 : 0,
                                    duration: Duration(milliseconds: 220),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: isSignup
                                          ? Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))
                                          : null,
                                    ),
                                    child: isSignup
                                        ? TextFormField(
                                            initialValue: _userName,
                                            key: _userNameKey,
                                            onSaved: (value) =>
                                                _userName = value.trim(),
                                            validator: (value) {
                                              if (value.length < 6) {
                                                return "minimum 6 characters";
                                              }
                                              if (usernameSnapshot == null) {
                                                return "Checking";
                                              } else if (usernameSnapshot
                                                  .isEmpty) {
                                                return null;
                                              }
                                              return "username ${value.trim()} is already taken";
                                            },
                                            onChanged: (value) {
                                              usernameSnapshot = null;
                                              Firestore.instance
                                                  .collection('user')
                                                  .where('name',
                                                      isEqualTo: value.trim())
                                                  .getDocuments()
                                                  .then((value) {
                                                usernameSnapshot =
                                                    value.documents;
                                                print(usernameSnapshot
                                                    .toString());
                                                _userNameKey.currentState
                                                    .validate();
                                              });
                                            },
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "User Name",
                                                hintStyle: TextStyle(
                                                    color: Colors.grey)),
                                          )
                                        : Container(),
                                  ),
                                  Container(
                                    height: null,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]))),
                                    child: TextFormField(
                                      validator: (value) {
                                        return validateEmail(value.trim())
                                            ? null
                                            : "${value.trim()} is not a valid email";
                                      },
                                      onSaved: (value) => _email = value.trim(),
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Email",
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                  Container(
                                    height: null,
                                    padding: EdgeInsets.all(10),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value.length < 8) {
                                          return "minimum 8 characters";
                                        }
                                        return null;
                                      },
                                      obscureText: true,
                                      onSaved: (value) => _password = value,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Password",
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      FadeAnimation(
                          1.7,
                          Center(
                              child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: Color.fromRGBO(49, 39, 79, .6)),
                          ))),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          1.9,
                          GestureDetector(
                            onTap: () => _signIn(context),
                            child: Container(
                              height: 50,
                              margin: EdgeInsets.symmetric(horizontal: 60),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Theme.of(context).accentColor,
                              ),
                              child: Center(
                                child: Text(
                                  isSignup ? "Sign Up" : "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          2,
                          Center(
                            child: GestureDetector(
                                child: Text(
                                  isSignup ? "Login instead" : "Create Account",
                                  style: TextStyle(
                                      color: Color.fromRGBO(49, 39, 79, .6)),
                                ),
                                onTap: () {
                                  setState(() {
                                    isSignup = !isSignup;
                                  });
                                }),
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
