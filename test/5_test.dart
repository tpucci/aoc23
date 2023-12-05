import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class Input {
  List<int> seeds = [];
  Map<String, InputMap> maps = {};
  InputMap buildingMap = InputMap();

  @override
  String toString() {
    return 'Input{seeds: $seeds, maps: $maps}';
  }
}

class InputMap {
  InputMap();
  String from = "";
  String to = "";
  List<Range> ranges = [];

  static final headerRegExp = RegExp(r'(\w+)-to-(\w+) map:');

  factory InputMap.fromHeader(String header) {
    final match = headerRegExp.firstMatch(header)!;
    return InputMap()
      ..from = match.group(1)!
      ..to = match.group(2)!;
  }

  @override
  String toString() {
    return 'InputMap{from: $from, to: $to, ranges: $ranges}';
  }

  (int destination, String to) apply(int source) {
    final range = ranges.firstWhere(
        (range) =>
            range.sourceStart <= source &&
            range.sourceStart + range.length > source,
        orElse: () =>
            Range(sourceStart: source, destinationStart: source, length: 1));
    final destination = range.destinationStart + source - range.sourceStart;
    return (destination, to);
  }

  static InputMap combine(InputMap a, InputMap b) {
    final combined = InputMap()
      ..from = a.from
      ..to = b.to;
    final aRanges = a.ranges.toList();
    final bRanges = b.ranges.toList();
    while (aRanges.isNotEmpty || bRanges.isNotEmpty) {
      final _ = switch ((
        aRanges.firstOrNull?.destinationStart ?? 100000000000000000,
        bRanges.firstOrNull?.sourceStart ?? 100000000000000000,
        aRanges.firstOrNull?.destinationEnd ?? 100000000000000000,
        bRanges.firstOrNull?.sourceEnd ?? 100000000000000000
      )) {
        (int astart, int bstart, int aend, int _)
            when astart < bstart && bstart < aend =>
          combined.ranges
            ..add(Range(
                sourceStart: aRanges.first.sourceStart,
                destinationStart:
                    aRanges.first.shrink(bstart - astart).destinationStart,
                length: bstart - astart)),
        (int astart, int bstart, int _, int bend)
            when bstart < astart && astart < bend =>
          combined.ranges
            ..add(Range(
                sourceStart: bstart,
                destinationStart:
                    bRanges.first.shrink(astart - bstart).destinationStart,
                length: astart - bstart)),
        (int astart, int bstart, int aend, int bend)
            when astart == bstart && aend < bend =>
          combined.ranges
            ..add(Range(
                sourceStart: aRanges.removeAt(0).sourceStart,
                destinationStart:
                    bRanges.first.shrink(aend - astart).destinationStart,
                length: aend - astart)),
        (int astart, int bstart, int aend, int bend)
            when astart == bstart && bend < aend =>
          combined.ranges
            ..add(Range(
                sourceStart: aRanges.first.shrink(bend - bstart).sourceStart,
                destinationStart: bRanges.removeAt(0).destinationStart,
                length: bend - bstart)),
        (int astart, int bstart, int aend, int bend)
            when astart == bstart && aend == bend =>
          combined.ranges
            ..add(Range(
                sourceStart: aRanges.removeAt(0).sourceStart,
                destinationStart: bRanges.removeAt(0).destinationStart,
                length: aend - astart)),
        (int _, int bstart, int aend, int _) when aend < bstart =>
          combined.ranges.add(aRanges.removeAt(0)),
        (int astart, int _, int _, int bend) when bend < astart =>
          combined.ranges.add(bRanges.removeAt(0)),
        _ => throw "Unexpected case: $aRanges $bRanges"
      };
    }
    return combined;
  }
}

class Range {
  Range(
      {required this.sourceStart,
      required this.destinationStart,
      required this.length});
  int sourceStart;
  int destinationStart;
  int length;

  factory Range.fromInts(List<int> ints) {
    return Range(
        sourceStart: ints[1], destinationStart: ints[0], length: ints[2]);
  }

  @override
  String toString() {
    return 'Range{sourceStart: $sourceStart, destinationStart: $destinationStart, length: $length}';
  }

  Range shrink(int shrink) {
    final initial = Range(
        sourceStart: sourceStart,
        destinationStart: destinationStart,
        length: length);
    sourceStart += shrink;
    destinationStart += shrink;
    length -= shrink;
    return initial;
  }

  int get sourceEnd => sourceStart + length;
  int get destinationEnd => destinationStart + length;
  int sourceMiddle(int d) => sourceStart + d - destinationStart;
  int destinationMiddle(int s) => destinationStart + s - sourceStart;

  operator ==(Object other) =>
      other is Range &&
      sourceStart == other.sourceStart &&
      destinationStart == other.destinationStart &&
      length == other.length;
}

