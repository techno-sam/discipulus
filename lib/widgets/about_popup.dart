/*
 *     Discipulus
 *     Copyright (C) 2025  Sam Wagenaar
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showAboutPopup(BuildContext context) {
  showAboutDialog(
      context: context,
      applicationName: "Discipulus",
      applicationIcon: Image.asset(
        "web/icons/Icon-192.png",
        width: 32,
        height: 32,
      ),
      children: const [
        _AboutContents(),
      ]
  );
}

class _AboutContents extends StatelessWidget {
  const _AboutContents();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Final Latin Final", style: theme.textTheme.bodyLarge,),
        Text("By Sam Wagenaar", style: theme.textTheme.bodyLarge,),
        const SizedBox(
          width: 64,
          child: Divider(),
        ),
        OutlinedButton(
          onPressed: () {
            launchUrl(Uri.parse("https://github.com/techno-sam/discipulus"));
          },
          child: const Text("View Source"),
        )
      ],
    );
  }
}

class AboutPopupShower extends StatefulWidget {
  final Widget? child;

  const AboutPopupShower({super.key, this.child});

  @override
  State<AboutPopupShower> createState() => _AboutPopupShowerState();
}

class _AboutPopupShowerState extends State<AboutPopupShower> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    if (!_shown) {
      _shown = true;
      scheduleMicrotask(() {
        if (Uri.base.queryParameters.containsKey("about") || Uri.base.queryParameters.containsKey("showAbout")) {
          showAboutPopup(context);
        }
      });
    }
    return widget.child ?? const SizedBox.shrink();
  }
}