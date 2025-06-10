import 'package:isolate_task_queue/isolate_task_queue.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

/// In our main isolate we will set it to folse so everytime we are in an isolate we will have true here
bool isIsolate = true;

void main() {
  group('A group of tests', () {
    //final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
      isIsolate = false;
    });

    // This is the simplest form of calling an isolate. Consider using Isolate.run() instead
    test('Simple Isolate', () async {
      // measure the time needed for this method
      int time = DateTime.now().millisecondsSinceEpoch;
      String reply = await FlutterIsolateInstance.isolateCompute(entryPoint, 2);
      expect(DateTime.now().millisecondsSinceEpoch - time, greaterThan(2000));
      expect(reply, equals("Hello Tester, wait: 2 secs, is isolate: true"));
    });

    /// An isolate which is initialized during construction time. Use this if you need to handle large quantities of data to the isolate which are not
    /// changing during the lifetime of the isolate.
    test('Isolate with class with instanceparam', () async {
      {
        // measure the time needed for this method
        int time = DateTime.now().millisecondsSinceEpoch;
        // test class without isolate
        WorkingClass workingClass = WorkingClass("classParams");
        String reply = await workingClass.entryPoint(2);
        expect(DateTime.now().millisecondsSinceEpoch - time, greaterThan(2000));
        expect(reply, equals("Hello classParams tester, wait: 2 secs, is isolate: false"));
      }
      {
        int time = DateTime.now().millisecondsSinceEpoch;
        // test class with isolate
        IsolateWorkingClass workingClass = await IsolateWorkingClass.instantiate("isolateParams");
        String reply = await workingClass.entryPoint(2);
        expect(DateTime.now().millisecondsSinceEpoch - time, greaterThan(2000));
        expect(reply, equals("Hello isolateParams tester, wait: 2 secs, is isolate: true"));
      }
    });

    test('Isolate multiple calls to one isolate', () async {
      {
        int time = DateTime.now().millisecondsSinceEpoch;
        // test class with isolate
        IsolateWorkingClass workingClass = await IsolateWorkingClass.instantiate("isolateParams");
        Future<String> w1 = workingClass.entryPoint(3);
        Future<String> w2 = workingClass.entryPoint(1);
        Future<String> w3 = workingClass.entryPoint(2);
        expect(DateTime.now().millisecondsSinceEpoch - time, lessThan(500));
        String reply1 = await w1;
        expect(DateTime.now().millisecondsSinceEpoch - time, greaterThan(3000));
        String reply2 = await w2;
        String reply3 = await w3;
        expect(DateTime.now().millisecondsSinceEpoch - time, lessThan(4000));
        expect(reply1, equals("Hello isolateParams tester, wait: 3 secs, is isolate: true"));
        expect(reply2, equals("Hello isolateParams tester, wait: 1 secs, is isolate: true"));
        expect(reply3, equals("Hello isolateParams tester, wait: 2 secs, is isolate: true"));
      }
    });
  });
}

//////////////////////////////////////////////////////////////////////////////

@pragma('vm:entry-point')
Future<String> entryPoint(int key) async {
  await Future.delayed(Duration(seconds: key));
  return "Hello Tester, wait: $key secs, is isolate: $isIsolate";
}

//////////////////////////////////////////////////////////////////////////////

/// A wrapper to use the [WorkingClass] in an isolate. Note that we keep the signature of the methods same as the original class so it is easily interchangeable.
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

//////////////////////////////////////////////////////////////////////////////

/// A simple class without considering isolates
class WorkingClass {
  final String instanceparam;

  WorkingClass(this.instanceparam);

  Future<String> entryPoint(int key) async {
    await Future.delayed(Duration(seconds: key));
    return "Hello $instanceparam tester, wait: $key secs, is isolate: $isIsolate";
  }
}
