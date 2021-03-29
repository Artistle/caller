import 'package:flutter/material.dart';
import 'package:flutter_app/constants/const_colors/const_colors.dart';
import 'package:flutter_app/ui_screens/3_register_screen/register_screen.dart';

class CustomCheckbox extends StatefulWidget {
  final bool isChecked;
  final double size;
  final double iconSize;
  final Color selectedColor;
  final Color selectedIconColor;
  final Function onTap;

  CustomCheckbox({
    this.isChecked,
    this.size,
    this.iconSize,
    this.selectedColor,
    this.selectedIconColor,
    this.onTap,
  });

  @override
  CustomCheckboxState createState() => CustomCheckboxState();
}

class CustomCheckboxState extends State<CustomCheckbox> {
  static bool isSelected = false;

  @override
  void initState() {
    isSelected = widget.isChecked ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
        decoration: BoxDecoration(
            color: isSelected
                ? widget.selectedColor ?? ConstColors.mainColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5.0),
            border: isSelected
                ? null
                : Border.all(
                    color: RegisterScreenState.checkValid == false
                        ? ConstColors.mainColor
                        : Colors.red,
                    width: 2.0,
                  )),
        width: widget.size ?? 30,
        height: widget.size ?? 30,
        child: isSelected
            ? Icon(
                Icons.check,
                color: widget.selectedIconColor ?? Colors.white,
                size: widget.iconSize ?? 20,
              )
            : null,
      ),
    );
  }
}
