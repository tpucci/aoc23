@Timeout(Duration(seconds: 60000))
import 'dart:convert';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Day 8 - a', () async {
    final start = DateTime.now();
    final a = await answerA('inputs/input8.txt');

    expect(a, 21883);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('Day 8 - b', () async {
    final start = DateTime.now();
    final b = await answerB('inputs/input8.txt');

    print(b);

    print('Time: ${DateTime.now().difference(start).inMilliseconds}ms');
  });

  test('example - b', () async {
    expect(await answerB('inputs/input8_example.txt'), 6);
  });
}

Future<int> answerA(String path) async {
  final input = await File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .map((line) => switch (line) {
            String l when l == "" => null,
            String l when l.length >= 5 && l[4] == '=' => line.parseDirection(),
            String _ => line.parseInstruction()
          })
      .fold(Input(), (acc, o) {
    return switch (o) {
      Instruction i => acc..instruction = i,
      Direction d => acc..directions[d.from] = d,
      null => acc,
      _ => throw Exception('Unknown type')
    };
  });

  String current = 'AAA';
  var steps = 0;
  while (current != 'ZZZ') {
    final direction = input.directions[current];
    if (direction == null) {
      throw Exception('No direction for $current');
    }

    final instruction = input
        .instruction.instruction[steps % input.instruction.instruction.length];
    if (instruction == 'L') {
      current = direction.L;
    } else if (instruction == 'R') {
      current = direction.R;
    } else {
      throw Exception('Unknown instruction $instruction');
    }

    steps++;
  }

  return steps;
}

Future<int> answerB(String path) async {
  final input = await File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .map((line) => switch (line) {
            String l when l == "" => null,
            String l when l.length >= 5 && l[4] == '=' => line.parseDirection(),
            String _ => line.parseInstruction()
          })
      .fold(Input(), (acc, o) {
    return switch (o) {
      Instruction i => acc..instruction = i,
      Direction d when d.isStart => acc
        ..directions[d.from] = d
        ..starts.add(d),
      Direction d => acc..directions[d.from] = d,
      null => acc,
      _ => throw Exception('Unknown type')
    };
  });

  final initialStarts = input.starts.toList();

  for (var start in input.starts) {
    String current = start.from;
    var steps = 0;
    while (!input.directions[current]!.isStart || steps == 0) {
      final direction = input.directions[current];
      if (direction == null) {
        throw Exception('No direction for $current');
      }

      final instruction = input.instruction
          .instruction[steps % input.instruction.instruction.length];
      if (instruction == 'L') {
        current = direction.L;
      } else if (instruction == 'R') {
        current = direction.R;
      } else {
        throw Exception('Unknown instruction $instruction');
      }

      steps++;
      if (input.directions[current]!.isEnd) {
        print("start: ${start.from} ends in $steps steps");
      }
    }

    print("start: ${start.from} loops to ${current} in $steps steps");
  }

  var steps = 0;
  while (!input.allEnd) {
    input
      ..starts = input.starts.map((d) {
        final instruction = input.instruction
            .instruction[steps % input.instruction.instruction.length];
        if (instruction == 'L') {
          return input.directions[d.L]!;
        } else if (instruction == 'R') {
          return input.directions[d.R]!;
        } else {
          throw Exception('Unknown instruction $instruction');
        }
      }).toList();

    steps++;
  }

  return steps;
}

class Input {
  Map<String, Direction> directions = {};
  List<Direction> starts = [];
  Instruction instruction = Instruction();

  bool get allEnd => !starts.any((dir) => !dir.isEnd);
}

class Direction {
  String from = '';
  String L = '';
  String R = '';

  bool get isStart => from.endsWith('A');
  bool get isEnd => from.endsWith('Z');
}

class Instruction {
  String instruction = '';
}

extension on String {
  Direction parseDirection() {
    return Direction()
      ..from = this.substring(0, 3)
      ..L = this.substring(7, 10)
      ..R = this.substring(12, 15);
  }

  Instruction parseInstruction() {
    return Instruction()..instruction = this;
  }
}
