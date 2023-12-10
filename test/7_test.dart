@Timeout(Duration(seconds: 60000))
import 'dart:convert';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class Hand {
  String cards = '23456';
  int bid = 23;
  int score = 0;

  @override
  String toString() {
    return 'Hand{cards: $cards, bid: $bid}';
  }
}

void main() {
  test('Day 7 - a', () async {
    final start = DateTime.now();
    final a = await answerA('inputs/input7.txt');

    expect(a, 250254244);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 7 - b', () async {
    final start = DateTime.now();
    final b = await answerB('inputs/input7.txt');

    expect(b, 250087440);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('example - a', () async {
    expect(await answerA('inputs/input7_example.txt'), 6440);
  });

  test('example - b', () async {
    expect(await answerB('inputs/input7_example.txt'), 5905);
  });
}

Future<int> answerA(String path) async {
  final hands = await File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .map((line) => Hand()
        ..cards = line.substring(0, 5)
        ..bid = int.parse(line.substring(6))
        ..score = line.substring(0, 5).aScore())
      .fold(<Hand>[], (acc, hand) {
    acc.add(hand);
    return acc;
  });

  hands.sort((a, b) => a.score.compareTo(b.score));

  var answer = 0;
  for (var i = 1; i <= hands.length; i++) {
    answer += i * hands[i - 1].bid;
  }
  return answer;
}

Future<int> answerB(String path) async {
  final hands = await File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .map((line) => Hand()
        ..cards = line.substring(0, 5)
        ..bid = int.parse(line.substring(6))
        ..score = line.substring(0, 5).bScore())
      .fold(<Hand>[], (acc, hand) {
    acc.add(hand);
    return acc;
  });

  hands.sort((a, b) => a.score.compareTo(b.score));

  var answer = 0;
  for (var i = 1; i <= hands.length; i++) {
    answer += i * hands[i - 1].bid;
  }
  return answer;
}

final rune0 = '0'.runes.first;
final rune2 = '2'.runes.first;
final rune9 = '9'.runes.first;
final runeT = 'T'.runes.first;
final runeJ = 'J'.runes.first;
final runeQ = 'Q'.runes.first;
final runeK = 'K'.runes.first;
final runeA = 'A'.runes.first;
final allRunes = '23456789TJQKA'.runes;

extension on String {
  int orderedScore() => runes.fold(
      0,
      (acc, rune) => switch (rune) {
            int r when r >= rune2 && r <= rune9 => acc * 100 + r - rune0,
            int r when r == runeT => acc * 100 + 10,
            int r when r == runeJ => acc * 100 + 11,
            int r when r == runeQ => acc * 100 + 12,
            int r when r == runeK => acc * 100 + 13,
            int r when r == runeA => acc * 100 + 14,
            _ => throw Exception("Unknown rune: $rune in $this")
          });

  int orderedScoreWithJoker() => runes.fold(
      0,
      (acc, rune) => switch (rune) {
            int r when r >= rune2 && r <= rune9 => acc * 100 + r - rune0,
            int r when r == runeT => acc * 100 + 10,
            int r when r == runeJ => acc * 100 + 1,
            int r when r == runeQ => acc * 100 + 12,
            int r when r == runeK => acc * 100 + 13,
            int r when r == runeA => acc * 100 + 14,
            _ => throw Exception("Unknown rune: $rune in $this")
          });

  int typeScoreWithJoker() {
    var countMap = runes.fold(<int, int>{}, (acc, rune) {
      if (rune == runeJ) {
        for (var r in allRunes) {
          acc[r] = (acc[r] ?? 0) + 1;
        }
        return acc;
      }
      acc[rune] = (acc[rune] ?? 0) + 1;
      return acc;
    });
    final jokers = (countMap[runeJ] ?? 0);
    final countList = countMap.keys.map((e) => (e, countMap[e]!)).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    final score = switch ((countList, jokers)) {
      (List<(int, int)> l, _) when l[0].$2 > 5 =>
        throw Exception("Unknown type: $this, $countList, $jokers"),
      (List<(int, int)> l, _) when l[0].$2 == 5 => 7,
      (List<(int, int)> l, _) when l[0].$2 == 4 => 6,
      (List<(int, int)> l, int j) when j == 0 && l[0].$2 == 3 && l[1].$2 == 2 =>
        5,
      (List<(int, int)> l, int j) when j == 1 && l[0].$2 == 3 && l[1].$2 == 3 =>
        5,
      (List<(int, int)> l, _) when l[0].$2 == 3 => 4,
      (List<(int, int)> l, int j) when j == 0 && l[0].$2 == 2 && l[1].$2 == 2 =>
        3,
      (_, int j) when j == 1 => 2,
      (List<(int, int)> l, _) when l[0].$2 == 2 => 2,
      (List<(int, int)> l, _) when l[0].$2 == 1 => 1,
      _ => throw Exception("Unknown type: $this, $countList, $jokers")
    };

    print('$this, ${switch (score) {
      1 => 'Single',
      2 => 'Pair',
      3 => 'Two Pair',
      4 => 'Three of a Kind',
      5 => 'Full House',
      6 => 'Four of a Kind',
      7 => 'Five of a Kind',
      _ => 'Unknown'
    }}');

    return score;
  }

  int typeScore() {
    final countMap = runes.fold(<int, int>{}, (acc, rune) {
      acc[rune] = (acc[rune] ?? 0) + 1;
      return acc;
    });
    return switch (countMap) {
      Map<int, int> m when m.length == 1 && m.values.contains(5) => 7,
      Map<int, int> m when m.length == 2 && m.values.contains(4) => 6,
      Map<int, int> m when m.length == 2 && m.values.contains(3) => 5,
      Map<int, int> m when m.length == 3 && m.values.contains(3) => 4,
      Map<int, int> m when m.length == 3 => 3,
      Map<int, int> m when m.length == 4 => 2,
      Map<int, int> m when m.length == 5 => 1,
      _ => 0
    };
  }

  int aScore() => typeScore() * 1000000000000 + orderedScore();
  int bScore() =>
      typeScoreWithJoker() * 1000000000000 + orderedScoreWithJoker();
}
