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
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';

class ClauseUnit implements SyntaxNode<ClauseUnit> {
  ClauseUnit? parent;
  List<SyntaxNode<dynamic>> nodes;

  ClauseUnit(this.nodes, {this.parent});

  void applyToSelfAndChildren(void Function(ClauseUnit) f) {
    // We collect and apply separately in case f modifies the tree (which could lead to recursive suffering)
    final selfAndChildren = [Pair(0, this)];
    _collectChildren(selfAndChildren, depth: 1);
    selfAndChildren.sort((a, b) => -a.first.compareTo(b.first));
    for (var child in selfAndChildren) {
      f(child.second);
    }
  }

  void _collectChildren(List<Pair<int, ClauseUnit>> children, {required int depth}) {
    for (var node in nodes) {
      if (node is ClauseUnit) {
        children.add(Pair(depth, node));
        node._collectChildren(children, depth: depth + 1);
      }
    }
  }

  @override
  ClauseUnit shallowClone() => ClauseUnit(nodes, parent: parent);

  @override
  String getDebugLabel() => "ClauseUnit: ${nodes.length.labeled("node")}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => nodes;
}