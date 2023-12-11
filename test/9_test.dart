@Timeout(Duration(seconds: 60000))
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Day 9 - a', () async {
    final start = DateTime.now();
    final a = await answerA('inputs/input9.txt');

    expect(a, 1647269739);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 9 - b', () async {
    final start = DateTime.now();
    final b = await answerB('inputs/input9.txt');

    print(b);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('example - a', () async {
    expect(await answerA('inputs/input9_example.txt'), 114);
  });

  test('example - b', () async {
    expect(await answerB('inputs/input9_example.txt'), 2);
  });
}

Future<int> answerA(String path) async {
  final answer = await File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .map((line) => History()..values = line.toListOfInts())
      .map((history) => history.nextValue())
      .reduce((previous, element) => previous + element);

  return answer;
}

Future<int> answerB(String path) async {
  final answer = await File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .map((line) => History()..values = line.toListOfInts())
      .map((history) => history.previousValue())
      .reduce((previous, element) => previous + element);

  return answer;
}

class History {
  List<int> values = [];

  int nextValue() {
    final firstInterval = values[1] - values[0];
    final lastInterval = values.last - values[values.length - 2];
    if (firstInterval != lastInterval) {
      var derivatedHistoryValues = <int>[];
      for (var i = 0; i < values.length - 1; i++) {
        derivatedHistoryValues.add(values[i + 1] - values[i]);
      }
      final derivatedHistory = History()..values = derivatedHistoryValues;
      return values.last + derivatedHistory.nextValue();
    }
    return values.last + lastInterval;
  }

  int previousValue() {
    final firstInterval = values[1] - values[0];
    final lastInterval = values.last - values[values.length - 2];
    if (firstInterval != lastInterval) {
      var derivatedHistoryValues = <int>[];
      for (var i = 0; i < values.length - 1; i++) {
        derivatedHistoryValues.add(values[i + 1] - values[i]);
      }
      final derivatedHistory = History()..values = derivatedHistoryValues;
      return values.first - derivatedHistory.previousValue();
    }
    return values.first - lastInterval;
  }
}

final runeminus = '-'.runes.first;
final rune0 = '0'.runes.first;
final rune9 = '9'.runes.first;

extension on String {
  List<int> toListOfInts() {
    final ints = <int>[];
    var sign = 1;
    var num = 0;
    for (final r in (this + ' ').runes) {
      if (r >= rune0 && r <= rune9) {
        num = num * 10 + (r - rune0);
      } else if (r == runeminus) {
        sign = -1;
      } else {
        ints.add(num * sign);
        num = 0;
        sign = 1;
      }
    }
    return ints;
  }
}
