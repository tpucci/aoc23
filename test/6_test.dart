import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class Input {
  List<Race> races = [];

  @override
  String toString() {
    return 'Input{races: $races}';
  }
}

class Race {
  final int duration;
  final int recordDistance;
  Race({required this.duration, required this.recordDistance});

  @override
  String toString() {
    return 'Race{duration: $duration, recordDistance: $recordDistance}';
  }

  int get numberOfWaysToWin => maxCharge - minCharge + 1;

  double get sqrtdelta => sqrt(duration * duration - 4 * recordDistance);

  int get minCharge => ((duration - sqrtdelta) / 2 + 0.00000000000001).ceil();
  int get maxCharge => ((duration + sqrtdelta) / 2 - 0.00000000000001).floor();
}

void main() {
  test('Day 6 - a', () async {
    final start = DateTime.now();
    final answer = await File('inputs/input6.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => switch (line) {
              String l when l.startsWith("Time:") =>
                Stream.fromIterable(l.substring(9).toListOfInts()),
              String l when l.startsWith("Distance:") =>
                Stream.fromIterable(l.substring(9).toListOfInts()),
              _ => throw Exception("Unknown line: $line")
            })
        .bufferCount(2)
        .flatMap((value) => Rx.zip(value,
            (values) => Race(duration: values[0], recordDistance: values[1])))
        .map((race) => race.numberOfWaysToWin)
        .reduce((previous, element) => previous * element);

    print(answer);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 6 - b', () async {
    final start = DateTime.now();
    final answer = await File('inputs/input6.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => switch (line) {
              String l when l.startsWith("Time:") =>
                int.parse(l.substring(9).replaceAll(' ', '')),
              String l when l.startsWith("Distance:") =>
                int.parse(l.substring(9).replaceAll(' ', '')),
              _ => throw Exception("Unknown line: $line")
            })
        .bufferCount(2)
        .map((values) => Race(duration: values[0], recordDistance: values[1]))
        .map((race) => race.numberOfWaysToWin)
        .reduce((previous, element) => previous * element);

    print(answer);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
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
        if (num > 0) {
          ints.add(num);
          num = 0;
        }
      }
    }
    return ints;
  }
}
