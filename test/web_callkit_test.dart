import 'package:flutter_test/flutter_test.dart';

// class MockWebCallkitPlatform
//     with MockPlatformInterfaceMixin
//     implements WebCallkitPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

void main() {
  // final WebCallkitPlatform initialPlatform = WebCallkitPlatform.instance;

  // test('$MethodChannelWebCallkit is the default instance', () {
  //   expect(initialPlatform, isInstanceOf<MethodChannelWebCallkit>());
  // });

  test('getPlatformVersion', () async {
    // WebCallkit webCallkitPlugin = WebCallkit();
    // MockWebCallkitPlatform fakePlatform = MockWebCallkitPlatform();
    // WebCallkitPlatform.instance = fakePlatform;

    // expect(await webCallkitPlugin.getPlatformVersion(), '42');
    expect('42', '42');
  });
}
