import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'amity_uikit_beta_service_platform_interface.dart';

/// An implementation of [AmityUikitBetaServicePlatform] that uses method channels.
class MethodChannelAmityUikitBetaService extends AmityUikitBetaServicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('amity_uikit_beta_service');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
