import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_constant.dart';
import 'keys.dart';

showSnackbar(context, String message, {MaterialColor? materialColor}) {
  if (message.isEmpty) return;
  // Find the Scaffold in the Widget tree and use it to show a SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: materialColor));
}

launchURL(String url) async {
  if (url.isEmpty) return;
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch $url';
  }
}

class MessageInCenterWidget extends StatelessWidget {
  final String _message;

  MessageInCenterWidget(this._message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(_message,
          key: const ValueKey(HomePageKeys.MESSAGE_IN_CENTER),
          style: const TextStyle(fontSize: FONT_MEDIUM, color: Colors.black)),
    );
  }
}
