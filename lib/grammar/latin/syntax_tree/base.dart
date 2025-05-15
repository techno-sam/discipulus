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

import 'package:discipulus/datatypes.dart';

abstract interface class SyntaxNode<S extends SyntaxNode<S>> extends TreeDebugNode {
  S shallowClone();
}

abstract interface class TreeDebugNode {
  String getDebugLabel();
  Iterable<TreeDebugNode> getDebugChildren();

  static List<String> getDebugLines(TreeDebugNode node, {bool recursive = false}) {
    List<String> lines = [];
    lines.add((recursive ? " " : "") + node.getDebugLabel());

    final debugChildren = node.getDebugChildren();
    for (final child in debugChildren.enumerate) {
      final header = child.first == debugChildren.length - 1
          ? "└──"
          : "├──";
      final body = child.first == debugChildren.length - 1
          ? "    "
          : "│   ";

      List<String> childLines = getDebugLines(child.second, recursive: true);
      for (final line in childLines.enumerate) {
        final header2 = line.first == 0
            ? header
            : body;
        lines.add("$header2${line.second}");
      }
    }
    return lines;
  }
}

class LiteralDebugNode implements TreeDebugNode {
  final String _label;
  final Iterable<TreeDebugNode> _children;

  LiteralDebugNode(this._label, [Iterable<TreeDebugNode>? children]): _children = children ?? [];

  @override
  String getDebugLabel() => _label;

  @override
  Iterable<TreeDebugNode> getDebugChildren() => _children;
}

class TestingTreeDebug implements TreeDebugNode {
  final String _label;
  final List<TestingTreeDebug> _children = [];

  TestingTreeDebug(this._label);

  @override
  String getDebugLabel() => _label;

  @override
  Iterable<TreeDebugNode> getDebugChildren() => _children;

  TestingTreeDebug c(String label) {
    TestingTreeDebug child = TestingTreeDebug(label);
    _children.add(child);
    return child;
  }
}

void testMe() {
  var root = TestingTreeDebug("root");
  var child1 = root.c("child1");
  var child2 = root.c("child2");
  child1.c("child1.1")..c("child1.1.1")..c("child1.1.2");
  child1.c("child1.2").c("child1.2.1").c("child1.2.1.1")..c("child1.2.1.2")..c("child1.2.1.3");
  child2.c("child2.1")..c("child2.1.1")..c("child2.1.2");
  child2.c("child2.2");

  var lines = TreeDebugNode.getDebugLines(root);
  for (var line in lines) {
    print(line);
  }
}
