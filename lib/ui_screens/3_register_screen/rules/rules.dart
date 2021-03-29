import 'package:flutter/material.dart';
import 'package:flutter_app/animations/fade_animation.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/ui_screens/screens.dart';
import 'package:worm_indicator/worm_indicator.dart';
import 'package:worm_indicator/shape.dart';

class Rules extends StatefulWidget {
  @override
  _RulesState createState() => _RulesState();
}

class _RulesState extends State<Rules> {
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: FadeAnimation(
          0.5,
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Container(
        height: sizeX.height,
        child: FadeAnimation(
          0.5,
          Stack(
            children: <Widget>[
              PageView(
                controller: pageController,
                children: <Widget>[
                  PrivacyPolicy(),
                  TermsOfService(),
                ],
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 30.0,
                child: WormIndicator(
                  indicatorColor: ConstColors.welcomeIndicator,
                  color: Colors.grey[300],
                  length: 2,
                  controller: pageController,
                  shape: Shape(
                      size: 16,
                      spacing: 8,
                      shape: DotShape.Circle // Similar for Square
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
