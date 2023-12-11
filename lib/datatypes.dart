/*
 *     Discipulus
 *     Copyright (C) 2023  Sam Wagenaar
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

import 'dart:math' as math;

import 'package:discipulus/utils/colors.dart';

class Triple<A, B, C> {
  final A first;
  final B second;
  final C third;

  const Triple(this.first, this.second, this.third);

  @override
  String toString() {
    return 'Triple<$A, $B, $C>[$first, $second, $third]';
  }

  Triple<T, T2, T3> cast<T, T2, T3>() {
    return Triple(first as T, second as T2, third as T3);
  }

  @override
  int get hashCode => Object.hash(first, second, third);

  @override
  bool operator ==(Object other) {
    if (super == other) return true;
    if (other is Triple<A, B, C>) {
      return first == other.first && second == other.second && third == other.third;
    }
    return false;
  }

  Triple<A, B, C> shallowCopy() {
    return Triple(first, second, third);
  }
}

class Pair<A, B> {
  final A first;
  final B second;
  const Pair(this.first, this.second);

  @override
  String toString() {
    return 'Pair<$A, $B>[$first, $second]';
  }

  Pair<T, T2> cast<T, T2>() {
    return Pair(first as T, second as T2);
  }

  @override
  int get hashCode => Object.hash(first, second);

  @override
  bool operator ==(Object other) {
    if (super == other) return true;
    if (other is Pair<A, B>) {
      return first == other.first && second == other.second;
    }
    return false;
  }
  
  Pair<A, B> shallowCopy() {
    return Pair(first, second);
  }
}

class Couple<T> extends Pair<T, T> {
  const Couple(super.first, super.second);

  @override
  String toString() {
    return 'Couple<$T>[$first, $second]';
  }

  Couple<S> map<S>(S Function(T) mapper) {
    return Couple(mapper.call(first), mapper.call(second));
  }

  bool both(bool Function(T) test) {
    return test.call(first) && test.call(second);
  }

  bool either(bool Function(T) test) {
    return test.call(first) || test.call(second);
  }

  @override
  Couple<T> shallowCopy() {
    return Couple(first, second);
  }
}

extension CouplableList<E> on List<E> {
  Couple<E> toCouple() {
    if (length != 2) {
      throw "Invalid list length";
    }
    return Couple(this[0], this[1]);
  }

  Couple<E>? tryToCouple() {
    if (length != 2) {
      return null;
    }
    return Couple(this[0], this[1]);
  }
}

class PeekableIterator<E> implements Iterator<E> {
  final Iterator<E> _wrapped;
  bool _peeked = false;
  E? _realCurrent = null;

  PeekableIterator._(this._wrapped);

  @override
  E get current => _peeked ? _realCurrent! : _wrapped.current;

  @override
  bool moveNext() {
    if (_peeked) {
      _peeked = false;
      _realCurrent = null;
      return true;
    } else {
      return _wrapped.moveNext();
    }
  }

  bool canPeek() {
    if (_peeked) return true;
    _realCurrent = _wrapped.current;
    _peeked = _wrapped.moveNext();
    if (!_peeked) {
      _realCurrent = null;
    }
    return _peeked;
  }

  /// MUST call canPeek() first
  E get peeked => _wrapped.current;
}

extension Peekable<E> on Iterator<E> {
  PeekableIterator<E> peekable() => PeekableIterator._(this);
}

extension VariantExtendable<E> on List<List<E>> {
  List<List<E>> _copy() {
    return map((l) => [...l]).toList();
  }

  void extendVariants(List<E> other) {
    if (isEmpty) {
      addAll(other.map((e) => [e]));
    } else {
      final List<List<E>> old = _copy();
      clear();
      for (final item in other) {
        old.map((l) => [...l, item]).forEach(add);
      }
//      old.map((l) => [...l, ...other]).forEach(add);
    }
  }
}

extension MinMaxIterable<E extends num> on Iterable<E> {
  E get max => reduce(math.max<E>);
  E get min => reduce(math.min<E>);
}

extension MinMaxWithIterable<E> on Iterable<E> {
  E maxWith(int Function(E) mapper) => reduce((a, b) => mapper.call(a) > mapper.call(b) ? a : b);
  E minWith(int Function(E) mapper) => reduce((a, b) => mapper.call(a) < mapper.call(b) ? a : b);
}

extension WherePairIterable<A, B> on Iterable<Pair<A, B>> {
  Iterable<Pair<T, B>> whereFirstType<T>() {
    return where((p) => p.first is T).map((p) => p.cast<T, B>());
  }

  Iterable<Pair<A, T>> whereSecondType<T>() {
    return where((p) => p.second is T).map((p) => p.cast<A, T>());
  }

  Iterable<Pair<T, T2>> whereBothTypes<T, T2>() {
    return where((p) => p.first is T && p.second is T2).map((p) => p.cast<T, T2>());
  }
}

extension MultiCastNestedPair<A, B, C, D> on Pair<Pair<A, B>, Pair<C, D>> {
  Pair<Pair<TA, TB>, Pair<C, D>> castFirst<TA, TB>() {
    return Pair(first.cast<TA, TB>(), second.shallowCopy());
  }

  Pair<Pair<A, B>, Pair<TC, TD>> castSecond<TC, TD>() {
    return Pair(first.shallowCopy(), second.cast<TC, TD>());
  }

  Pair<Pair<TA, TB>, Pair<TC, TD>> castBoth<TA, TB, TC, TD>() {
    return Pair(first.cast<TA, TB>(), second.cast<TC, TD>());
  }
}

extension WherePairPairIterable<A, B, C, D> on Iterable<Pair<Pair<A, B>, Pair<C, D>>> {
  Iterable<Pair<Pair<T, B>, Pair<C, D>>> whereFirst$FirstType<T>() {
    return where((p) => p.first.first is T).map((p) => p.castFirst<T, B>());
  }

  Iterable<Pair<Pair<A, T>, Pair<C, D>>> whereFirst$SecondType<T>() {
    return where((p) => p.first.second is T).map((p) => p.castFirst<A, T>());
  }

  Iterable<Pair<Pair<A, B>, Pair<T, D>>> whereSecond$FirstType<T>() {
    return where((p) => p.second.first is T).map((p) => p.castSecond<T, D>());
  }

  Iterable<Pair<Pair<A, B>, Pair<C, T>>> whereSecond$SecondType<T>() {
    return where((p) => p.second.second is T).map((p) => p.castSecond<C, T>());
  }
}

extension MultiCastNestedTriple<A1, A2, B1, B2, C1, C2> on Triple<Pair<A1, A2>, Pair<B1, B2>, Pair<C1, C2>> {
  Triple<Pair<TA1, TA2>, Pair<B1, B2>, Pair<C1, C2>> castFirst<TA1, TA2>() {
    return Triple(first.cast<TA1, TA2>(), second.shallowCopy(), third.shallowCopy());
  }

  Triple<Pair<A1, A2>, Pair<TB1, TB2>, Pair<C1, C2>> castSecond<TB1, TB2>() {
    return Triple(first.shallowCopy(), second.cast<TB1, TB2>(), third.shallowCopy());
  }

  Triple<Pair<A1, A2>, Pair<B1, B2>, Pair<TC1, TC2>> castThird<TC1, TC2>() {
    return Triple(first.shallowCopy(), second.shallowCopy(), third.cast<TC1, TC2>());
  }

  Triple<Pair<TA1, TA2>, Pair<TB1, TB2>, Pair<C1, C2>> castFirstSecond<TA1, TA2, TB1, TB2>() {
    return Triple(first.cast<TA1, TA2>(), second.cast<TB1, TB2>(), third.shallowCopy());
  }

  Triple<Pair<TA1, TA2>, Pair<B1, B2>, Pair<TC1, TC2>> castFirstThird<TA1, TA2, TC1, TC2>() {
    return Triple(first.cast<TA1, TA2>(), second.shallowCopy(), third.cast<TC1, TC2>());
  }

  Triple<Pair<A1, A2>, Pair<TB1, TB2>, Pair<TC1, TC2>> castSecondThird<TB1, TB2, TC1, TC2>() {
    return Triple(first.shallowCopy(), second.cast<TB1, TB2>(), third.cast<TC1, TC2>());
  }

  Triple<Pair<TA1, TA2>, Pair<TB1, TB2>, Pair<TC1, TC2>> castAll<TA1, TA2, TB1, TB2, TC1, TC2>() {
    return Triple(first.cast<TA1, TA2>(), second.cast<TB1, TB2>(), third.cast<TC1, TC2>());
  }
}

extension WhereTripleIterable<A, B, C> on Iterable<Triple<A, B, C>> {
  Iterable<Triple<T, B, C>> whereFirstType<T>() {
    return where((p) => p.first is T).map((p) => p.cast<T, B, C>());
  }

  Iterable<Triple<A, T, C>> whereSecondType<T>() {
    return where((p) => p.second is T).map((p) => p.cast<A, T, C>());
  }

  Iterable<Triple<A, B, T>> whereThirdType<T>() {
    return where((p) => p.third is T).map((p) => p.cast<A, B, T>());
  }

  Iterable<Triple<T, T2, T3>> whereAllTypes<T, T2, T3>() {
    return where((p) => p.first is T && p.second is T2 && p.third is T3).map((p) => p.cast<T, T2, T3>());
  }
}

extension WhereTriplePairIterable<A1, A2, B1, B2, C1, C2> on Iterable<Triple<Pair<A1, A2>, Pair<B1, B2>, Pair<C1, C2>>> {
  Iterable<Triple<Pair<T1, A2>, Pair<B1, B2>, Pair<C1, C2>>> whereFirst$FirstType<T1>() {
    return where((p) => p.first.first is T1).map((p) => p.castFirst<T1, A2>());
  }

  Iterable<Triple<Pair<A1, T2>, Pair<B1, B2>, Pair<C1, C2>>> whereFirst$SecondType<T2>() {
    return where((p) => p.first.second is T2).map((p) => p.castFirst<A1, T2>());
  }

  Iterable<Triple<Pair<A1, A2>, Pair<T1, B2>, Pair<C1, C2>>> whereSecond$FirstType<T1>() {
    return where((p) => p.second.first is T1).map((p) => p.castSecond<T1, B2>());
  }

  Iterable<Triple<Pair<A1, A2>, Pair<B1, T2>, Pair<C1, C2>>> whereSecond$SecondType<T2>() {
    return where((p) => p.second.second is T2).map((p) => p.castSecond<B1, T2>());
  }

  Iterable<Triple<Pair<A1, A2>, Pair<B1, B2>, Pair<T1, C2>>> whereThird$FirstType<T1>() {
    return where((p) => p.third.first is T1).map((p) => p.castThird<T1, C2>());
  }

  Iterable<Triple<Pair<A1, A2>, Pair<B1, B2>, Pair<C1, T2>>> whereThird$SecondType<T2>() {
    return where((p) => p.third.second is T2).map((p) => p.castThird<C1, T2>());
  }
}

extension Enumeratable<E> on Iterable<E> {
  Iterable<Pair<int, E>> get enumerate sync* {
    int i = 0;
    for (final E e in this) {
      yield Pair(i, e);
      i++;
    }
  }
}

extension Capitalizable on String {
  String get capitalize => isEmpty ? this : "${this[0].toUpperCase()}${length == 1 ? "" : substring(1)}";
}

extension ShallowCopiable<E> on List<E> {
  List<E> shallowCopy() {
    return [...this];
  }
}

extension FunctionName<R, P> on R Function(P) {
  String get name => toString().split("'")[1];
}

extension ColorfulList on List<bool> {
  String get colorCoded {
    String out = "${Fore.RESET}[";
    for (int i = 0; i < length; i++) {
      out += this[i] ? "${Fore.GREEN}true${Fore.RESET}" : "${Fore.RED}false${Fore.RESET}";
      if (i != length - 1) {
        out += ", ";
      }
    }
    out += "]";
    return out;
  }
}

extension CouplewiseList<E> on List<E> {
  List<Couple<E>> get couples => [
    for (int i = 0; i < length - 1; i++)
      Couple(this[i], this[i+1]),
  ];
}

extension PairwiseList<E> on List<E> {
  List<Pair<E, E>> get pairs => [
    for (int i = 0; i < length - 1; i++)
      Pair(this[i], this[i+1]),
  ];
}

extension TriplewiseList<E> on List<E> {
  List<Triple<E, E, E>> get triples => [
    for (int i = 0; i < length - 2; i++)
      Triple(this[i], this[i+1], this[i+2]),
  ];
}

extension WeightedAbs on int {
  int weightedAbs() => this < 0 ? 1-this : this;
}