import 'dart:convert';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class Gear {
  final Offset offset;
  final Set<Part> parts;
  const Gear(this.offset, this.parts);

  factory Gear.from(
      {required Match match, required int lineIndex, required Offset offset}) {
    return Gear(offset, Set.of([Part.fromLineAndMatch(match, lineIndex)]));
  }

  int get factor =>
      parts.length == 2 ? parts.first.value * parts.last.value : 0;
}

class Offset {
  final int x;
  final int y;
  const Offset(this.x, this.y);

  bool operator ==(dynamic other) => x == other.x && y == other.y;
  String toString() => "$x:$y";

  int get hashCode => x.hashCode ^ y.hashCode;
}

class Part {
  final Offset offset;
  final int value;
  const Part(this.offset, this.value);

  factory Part.fromLineAndMatch(Match match, int lineIndex) {
    final y = lineIndex;
    final value = int.parse(match[1]!);
    return Part(Offset(match.start, y), value);
  }

  bool operator ==(dynamic other) =>
      other is Part && other.offset == offset && other.value == value;

  int get hashCode => offset.hashCode ^ value.hashCode;

  String toString() => "Part $value at $offset";
}

RegExp ints = RegExp(r'(\d+)');

final rune0 = '0'.runes.first;
final rune9 = '9'.runes.first;

isGearAtOffset(String? line, int? x) {
  if (line == null) return false;
  if (x == null) return false;
  if (x >= line.length) return false;
  if (x < 0) return false;
  if (line[x] == '.') return false;
  final rune = line.runes.elementAt(x);
  return !(rune >= rune0 && rune <= rune9);
}

Part getPart(Match match, int lineIndex) {
  final y = lineIndex;
  final value = int.parse(match[1]!);
  return Part(Offset(match.start, y), value);
}

Stream<Part> detectParts(
    String line, int lineIndex, String? lineToCompareTo) async* {
  final matches = ints.allMatches(line);

  for (final match in matches) {
    final xMin = match.start > 0 ? match.start - 1 : null;
    final xMax = match.end < line.length ? match.end : null;
    if (isGearAtOffset(line, xMin)) {
      yield Part.fromLineAndMatch(match, lineIndex);
      continue;
    }
    if (isGearAtOffset(line, xMax)) {
      yield Part.fromLineAndMatch(match, lineIndex);
      continue;
    }
    for (var x = xMin ?? 0; x <= (xMax ?? line.length - 1); x++) {
      if (isGearAtOffset(lineToCompareTo, x)) {
        yield Part.fromLineAndMatch(match, lineIndex);
        break;
      }
    }
  }
}

Stream<Gear> detectGears(
    String line, int lineIndex, (String?, int) lineToCompare) async* {
  final matches = ints.allMatches(line);

  for (final match in matches) {
    final xMin = match.start - 1;
    final xMax = match.end;
    if (isGearAtOffset(line, xMin)) {
      yield Gear.from(
          offset: Offset(xMin, lineIndex), match: match, lineIndex: lineIndex);
    }
    if (isGearAtOffset(line, xMax)) {
      yield Gear.from(
          offset: Offset(xMax, lineIndex), match: match, lineIndex: lineIndex);
    }
    final (lineToCompareTo, lineToCompareToIndex) = lineToCompare;
    if (lineToCompareTo == null) continue;
    for (var x = xMin; x <= xMax; x++) {
      if (isGearAtOffset(lineToCompareTo, x)) {
        yield Gear.from(
            offset: Offset(x, lineToCompareToIndex),
            match: match,
            lineIndex: lineIndex);
      }
    }
  }
}

void main() {
  group('detectParts', () {
    test('start', () {
      final start = detectParts("123...", 0, "*.....");
      expect(
          start,
          emits(
            Part(Offset(0, 0), 123),
          ));

      final cornerStart = detectParts(".234..", 0, "*.....");
      expect(
          cornerStart,
          emits(
            Part(Offset(1, 0), 234),
          ));
    });

    test('end', () {
      final cornerEnd = detectParts("..345.", 0, ".....*");
      expect(
          cornerEnd,
          emits(
            Part(Offset(2, 0), 345),
          ));

      final end = detectParts("...456", 0, ".....*");
      expect(
          end,
          emits(
            Part(Offset(3, 0), 456),
          ));
    });

    test('before/after', () {
      final before = detectParts("*234..", 0, "......");
      expect(
          before,
          emits(
            Part(Offset(1, 0), 234),
          ));

      final after = detectParts("..345*", 0, "......");
      expect(
          after,
          emits(
            Part(Offset(2, 0), 345),
          ));
    });

    test("numbers", () {
      final doesNotDetectNumbers = detectParts("0123456789", 0, "0123456789");
      expect(doesNotDetectNumbers, neverEmits(isA<Part>()));
    });
  });

  test('identical', () {
    expect(Part(Offset(1, 2), 123) == Part(Offset(1, 2), 123), isTrue);
    final set = Set<Part>()
      ..add(Part(Offset(1, 2), 123))
      ..add(Part(Offset(1, 2), 123));
    expect(set.length, 1);
  });

  test('Day 3 - a', () async {
    final start = DateTime.now();
    final partsSet = await File('inputs/input3.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())

        // Transform to (line, next line, line index)
        .scan<(String?, String?, int)>(
            (accumulated, value, index) => (accumulated.$2, value, index),
            (null, null, -1))

        // Transform to (line, line index, line to compare to)
        .flatMap((tuple) => Stream.fromIterable([
              (tuple.$1, tuple.$3 - 1, tuple.$2),
              (tuple.$2, tuple.$3, tuple.$1)
            ]))
        .where((tuple) => tuple.$1 != null)
        .flatMap((tuple) => detectParts(tuple.$1!, tuple.$2, tuple.$3))
        .scan((accumulated, value, _) => accumulated..add(value), Set<Part>())
        .last;

    final answer = partsSet.fold(0, (value, part) => value + part.value);
    expect(answer, 530849);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 3 - b', () async {
    final start = DateTime.now();
    final gearsSet = await File('inputs/input3.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())

        // Transform to (line, next line, line index)
        .scan<(String?, String?, int)>(
            (accumulated, value, index) => (accumulated.$2, value, index),
            (null, null, -1))

        // Transform to (line, line index, line to compare to)
        .flatMap((tuple) => Stream.fromIterable([
              (tuple.$1, tuple.$3 - 1, (tuple.$2, tuple.$3)),
              (tuple.$2, tuple.$3, (tuple.$1, tuple.$3 - 1))
            ]))
        .where((tuple) => tuple.$1 != null)
        .flatMap((tuple) => detectGears(tuple.$1!, tuple.$2, tuple.$3))
        .scan((accumulated, value, _) {
          final gearInSet =
              accumulated.any((gear) => gear.offset == value.offset);
          if (!gearInSet) {
            return accumulated..add(value);
          } else {
            accumulated
                .firstWhere((gear) => gear.offset == value.offset)
                .parts
                .add(value.parts.first);
            return accumulated;
          }
        }, Set<Gear>())
        .last;

    final answer =
        gearsSet.fold(0, (previous, element) => previous + element.factor);
    print(answer);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });
}
