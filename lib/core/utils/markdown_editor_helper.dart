import 'package:flutter/services.dart';

typedef MarkdownEditResult = ({String text, TextSelection selection});

MarkdownEditResult applyInlineFormatEdit({
  required String text,
  required TextSelection selection,
  required String prefix,
  required String suffix,
}) {
  final range = _resolveRange(text: text, selection: selection);
  final replacement = range.hasSelection ? '$prefix${range.selectedText}$suffix' : '$prefix$suffix';
  final newText = text.replaceRange(range.start, range.end, replacement);
  final cursorOffset = range.hasSelection ? range.start + replacement.length : range.start + prefix.length;

  return (
    text: newText,
    selection: _collapsedSelection(newText, cursorOffset),
  );
}

MarkdownEditResult insertSpoilerEdit({
  required String text,
  required TextSelection selection,
}) {
  const header = 'spoiler Header';
  final range = _resolveRange(text: text, selection: selection);
  final replacement = range.hasSelection ? '\n```$header\n${range.selectedText}\n```\n' : '```$header\n\n```';
  final newText = text.replaceRange(range.start, range.end, replacement);
  final cursorOffset = range.hasSelection ? range.start + replacement.length : range.start + '```$header\n'.length;

  return (
    text: newText,
    selection: _collapsedSelection(newText, cursorOffset),
  );
}

MarkdownEditResult insertQuoteEdit({
  required String text,
  required TextSelection selection,
}) {
  final range = _resolveRange(text: text, selection: selection);

  final needsLeadingNewline = range.start > 0 && text[range.start - 1] != '\n';
  final needsTrailingNewline = range.end < text.length && text[range.end] != '\n';
  const opening = '```quote\n';
  const closing = '\n```';
  final core = range.hasSelection ? '$opening${range.selectedText}$closing' : '$opening\n$closing';
  final replacement = '${needsLeadingNewline ? '\n' : ''}$core${needsTrailingNewline ? '\n' : ''}';
  final newText = text.replaceRange(range.start, range.end, replacement);

  final cursorOffset = range.hasSelection
      ? range.start + replacement.length
      : range.start + (needsLeadingNewline ? 1 : 0) + opening.length;

  return (
    text: newText,
    selection: _collapsedSelection(newText, cursorOffset),
  );
}

MarkdownEditResult insertCodeBlockEdit({
  required String text,
  required TextSelection selection,
}) {
  final range = _resolveRange(text: text, selection: selection);
  final replacement = range.hasSelection ? '```\n${range.selectedText}\n```' : '```\n\n```';
  final newText = text.replaceRange(range.start, range.end, replacement);
  final cursorOffset = range.hasSelection ? range.start + replacement.length : range.start + '```\n'.length;

  return (
    text: newText,
    selection: _collapsedSelection(newText, cursorOffset),
  );
}

MarkdownEditResult insertLinkEdit({
  required String text,
  required TextSelection selection,
}) {
  final range = _resolveRange(text: text, selection: selection);
  final linkText = range.selectedText.isNotEmpty ? range.selectedText : 'text';
  const urlPlaceholder = 'https://';
  final replacement = '[$linkText]($urlPlaceholder)';
  final newText = text.replaceRange(range.start, range.end, replacement);
  final urlStart = range.start + linkText.length + 3;
  final urlEnd = urlStart + urlPlaceholder.length;

  return (
    text: newText,
    selection: _rangeSelection(newText, baseOffset: urlStart, extentOffset: urlEnd),
  );
}

