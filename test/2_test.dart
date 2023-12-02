import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

class GameSet {
  final int id;
  final int red;
  final int green;
  final int blue;
  const GameSet(
      {required this.id,
      required this.red,
      required this.green,
      required this.blue});
}

RegExp expBlue = RegExp(r'(\d+)\s+blue');
RegExp expGreen = RegExp(r'(\d+)\s+green');
RegExp expRed = RegExp(r'(\d+)\s+red');

GameSet detectGameSet(int id, String input) {
  final matchBlue = expBlue.firstMatch(input);
  final matchGreen = expGreen.firstMatch(input);
  final matchRed = expRed.firstMatch(input);

  return GameSet(
    id: id,
    red:
        matchRed?.group(1) != null ? int.tryParse(matchRed!.group(1)!) ?? 0 : 0,
    blue: matchBlue?.group(1) != null
        ? int.tryParse(matchBlue!.group(1)!) ?? 0
        : 0,
    green: matchGreen?.group(1) != null
        ? int.tryParse(matchGreen!.group(1)!) ?? 0
        : 0,
  );
}

void main() {
  test('Day 2 - a', () async {
    final start = DateTime.now();
    await File('inputs/input2.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => line.split(":"))
        .map((parts) => parts[1]
            .split(";")
            .map((part) => (int.parse(parts[0].substring(5)), part)))
        .map((tuple) => tuple.map((t) => detectGameSet(t.$1, t.$2)))
        .map((gamesSets) => gamesSets.reduce((value, element) => GameSet(
            id: value.id,
            red: max(value.red, element.red),
            green: max(value.green, element.green),
            blue: max(value.blue, element.blue))))
        .where((maxGameSet) =>
            maxGameSet.red <= 12 &&
            maxGameSet.green <= 13 &&
            maxGameSet.blue <= 14)
        .map((maxGameSet) => maxGameSet.id)
        .reduce((previous, element) => previous + element)
        .then(print);
    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 2 - b', () async {
    final start = DateTime.now();
    await File('inputs/input2.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => line.split(":"))
        .map((parts) => parts[1]
            .split(";")
            .map((part) => (int.parse(parts[0].substring(5)), part)))
        .map((tuple) => tuple.map((t) => detectGameSet(t.$1, t.$2)))
        .map((gamesSets) => gamesSets.reduce((value, element) => GameSet(
            id: value.id,
            red: max(value.red, element.red),
            green: max(value.green, element.green),
            blue: max(value.blue, element.blue))))
        .map(
            (maxGameSet) => maxGameSet.blue * maxGameSet.green * maxGameSet.red)
        .reduce((previous, element) => previous + element)
        .then(print);
    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });
}
