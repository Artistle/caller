import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallLogs {
  getAvator(CallType callType) {
    switch (callType) {
      case CallType.outgoing:
        return CircleAvatar(
          maxRadius: 30,
          foregroundColor: Colors.green,
          backgroundColor: Colors.greenAccent,
        );
      case CallType.missed:
        return CircleAvatar(
          maxRadius: 30,
          foregroundColor: Colors.red[400],
          backgroundColor: Colors.red[400],
        );
      default:
        return CircleAvatar(
          maxRadius: 30,
          foregroundColor: Colors.indigo[700],
          backgroundColor: Colors.indigo[700],
        );
    }
  }

  static Future<Iterable<CallLogEntry>> getCallLogs() {
    // if (await Permission.contacts.request().isGranted) {
    // getAllContacts();

    return CallLog.get();
    // }
  }

  String formatDate(DateTime dt) {
    return DateFormat('d-MMM-y H:m:s').format(dt);
  }

  static getTitle(CallLogEntry entry) {
    if (entry.name == null) return entry.number;
    if (entry.name.isEmpty) {
      return entry.number;
    } else
      return entry.name;
  }

  static getNumber(CallLogEntry entry) {
    if (entry.number == null) return entry.number;
    if (entry.number.isEmpty) {
      return entry.name;
    } else
      return entry.number;
  }

  static getDuration(CallLogEntry entry) {
    if (entry.duration == null) return entry.duration;
    if (entry.duration.isNaN) {
      return entry.duration;
    } else
      return entry.duration;
  }

  static getCallType(CallType callType) {
    switch (callType) {
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Incoming';
      default:
        return 'Incoming';
    }
  }

  String getTime(int duration) {
    Duration d1 = Duration(seconds: duration);
    String formatedDuration = "";
    if (d1.inHours > 0) {
      formatedDuration += d1.inHours.toString() + "h ";
    }
    if (d1.inMinutes > 0) {
      formatedDuration += d1.inMinutes.toString() + "m ";
    }
    if (d1.inSeconds > 0) {
      formatedDuration += d1.inSeconds.toString() + "s";
    }
    if (formatedDuration.isEmpty) return "0s";
    return formatedDuration;
  }
}
