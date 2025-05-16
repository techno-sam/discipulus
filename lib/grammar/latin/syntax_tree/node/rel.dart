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
import 'package:discipulus/grammar/latin/word_types.dart';

import 's.dart';

class Rel implements SyntaxNode<Rel> {
  final Noun _pronoun;

  const Rel(this._pronoun);

  Case get caze => _pronoun.caze;
  bool get plural => _pronoun.plural;
  Gender get gender => _pronoun.gender;

  String translate() => _pronoun.primaryTranslation;

  @override
  Rel shallowClone() => Rel(_pronoun);

  @override
  String getDebugLabel() => "Rel: ${_pronoun.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class RelClause implements SyntaxNode<RelClause> {
  final Rel _pronoun;
  final S _s;

  RelClause(this._pronoun, this._s) {
    if (_pronoun.plural != _s.subject.plural) {
      throw ArgumentError.value(_s.subject.plural, "subject.plural", "Subject and relative pronoun must agree in number");
    }
  }

  static bool isValidPair(Rel pronoun, S s) =>
      pronoun.plural == s.subject.plural;

  Case get caze => _pronoun.caze;
  bool get plural => _pronoun.plural;
  Gender get gender => _pronoun.gender;

  String translate() => "${_pronoun.translate()} ${_s.translate(null, skipImplicitSubject: true)}";

  @override
  RelClause shallowClone() => RelClause(_pronoun, _s);

  @override
  String getDebugLabel() => "RelClause -> ${translate()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_pronoun, _s];
}