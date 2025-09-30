import 'package:flutter/material.dart';

class MentionNavIntent extends Intent {
  const MentionNavIntent._(this.direction);
  const MentionNavIntent.down() : this._(TraversalDirection.down);
  const MentionNavIntent.up() : this._(TraversalDirection.up);
  final TraversalDirection direction;
}

class MentionSelectIntent extends Intent {
  const MentionSelectIntent();
}