void main() {
  test('Day 5 - a', () async {
    final start = DateTime.now();
    final input = await File('inputs/input5.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .concatWith([Stream.value('')]).fold(
            Input(),
            (input, line) => switch (line) {
                  String l when l.startsWith("seeds:") => input
                    ..seeds = l.substring(7).toListOfInts(),
                  String l when l.endsWith("map:") => input
                    ..buildingMap = InputMap.fromHeader(l),
                  '' => input
                    ..maps.addAll({
                      if (input.buildingMap.from.isNotEmpty)
                        input.buildingMap.from: input.buildingMap
                    }),
                  String intsString => input
                    ..buildingMap
                        .ranges
                        .add(Range.fromInts(intsString.toListOfInts())),
                });

    final minLocation = input.seeds.map((seed) {
      String to = "seed";
      int destination = seed;
      while (to != "location") {
        (destination, to) = input.maps[to]!.apply(destination);
      }
      return destination;
    }).reduce(min);

    print(minLocation);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 5 - b', () async {
    final start = DateTime.now();
    final input = await File('inputs/input5.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .concatWith([Stream.value('')]).fold(
            Input(),
            (input, line) => switch (line) {
                  String l when l.startsWith("seeds:") => input
                    ..seeds = l.substring(7).toListOfInts(),
                  String l when l.endsWith("map:") => input
                    ..buildingMap = InputMap.fromHeader(l),
                  '' => input
                    ..maps.addAll({
                      if (input.buildingMap.from.isNotEmpty)
                        input.buildingMap.from: input.buildingMap
                    }),
                  String intsString => input
                    ..buildingMap
                        .ranges
                        .add(Range.fromInts(intsString.toListOfInts())),
                });

    var combinedMap = input.maps["seed"]!;
    while (combinedMap.to != "location") {
      combinedMap = InputMap.combine(combinedMap, input.maps[combinedMap.to]!);
    }

    final seedsRanges = groupListTwoByTwo(input.seeds)
        .map((pair) => Range(
            sourceStart: pair[0], destinationStart: pair[0], length: pair[1]))
        .toList();

    final seedMap = InputMap()
      ..from = "seedmap"
      ..to = "seed"
      ..ranges = seedsRanges;

    combinedMap = InputMap.combine(seedMap, combinedMap);

    var list = combinedMap.ranges
      ..sort((a, b) => a.destinationStart.compareTo(b.destinationStart));

    // FAILLLLL THAT'S NOT THE RIGHT ANSWER
    var found = false;
    while (!found) {
      var range = list.removeAt(0);
      for (var i = range.destinationStart; i < range.destinationEnd; i++) {
        var source = range.sourceMiddle(i);
        if (seedsRanges.any((element) =>
            element.sourceStart <= source && element.sourceEnd > source)) {
          found = true;
          break;
        }
      }
    }

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Combine input maps', () {
    final atob = InputMap()
      ..from = "a"
      ..to = "b"
      ..ranges = [
        Range(sourceStart: 10, destinationStart: 20, length: 10),
        Range(sourceStart: 50, destinationStart: 90, length: 10),
        Range(sourceStart: 100, destinationStart: 200, length: 10),
      ];
    final btoc = InputMap()
      ..from = "b"
      ..to = "c"
      ..ranges = [
        Range(sourceStart: 40, destinationStart: 0, length: 5),
        Range(sourceStart: 92, destinationStart: 50, length: 10),
        Range(sourceStart: 200, destinationStart: 400, length: 10),
      ];
    final atoc = InputMap()
      ..from = "a"
      ..to = "c"
      ..ranges = [
        Range(sourceStart: 10, destinationStart: 20, length: 10),
        Range(sourceStart: 40, destinationStart: 0, length: 5),
        Range(sourceStart: 50, destinationStart: 90, length: 2),
        Range(sourceStart: 52, destinationStart: 50, length: 8),
        Range(sourceStart: 100, destinationStart: 58, length: 2),
        Range(sourceStart: 100, destinationStart: 400, length: 10),
      ];
    var combine = InputMap.combine(atob, btoc);
    expect(combine.from, atoc.from);
    expect(combine.to, atoc.to);
    expect(combine.ranges, atoc.ranges);
  });
}

final rune0 = '0'.runes.first;
final rune9 = '9'.runes.first;

extension on String {
  List<int> toListOfInts() {
    final ints = <int>[];
    var num = 0;
    for (final r in (this + ' ').runes) {
      if (r >= rune0 && r <= rune9) {
        num = num * 10 + (r - rune0);
      } else {
        ints.add(num);
        num = 0;
      }
    }
    return ints;
  }
}

List<List<T>> groupListTwoByTwo<T>(List<T> list) {
  List<List<T>> grouped = [];
  for (int i = 0; i < list.length; i += 2) {
    grouped.add([list[i], list[i + 1]]);
  }
  return grouped;
}
