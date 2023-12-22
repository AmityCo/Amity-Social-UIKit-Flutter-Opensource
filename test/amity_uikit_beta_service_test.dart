import 'package:flutter_test/flutter_test.dart';
import 'package:amity_uikit_beta_service/amity_uikit_beta_service.dart';
import 'package:amity_uikit_beta_service/amity_uikit_beta_service_platform_interface.dart';
import 'package:amity_uikit_beta_service/amity_uikit_beta_service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAmityUikitBetaServicePlatform
    with MockPlatformInterfaceMixin
    implements AmityUikitBetaServicePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AmityUikitBetaServicePlatform initialPlatform = AmityUikitBetaServicePlatform.instance;

  test('$MethodChannelAmityUikitBetaService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAmityUikitBetaService>());
  });

  test('getPlatformVersion', () async {
    AmityUikitBetaService amityUikitBetaServicePlugin = AmityUikitBetaService();
    MockAmityUikitBetaServicePlatform fakePlatform = MockAmityUikitBetaServicePlatform();
    AmityUikitBetaServicePlatform.instance = fakePlatform;

    expect(await amityUikitBetaServicePlugin.getPlatformVersion(), '42');
  });
}
