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

import 'package:discipulus/models/translation_state.dart';
import 'package:discipulus/widgets/about_popup.dart';
import 'package:discipulus/widgets/translation_input.dart';
import 'package:discipulus/widgets/translation_output.dart';
import 'package:discipulus/utils/splash_control/splash_control.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    getSplashControl().sendSplashClearEvent();

    return AboutPopupShower(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.inversePrimary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Discipulus",
                style: GoogleFonts.monsieurLaDoulaiseTextTheme(theme.textTheme).headlineLarge,
              ),
              OutlinedButton(
                onPressed: () => showAboutPopup(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: const BorderSide(color: Colors.grey)
                  ),
                ),
                child: const Text("About"),
              ),
            ],
          ),
        ),
        body: ChangeNotifierProvider(
          create: (_) => TranslationState(),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TranslationInput(),
                SizedBox(height: 4.0),
                TranslationOutput(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}