# isolate_task_queue

A Dart package that provides a task queue mechanism utilizing Flutter isolates to manage and execute asynchronous tasks sequentially.

# Features

 - Sequential Task Execution: Ensures tasks are executed one after another, maintaining order and preventing race conditions.
 - Parallel Task Execution: Ensures a limited number of tasks are executed concurrently, enhancing efficiency.
 - Isolate Utilization: Leverages Dart's isolate system to perform tasks without blocking the main thread, enhancing performance.

# Getting Started

To use isolate_task_queue in your Flutter project:

## Add Dependency:

Add the following to your pubspec.yaml file:

```yaml
dependencies:
isolate_task_queue: ^0.0.1
```

## Import the Package:

In your Dart code, import the package:

```dart
import 'package:isolate_task_queue/isolate_task_queue.dart';
```

# Usage
Here's a basic example of how to use isolate_task_queue:

```dart
void main() async {
final queue = SimpleTaskQueue();

queue.add(() async {
print("Task 1 start");
await Future.delayed(Duration(seconds: 2));
print("Task 1 end");
});

queue.add(() async {
print("Task 2 start");
await Future.delayed(Duration(seconds: 1));
print("Task 2 end");
});

queue.add(() async {
print("Task 3 start");
await Future.delayed(Duration(milliseconds: 500));
print("Task 3 end");
});

print("All tasks added to the queue");
}
```

In this example, each task is added to the queue and will execute sequentially, ensuring that each task completes before the next begins.

# Additional Information

 . License: This project is licensed under the MIT License. See the LICENSE file for details.
 . Contributions: Contributions are welcome! Please open issues or submit pull requests for any enhancements or bug fixes.
 . Author: mikes222

