

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/dialogs.dart';

void openLinkOrFail(BuildContext context, String link, {String? title, String? message}) {
  final uri = Uri.parse(link);
  openUriOrFail(context, uri, title: title, message: message);
}

void openUriOrFail(BuildContext context, Uri uri, {String? title, String? message}) {
  canLaunchUrl(uri).then((value) => launchUrl(uri)).catchError((err) {
    showPopup(
      context: context,
      title: title ?? "Error",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message ?? "Unfortunately, I could not open the link for you. Please visit:"),
          InkWell(
            onTap: () {
              launchUrl(uri);
            },
            child: Text(
              uri.toString(),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
    return false;
  });
}