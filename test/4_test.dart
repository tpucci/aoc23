import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

final rune0 = '0'.runes.first;
final runeSpace = ' '.runes.first;

extension on String {
  List<int> toListOfInts() {
    final ints = <int>[];
    for (var i = 0; i < length; i += 3) {
      var maybeTens = this.runes.elementAt(i + 1);
      final tens = maybeTens == runeSpace ? 0 : (maybeTens - rune0) * 10;
      final units = this.runes.elementAt(i + 2) - rune0;
      ints.add(tens + units);
    }
    return ints;
  }
}

void main() {
  test('Day 4 - a', () async {
    final start = DateTime.now();
    await File('inputs/input4.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => (
              line.substring(5, 8),
              line.substring(9, 39).toListOfInts(),
              line.substring(41, 116).toListOfInts()
            ))
        .map((tuple) =>
            tuple.$3.where((element) => tuple.$2.contains(element)).length)
        .map((score) => score > 0 ? pow(2, score - 1) : 0)
        .reduce((previous, element) => previous + element)
        .then(print);
    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 4 - b', () async {
    final start = DateTime.now();
    await File('inputs/input4.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => (
              line.substring(9, 39).toListOfInts(),
              line.substring(41, 116).toListOfInts()
            ))
        .fold(
            <int>[],
            (acc, tuple) => [
                  ...acc,
                  tuple.$2.where((element) => tuple.$1.contains(element)).length
                ]).then((value) {
      print(value);
      return value;
    }).then((wins) {
      final copies = List.generate(wins.length, (_) => 1);
      for (var i = 0; i < copies.length; i++) {
        for (var j = 0; j < copies[i]; j++) {
          for (var k = 1; k <= wins[i]; k++) {
            copies[i + k]++;
          }
        }
      }
      return copies.reduce((value, element) => value + element);
    }).then(print);
    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 4 - b - example', () async {
    final start = DateTime.now();
    await File('inputs/input4_example.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => (
              line.substring(7, 22).toListOfInts(),
              line.substring(24, 48).toListOfInts()
            ))
        .fold(
            <int>[],
            (acc, tuple) => [
                  ...acc,
                  tuple.$2.where((element) => tuple.$1.contains(element)).length
                ]).then((value) {
      print(value);
      return value;
    }).then((wins) {
      final copies = List.generate(wins.length, (_) => 1);
      for (var i = 0; i < copies.length; i++) {
        for (var j = 0; j < copies[i]; j++) {
          for (var k = 1; k <= wins[i]; k++) {
            copies[i + k]++;
          }
        }
      }
      return copies.reduce((value, element) => value + element);
    }).then(print);
    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });
}
