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

class TranslationInput extends StatefulWidget {
  const TranslationInput({super.key});

  @override
  State<TranslationInput> createState() => _TranslationInputState();
}

class _TranslationInputState extends State<TranslationInput> {
  final TextEditingController _controller = TextEditingController();
  String _currentValue = "";

  void _onSubmit() {
    context.read<TranslationState>().setSourceText(_currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translationState = context.watch<TranslationState>();

    if (translationState.sourceText != _currentValue) {
      _controller.text = translationState.sourceText;
      _currentValue = translationState.sourceText;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            color: theme.colorScheme.surfaceContainerLowest,
            elevation: 1,
            clipBehavior: Clip.none,
            borderOnForeground: false,
            shape: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 0,
                    color: Colors.transparent
                ),
                borderRadius: BorderRadius.circular(8.0)
            ),
            child: Stack(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Latin Text',
                    hintText: 'Enter a latin sentence',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _currentValue = value;
                    if (value.isEmpty) {
                      _onSubmit();
                    }
                  },
                  onSubmitted: (value) {
                    _currentValue = value;
                    _onSubmit();
                  },
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.clear),
                        color: theme.colorScheme.outline,
                        onPressed: () {
                          _controller.clear();
                          _currentValue = "";
                          translationState.setSourceText("");
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton.outlined(
          onPressed: _onSubmit,
          icon: const Icon(Icons.translate),
          style: (theme.outlinedButtonTheme.style ?? const ButtonStyle()).copyWith(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          tooltip: 'Translate',
        ),
      ],
    );
  }
}