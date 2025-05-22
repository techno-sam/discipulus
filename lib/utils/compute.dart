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

import 'dart:async';

import 'package:discipulus/datatypes.dart';
import 'package:flutter/foundation.dart';

List<List<E>> _chunked<E>(List<E> base, int chunkCount) {
  final int chunkSize = (base.length / chunkCount).ceil();
  final List<List<E>> chunks = [];

  for (int i = 0; i < base.length; i += chunkSize) {
    chunks.add(base.sublist(i, i + chunkSize > base.length ? base.length : i + chunkSize));
  }

  return chunks;
}

Future<List<R>> computePooled<M, R>(FutureOr<R> Function(M) callback, List<M> elements, {String? debugLabel, int poolCount = 8}) async{
  final List<List<M>> chunks = _chunked(elements, poolCount);

  final futures = chunks.enumerate.map((pair) {
    return compute(
      (List<M> chunk) {
        return Future.wait(chunk.map((M element) async => await callback(element)));
      },
      pair.second,
      debugLabel: "${debugLabel ?? "computePooled"} (Pool ${pair.first}/${chunks.length})",
    );
  });

  final chunkedOut = await Future.wait(futures);

  return chunkedOut.expand((e) => e).toList();
}