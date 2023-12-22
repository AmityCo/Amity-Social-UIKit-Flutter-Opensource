
import 'amity_uikit_beta_service_platform_interface.dart';

class AmityUikitBetaService {
  Future<String?> getPlatformVersion() {
    return AmityUikitBetaServicePlatform.instance.getPlatformVersion();
  }
}
