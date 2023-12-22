import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'amity_uikit_beta_service_method_channel.dart';

abstract class AmityUikitBetaServicePlatform extends PlatformInterface {
  /// Constructs a AmityUikitBetaServicePlatform.
  AmityUikitBetaServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static AmityUikitBetaServicePlatform _instance = MethodChannelAmityUikitBetaService();

  /// The default instance of [AmityUikitBetaServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelAmityUikitBetaService].
  static AmityUikitBetaServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AmityUikitBetaServicePlatform] when
  /// they register themselves.
  static set instance(AmityUikitBetaServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
