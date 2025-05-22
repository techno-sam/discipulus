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

import 'package:discipulus/datatypes.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/s.dart';
import 'package:discipulus/screens/translation_tree_screen.dart';
import 'package:discipulus/widgets/debug_tree_display.dart';
import 'package:flutter/material.dart';

class TranslationCard extends StatefulWidget {
  final Pair<String, S> sentence;

  const TranslationCard({super.key, required this.sentence});

  @override
  State<TranslationCard> createState() => _TranslationCardState();
}

class _TranslationCardState extends State<TranslationCard> {
  bool _showTree = false;

  bool get showTree => _showTree;

  void toggleTree() {
    setState(() {
      _showTree = !_showTree;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: showTree
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (!showTree)
              Text(
                widget.sentence.second.translate(null),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (showTree)
              DebugTreeDisplay(debugNode: widget.sentence.second),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.bug_report_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TranslationTreeScreen(
                      sentence: widget.sentence,
                    ),
                  ),
                );
              },
              tooltip: "Show Translation Process",
            ),
            const SizedBox(width: 4.0),
            IconButton(
              icon: Icon(
                showTree ? Icons.expand_less : Icons.account_tree_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: toggleTree,
              tooltip: "Toggle Tree View",
            ),
          ],
        ),
      ),
    );
  }
}