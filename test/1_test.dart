import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

List<int> detectInts(String s) {
  var ints = <int>[];
  for (var i = 0; i < s.length; i++) {
    var c = s[i];
    var maybeInt = int.tryParse(c);
    if (maybeInt != null) {
      ints.add(maybeInt);
      continue;
    }

    try {
      switch (c) {
        case 'o':
          if (s[i + 1] == 'n' && s[i + 2] == 'e') {
            ints.add(1);
          }
          break;
        case 't':
          if (s[i + 1] == 'w' && s[i + 2] == 'o') {
            ints.add(2);
          }
          if (s[i + 1] == 'h' &&
              s[i + 2] == 'r' &&
              s[i + 3] == 'e' &&
              s[i + 4] == 'e') {
            ints.add(3);
          }
          break;
        case 'f':
          if (s[i + 1] == 'o' && s[i + 2] == 'u' && s[i + 3] == 'r') {
            ints.add(4);
          }
          if (s[i + 1] == 'i' && s[i + 2] == 'v' && s[i + 3] == 'e') {
            ints.add(5);
          }
          break;
        case 's':
          if (s[i + 1] == 'i' && s[i + 2] == 'x') {
            ints.add(6);
          }
          if (s[i + 1] == 'e' &&
              s[i + 2] == 'v' &&
              s[i + 3] == 'e' &&
              s[i + 4] == 'n') {
            ints.add(7);
          }
          break;
        case 'e':
          if (s[i + 1] == 'i' &&
              s[i + 2] == 'g' &&
              s[i + 3] == 'h' &&
              s[i + 4] == 't') {
            ints.add(8);
          }
          break;
        case 'n':
          if (s[i + 1] == 'i' && s[i + 2] == 'n' && s[i + 3] == 'e') {
            ints.add(9);
          }
          break;
        case 'z':
          if (s[i + 1] == 'e' && s[i + 2] == 'r' && s[i + 3] == 'o') {
            ints.add(0);
          }
          break;
        default:
      }
    } catch (e) {}
  }
  return ints;
}

void main() {
  test('Day 1', () async {
    final start = DateTime.now();
    await File('inputs/input1.txt')
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map(detectInts)
        .map((ints) => ints.first * 10 + ints.last)
        .reduce((a, b) => a + b)
        .then(print);
    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });
}
