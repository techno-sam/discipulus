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

import 'package:discipulus/grammar/latin/grammar_types.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/nodes.dart';

class S implements SyntaxNode<S> {
  final NP<dynamic> _subject;
  final VP _predicate;

  S({required NP<dynamic> subject, required VP predicate})
      : _subject = subject,
        _predicate = predicate
  {
    if (_subject.caze != Case.nom) {
      throw ArgumentError.value(_subject.caze, "subject.caze", "Subject must be nominative");
    }
    if (_subject.plural != _predicate.person.plural) {
      throw ArgumentError.value((_subject.plural, _predicate.person), "(subject.plural, predicate.person)", "Subject and predicate must agree in number");
    }
  }

  static bool isValidPair(NP<dynamic> subject, VP predicate) =>
      subject.caze == Case.nom && subject.plural == predicate.person.plural;

  String translate() {
    final subjectTranslation = _subject.translate(article: Article.definite);
    final predicateTranslation = _predicate.translate();
    return "$subjectTranslation $predicateTranslation";
  }

  @override
  S shallowClone() => S(subject: _subject, predicate: _predicate);

  @override
  String getDebugLabel() => "S -> ${translate()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_subject, _predicate];
}