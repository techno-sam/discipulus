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
import 'package:http/http.dart' as http;

import 'package:discipulus/words_invokers/words_invoker.dart';

class HTTPWordsInvoker implements WordsInvoker {
  final http.Client _client;

  HTTPWordsInvoker({http.Client? client}) : _client = client ?? http.Client();

  @override
  String callWords(String word) {
    throw UnimplementedError();
  }

  @override
  FutureOr<String> callWordsAsync(String word) async {
    final response = await _client.get(Uri.http(
      '129.159.36.220',
      '/words',
      {'word': word},
    ));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to contact server: ${response.statusCode}\n${response.body}');
    }
  }

  @override
  void dispose() {
    _client.close();
  }
}