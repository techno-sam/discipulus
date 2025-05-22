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
import 'package:discipulus/widgets/translation_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sample_sentences.dart';

class TranslationOutput extends StatelessWidget {
  const TranslationOutput({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translationState = context.watch<TranslationState>();

    final contents = translationState.result?.apply(
      (success) => _SuccessOutput(success: success),
      (error) => _ErrorOutput(error: error),
    ) ?? const _EmptyOutput();

    return Flexible(
      child: Card.outlined(
        elevation: 1,
        color: theme.colorScheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: contents,
        ),
      ),
    );
  }
}

class _SuccessOutput extends StatelessWidget {
  final TranslationSuccess success;

  const _SuccessOutput({required this.success});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: success.sentences.length,
      itemBuilder: (context, idx) {
        if (idx >= success.sentences.length) return null;
        return TranslationCard(sentence: success.sentences[idx]);
      },
    );
  }
}

class _ErrorOutput extends StatelessWidget {
  final TranslationError error;

  const _ErrorOutput({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Eheu!",
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8.0),
        Flexible(
          child: SingleChildScrollView(
            child: Text(
              error.toString(),
              style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Colors.red.shade800),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyOutput extends StatelessWidget {
  const _EmptyOutput();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "No translation yet.",
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 4.0),
        Text(
          "Please enter a Latin sentence to translate, or pick one of the samples below.",
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(
          width: 200,
          child: Divider(
            thickness: 2,
            height: 32,
          ),
        ),
        const Flexible(child: SampleSentenceList()),
      ],
    );
  }
}