import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amity_uikit_beta_service/amity_uikit_beta_service_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAmityUikitBetaService platform = MethodChannelAmityUikitBetaService();
  const MethodChannel channel = MethodChannel('amity_uikit_beta_service');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
