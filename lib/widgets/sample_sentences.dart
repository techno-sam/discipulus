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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const List<String> _sampleSentences = [
  "Cornelia et Flavia sunt amicae",
  "Cornelia et raedae sunt in pictura",
  "Sextus dat glirem puellae Romanae",
  "Cornelia iam sub arbore sedet cum Flavia et legit",
  "Cornelia quae cotidie ambulat edit glirem quod famem habet",
  "Cornelia et pueri Romani timidi magnos glires celeriter edunt in foro",
  "pueri Romani edunt glires qui trans Rhenum incolunt quod amant in silva musculos devorare"
];

class SampleSentenceList extends StatelessWidget {
  const SampleSentenceList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _sampleSentences.length,
          itemBuilder: (context, idx) {
            if (idx >= _sampleSentences.length) return null;

            return SampleSentenceTile(sentence: _sampleSentences[idx]);
          },
      ),
    );
  }
}

class SampleSentenceTile extends StatelessWidget {
  final String sentence;

  const SampleSentenceTile({super.key, required this.sentence});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sentence,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 16.0),
            IconButton.outlined(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                context.read<TranslationState>().setSourceText(sentence);
              },
              style: (theme.outlinedButtonTheme.style ?? const ButtonStyle()).copyWith(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              tooltip: "Use this sentence",
            ),
          ],
        ),
      ),
    );
  }
}