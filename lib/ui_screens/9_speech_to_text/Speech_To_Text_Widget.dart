import 'package:flutter/material.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/ui_screens/9_speech_to_text/FirestoreSpeechApi.dart';
import 'Speech_API.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'Speech_Comands.dart';
import 'Substring_Hightlight.dart';

// ignore: must_be_immutable
class SpeechToTextWidget extends StatefulWidget {
  final String logPath;
  String speechText;
  SpeechToTextWidget({
    Key key,
    this.logPath,
    this.speechText,
  }) : super(key: key);

  @override
  _SpeechToTextWidgetState createState() => _SpeechToTextWidgetState();
}

class _SpeechToTextWidgetState extends State<SpeechToTextWidget> {
  String text = 'Speak';
  bool isListening = false;

  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Container(
        child: Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            reverse: true,
            child: SubstringHighlight(
              text: widget.speechText == '' ? text : widget.speechText,
              terms: Command.all,
              textStyle: TextStyle(
                fontSize: sizeX.height / 55,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              textStyleHighlight: TextStyle(
                fontSize: sizeX.height / 55,
                color: ConstColors.registerTextColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          GestureDetector(
            onTap: toggleRecording,
            child: AvatarGlow(
              animate: isListening,
              endRadius: 45,
              glowColor: ConstColors.registerTextColor,
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300],
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                child: Image.asset('assets/icons/icon_speach_to_text.png'),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) => setState(() => this.widget.speechText = text),
        onListening: (isListening) {
          setState(() => this.isListening = isListening);

          if (!isListening) {
            Future.delayed(Duration(seconds: 1), () {
              Utils.scanText(widget.speechText);
              FirestoreSpeechApi().speechToTextUpd(
                widget.logPath,
                widget.speechText,
              );
            });
          }
        },
      );
}
