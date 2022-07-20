import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher findsWidgetsMoreThan(int threshold) =>
    _FindsWidgetMatcher(threshold, null);

/// WidgetMatcher checking whether the count of finds is in rage of [min,max]
///
/// original: package:flutter_test/src/matchers.dart
class _FindsWidgetMatcher extends Matcher {
  const _FindsWidgetMatcher(this.min, this.max);

  final int? min;
  final int? max;

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    assert(min != null || max != null);
    assert(min == null || max == null || min! <= max!);
    matchState[Finder] = finder;
    int count = 0;
    final Iterator<Element> iterator = finder.evaluate().iterator;
    if (min != null) {
      while (count < min! && iterator.moveNext()) {
        count += 1;
      }
      if (count < min!) {
        return false;
      }
    }
    if (max != null) {
      while (count <= max! && iterator.moveNext()) {
        count += 1;
      }
      if (count > max!) {
        return false;
      }
    }
    return true;
  }

  @override
  Description describe(Description description) {
    assert(min != null || max != null);
    if (min == max) {
      if (min == 1) {
        return description.add('exactly one matching node in the widget tree');
      }
      return description.add('exactly $min matching nodes in the widget tree');
    }
    if (min == null) {
      if (max == 0) {
        return description.add('no matching nodes in the widget tree');
      }
      if (max == 1) {
        return description.add('at most one matching node in the widget tree');
      }
      return description.add('at most $max matching nodes in the widget tree');
    }
    if (max == null) {
      if (min == 1) {
        return description.add('at least one matching node in the widget tree');
      }
      return description.add('at least $min matching nodes in the widget tree');
    }
    return description.add(
        'between $min and $max matching nodes in the widget tree (inclusive)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    final Finder finder = matchState[Finder] as Finder;
    final int count = finder.evaluate().length;
    if (count == 0) {
      assert(min != null && min! > 0);
      if (min == 1 && max == 1) {
        return mismatchDescription
            .add('means none were found but one was expected');
      }
      return mismatchDescription
          .add('means none were found but some were expected');
    }
    if (max == 0) {
      if (count == 1) {
        return mismatchDescription
            .add('means one was found but none were expected');
      }
      return mismatchDescription
          .add('means some were found but none were expected');
    }
    if (min != null && count < min!) {
      return mismatchDescription.add('is not enough');
    }
    assert(max != null && count > min!);
    return mismatchDescription.add('is too many');
  }
}
