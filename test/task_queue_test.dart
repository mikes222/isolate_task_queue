import 'dart:async';

import 'package:isolate_task_queue/isolate_task_queue.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    //final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    test('Simple task queue', () async {
      List<Future> futures = [];
      TaskQueue taskQueue = SimpleTaskQueue();
      int time = DateTime.now().millisecondsSinceEpoch;
      futures.add(taskQueue.add(() async => Future.delayed(Duration(seconds: 1))));
      futures.add(taskQueue.add(() async => Future.delayed(Duration(seconds: 1))));
      futures.add(taskQueue.add(() async => Future.delayed(Duration(seconds: 1))));
      futures.add(taskQueue.add(() async => Future.delayed(Duration(seconds: 1))));
      int diff = DateTime.now().millisecondsSinceEpoch - time;
      expect(diff, lessThan(50));

      await Future.wait(futures);
      taskQueue.cancel();
      diff = DateTime.now().millisecondsSinceEpoch - time;
      expect(diff, greaterThan(4000));
      expect(diff, lessThan(4500));
    });
  });

  test('Parallel task queue', () async {
    List<Future> futures = [];
    TaskQueue taskQueue = ParallelTaskQueue(2);
    int time = DateTime.now().millisecondsSinceEpoch;
    futures.add(taskQueue.add(() async => Future.delayed(Duration(seconds: 1))));
    futures.add(taskQueue.add(() async => Future.delayed(Duration(seconds: 1))));
    futures.add(taskQueue.add(() async => Future.delayed(Duration(seconds: 1))));
    futures.add(taskQueue.add(() async => Future.delayed(Duration(seconds: 1))));
    int diff = DateTime.now().millisecondsSinceEpoch - time;
    expect(diff, lessThan(50));

    await Future.wait(futures);
    taskQueue.cancel();
    diff = DateTime.now().millisecondsSinceEpoch - time;
    expect(diff, greaterThan(2000));
    expect(diff, lessThan(2500));
  });
}
