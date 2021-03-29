import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/4_home_screen/search/sort_types.dart';
import 'package:flutter_app/ui_screens/screens.dart';

class SearchDialog extends StatefulWidget {
  @override
  SearchDialogState createState() => SearchDialogState();
}

class SearchDialogState extends State<SearchDialog>
    with SingleTickerProviderStateMixin {
  double _height = 60;
  double _width = 80;

  static bool searchState = false;

  var _searchColor = ConstColors.mainColor;
  static String searchString;
  TextEditingController controllerText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Material(
      color: searchState == false
          ? ConstColors.mainColor
          : ConstColors.searchColor,
      elevation: searchState == true ? 5.0 : 0.0,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
      ),
      child: AnimatedContainer(
        height: _height,
        width: _width,
        duration: Duration(
          milliseconds: 500,
        ),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          color: _searchColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
          ),
        ),
        child: searchState == false
            ? IconButton(
                onPressed: () {
                  setState(() {
                    searchState = true;
                    _height = sizeX.height / 1.4;
                    _width = sizeX.height / 2.2;
                    _searchColor = ConstColors.searchColor;
                  });
                },
                icon: Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                ),
              )
            : Stack(
                children: <Widget>[
                  searchState == true
                      ? Positioned(
                          top: 5.0,
                          left: 0.0,
                          right: 0.0,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      AppLocalization.of(context)
                                          .getTranslatedValue("search"),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: sizeX.height / 3.5),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            searchState = false;
                                            _height = 60;
                                            _width = 80;
                                            _searchColor =
                                                ConstColors.mainColor;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 10.0,
                                  left: 15.0,
                                ),
                                child: Container(
                                  height: sizeX.height / 20,
                                  width: sizeX.height / 2.3,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      30.0,
                                    ),
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      TextField(
                                        // controller: controllerText,
                                        onChanged: (search) {
                                          setState(() {
                                            searchString = search;
                                          });
                                        },
                                        textInputAction: TextInputAction.done,
                                        cursorColor:
                                            ConstColors.registerTextColor,
                                        decoration: InputDecoration(
                                          hintStyle: TextStyle(
                                              fontSize: sizeX.height / 55,
                                              color: Colors.grey[600]),
                                          contentPadding: EdgeInsets.only(
                                              top: 10.0, left: 10.0),
                                          hintText: AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "write_to_search"),
                                          focusedBorder: new OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: new OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          errorBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          border: const UnderlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0.0,
                                        top: 0.0,
                                        bottom: 0.0,
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            CupertinoIcons.search,
                                            color: searchState == true
                                                ? ConstColors.registerTextColor
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  SortTypes(),
                ],
              ),
      ),
    );
  }
}
