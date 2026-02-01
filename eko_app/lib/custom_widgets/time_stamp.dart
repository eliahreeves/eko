import 'package:flutter/material.dart';

String formatTime(String time) {
  DateTime now = DateTime.now();
  DateTime postTime = DateTime.parse(time).toLocal();
  Duration difference = now.difference(postTime);

  int totalMonths = 0;
  totalMonths = (now.year - postTime.year) * 12;
  totalMonths += now.month - postTime.month;

  if (now.day < postTime.day) {
    totalMonths--;
  }
  int years = totalMonths ~/ 12;
  int days = difference.inDays;

  if (totalMonths >= 12) {
    return '${years}y';
  } else if (totalMonths > 0) {
    return '${totalMonths}mo';
  } else if (days > 0) {
    return '${days}d';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return 'now';
  }
}

class TimeStamp extends StatelessWidget {
  final String time;
  final double fontSize;
  const TimeStamp({super.key, required this.time, this.fontSize = 15});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTime(time),
      style: TextStyle(
          fontSize: fontSize,
          //fontWeight: FontWeight.w300,
          color: Theme.of(context).colorScheme.onSurfaceVariant
          //color: Theme.of(context).colorScheme.onBackground,
          ),
    );
  }
}