MarkdownEditResult insertListEdit({
  required String text,
  required TextSelection selection,
  required bool ordered,
}) {
  final baseOffset = selection.isValid ? selection.baseOffset : text.length;
  final lineBreakIndex = text.indexOf('\n');
  final firstLineEnd = lineBreakIndex == -1 ? text.length : lineBreakIndex;
  final firstLine = text.substring(0, firstLineEnd);
  final unorderedPrefixMatch = RegExp(r'^(\s*)[-*]\s+').firstMatch(firstLine);
  final orderedPrefixMatch = RegExp(r'^(\s*)(\d+)\.\s+').firstMatch(firstLine);
  final existingPrefixMatch = orderedPrefixMatch ?? unorderedPrefixMatch;
  final existingIndent = existingPrefixMatch?.group(1) ?? '';
  final replacementPrefix = '$existingIndent${ordered ? '1. ' : '- '}';
  final replaceEnd = existingPrefixMatch?.end ?? 0;
  final newText = text.replaceRange(0, replaceEnd, replacementPrefix);
  final delta = replacementPrefix.length - replaceEnd;
  final cursorOffset = (baseOffset + delta).clamp(0, newText.length);

  return (
    text: newText,
    selection: _collapsedSelection(newText, cursorOffset),
  );
}

({String text, int cursorOffset})? buildListContinuationEdit({
  required String text,
  required int cursorOffset,
}) {
  if (cursorOffset <= 0 || cursorOffset > text.length) return null;
  final newlineIndex = cursorOffset - 1;
  if (text[newlineIndex] != '\n') return null;

  final previousLineStart = text.lastIndexOf('\n', newlineIndex - 1) + 1;
  final previousLine = text.substring(previousLineStart, newlineIndex);

  final emptyUnordered = RegExp(r'^(\s*)[-*]\s*$').firstMatch(previousLine);
  if (emptyUnordered != null) {
    final clearedText = text.replaceRange(previousLineStart, newlineIndex, '');
    final removedLength = newlineIndex - previousLineStart;
    return (
      text: clearedText,
      cursorOffset: cursorOffset - removedLength,
    );
  }

  final emptyOrdered = RegExp(r'^(\s*)(\d+)\.\s*$').firstMatch(previousLine);
  if (emptyOrdered != null) {
    final clearedText = text.replaceRange(previousLineStart, newlineIndex, '');
    final removedLength = newlineIndex - previousLineStart;
    return (
      text: clearedText,
      cursorOffset: cursorOffset - removedLength,
    );
  }

  final unorderedMatch = RegExp(r'^(\s*)[-*]\s+').firstMatch(previousLine);
  if (unorderedMatch != null) {
    final marker = '${unorderedMatch.group(1) ?? ''}- ';
    final newText = text.replaceRange(cursorOffset, cursorOffset, marker);
    return (
      text: newText,
      cursorOffset: cursorOffset + marker.length,
    );
  }

  final orderedMatch = RegExp(r'^(\s*)(\d+)\.\s+').firstMatch(previousLine);
  if (orderedMatch != null) {
    final indent = orderedMatch.group(1) ?? '';
    final currentNumber = int.tryParse(orderedMatch.group(2) ?? '');
    if (currentNumber == null) return null;
    final marker = '$indent${currentNumber + 1}. ';
    final newText = text.replaceRange(cursorOffset, cursorOffset, marker);
    return (
      text: newText,
      cursorOffset: cursorOffset + marker.length,
    );
  }

  return null;
}

({int start, int end, bool hasSelection, String selectedText}) _resolveRange({
  required String text,
  required TextSelection selection,
}) {
  final int start = selection.isValid ? selection.start : text.length;
  final int end = selection.isValid ? selection.end : text.length;
  final bool hasSelection = selection.isValid && !selection.isCollapsed && start != end;
  final String selectedText = hasSelection ? text.substring(start, end) : '';
  return (
    start: start,
    end: end,
    hasSelection: hasSelection,
    selectedText: selectedText,
  );
}

TextSelection _collapsedSelection(String text, int offset) {
  return TextSelection.collapsed(offset: offset.clamp(0, text.length));
}

TextSelection _rangeSelection(
  String text, {
  required int baseOffset,
  required int extentOffset,
}) {
  return TextSelection(
    baseOffset: baseOffset.clamp(0, text.length),
    extentOffset: extentOffset.clamp(0, text.length),
  );
}
