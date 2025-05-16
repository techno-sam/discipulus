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

import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/word_types.dart';

import 's.dart';
import 'vp.dart';

abstract interface class Conj<S extends Conj<S>> implements SyntaxNode<S> {
  String translate();
}

class Conj$s implements Conj<Conj$s> {
  final Conjunction _conjunction;

  const Conj$s(this._conjunction);

  @override
  String translate() => _conjunction.primaryTranslation;

  @override
  Conj$s shallowClone() => Conj$s(_conjunction);

  @override
  String getDebugLabel() => "Conj_s: ${_conjunction.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class Et implements Conj<Et> {
  const Et();

  @override
  String translate() => "and";

  @override
  Et shallowClone() => const Et();

  @override
  String getDebugLabel() => "\"et\"";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class Sbar implements SyntaxNode<Sbar> {
  final Conj<dynamic> _conjunction;
  final S _s;

  const Sbar(this._conjunction, this._s);

  String translate(List<S>? parents) => "${_conjunction.translate()} ${_s.translate(parents)}";

  @override
  Sbar shallowClone() => Sbar(_conjunction, _s);

  @override
  String getDebugLabel() => "SBAR -> ${translate(null)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_conjunction, _s];
}