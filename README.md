# isolate_task_queue

A Dart package that provides a task queue mechanism as well as isolates to manage and execute asynchronous tasks.

# Features

 - Sequential Task Execution: Ensures tasks are executed one after another, maintaining order and preventing race conditions.
 - Parallel Task Execution: Ensures a limited number of tasks are executed concurrently, enhancing efficiency.
 - Isolate Utilization: Leverages Dart's isolate system to perform tasks without blocking the main thread, enhancing performance.

# Getting Started

To use isolate_task_queue in your Flutter project:

**Add Dependency:**

Add the following to your pubspec.yaml file:

```yaml
dependencies:
  isolate_task_queue: ^1.0.0
```

**Import the Package:**

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
    
    print("All tasks added to the queue and will execute sequentially.");
}
```

In this example, each task is added to the queue and will execute sequentially, ensuring that each task completes before the next begins.


=====

# Simple Isolate

Consider using Isolate.run() instead if this is the only usecase for you
```dart
@pragma('vm:entry-point')
Future<String> entryPoint(int key) async {
  await Future.delayed(Duration(seconds: key));
  return "Hello Tester, wait: $key secs, is isolate: $isIsolate";
}
```

# Isolate with class with instanceparam

First, create your class without considering isolates:

```dart
class WorkingClass {
  final String instanceparam;

  WorkingClass(this.instanceparam);

  Future<String> entryPoint(int key) async {
    await Future.delayed(Duration(seconds: key));
    return "Hello $instanceparam tester, wait: $key secs, is isolate: $isIsolate";
  }
}
```

Afterwards create a wrapper to use the class in an isolate. Note that we keep the signature of the methods same as the original class so it is easily interchangeable.

```dart
@pragma('vm:entry-point')
class IsolateWorkingClass {
  late final FlutterIsolateInstance _isolateInstance;

  static WorkingClass? _workingClass;

  static Future<IsolateWorkingClass> instantiate(String instanceparam) async {
    IsolateWorkingClass isolateWorkingClass = IsolateWorkingClass();
    isolateWorkingClass._isolateInstance = await FlutterIsolateInstance.createInstance(createInstance: createInstanceStatic, instanceParams: instanceparam);
    return isolateWorkingClass;
  }

  // same method signature as the original WorkingClass method
  Future<String> entryPoint(int key) async {
    return await _isolateInstance.compute(entryPointStatic, key);
  }

  @pragma('vm:entry-point')
  static void createInstanceStatic(Object object) {
    _workingClass = WorkingClass(object as String);
  }

  @pragma('vm:entry-point')
  static Future<String> entryPointStatic(int key) async {
    return _workingClass!.entryPoint(key);
  }
}
```

Now use the new isolate. This usecase is useful if you need to handle large quantities of data to the isolate which are not changing during the lifetime of the isolate.

```dart
    IsolateWorkingClass workingClass = await IsolateWorkingClass.instantiate("isolateParams");
    String reply = await workingClass.entryPoint(2);
```

# Todo:

- Isolate returns a  stream of events
- Isolatepool if you are not allowed to concurrently call the isolate method


# Additional Information

 - License: This project is licensed under the MIT License. See the LICENSE file for details.
 - Contributions: Contributions are welcome! Please open issues or submit pull requests for any enhancements or bug fixes.
 - Author: mikes222

