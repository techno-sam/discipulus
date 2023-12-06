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

// ignore_for_file: camel_case_types

import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

typedef str_ptr = Pointer<Utf8>;

/* Rust/C */

typedef test_func = str_ptr Function(str_ptr);
typedef words_func = str_ptr Function(str_ptr, str_ptr, str_ptr);
typedef drop_str_func = Void Function(str_ptr);

/* Dart */

typedef Test = str_ptr Function(str_ptr);
typedef Words = str_ptr Function(str_ptr, str_ptr, str_ptr);
typedef DropStr = void Function(str_ptr);

DynamicLibrary load({String basePath = ''}) {
  if (Platform.isLinux) {
    return DynamicLibrary.open('${basePath}libwords_ffi.so');
  } else if (Platform.isMacOS) {
    return DynamicLibrary.open('${basePath}libwords_ffi.dylib');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('${basePath}words_ffi.dll');
  } else {
    throw NotSupportedPlatform('${Platform.operatingSystem} is not supported!');
  }
}

class NotSupportedPlatform extends Error {
  NotSupportedPlatform(String s);
}

class WordsLL {
  static late DynamicLibrary _lib;
  static bool _init = false;

  WordsLL({required bool debugMode}) {
    _initLib(debugMode: debugMode);
  }

  static void _initLib({required bool debugMode}) {
    if (!_init) {
      // for debugging and tests
      if (debugMode && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        _lib = load(basePath: 'target/debug/');
      } else {
        _lib = load();
      }
      _init = true;
    }
  }

  String test(String fname) {
    final str_ptr out = _lib.lookupFunction<test_func, Test>('ffi_test', isLeaf: true)(fname.toNativeUtf8());
    String outDart = out.toDartString();
    _dropString(out);
    return outDart;
  }

  String words(String workingDir, String exec, String word) {
    final str_ptr out = _lib.lookupFunction<words_func, Words>('ffi_words', isLeaf: true)
      (workingDir.toNativeUtf8(), exec.toNativeUtf8(), word.toNativeUtf8());
    String outDart = out.toDartString();
    _dropString(out);
    return outDart;
  }

  String wordsDefault(String word) {
    return words("/home/sam/bin/whitakers-words", "/home/sam/bin/whitakers-words/bin/words", word);
  }

  void _dropString(str_ptr string) {
    _lib.lookupFunction<drop_str_func, DropStr>('ffi_drop_string', isLeaf: true)(string);
  }
}