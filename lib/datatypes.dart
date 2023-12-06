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
      old.map((l) => [...l, ...other]).forEach(add);
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