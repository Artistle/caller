import 'dart:ffi';
import 'package:flutter/services.dart';

class PlatformRepository{
  static const platform = const MethodChannel('samples.flutter.dev/caller');

  Future<Void> setDefaultDialer(String uid) async{
    try{
      final String result = await platform.invokeMethod("setDefaultDialer",{"uid":uid});
      print(result);
    }on PlatformException catch(e){
      print(e);
    }
  }
}

