// ignore_for_file: use_build_context_synchronously

import 'package:amity_uikit_beta_service/amity_uikit.dart';

enum AmityRegion {
  sg,
  eu,
  us,
  custom; // Added for custom URLs

  AmityEndpointRegion toEndpointRegion() {
    switch (this) {
      case AmityRegion.sg:
        return AmityEndpointRegion.sg;
      case AmityRegion.eu:
        return AmityEndpointRegion.eu;
      case AmityRegion.us:
        return AmityEndpointRegion.us;
      case AmityRegion.custom:
        return AmityEndpointRegion.custom;
    }
  }
}

@Deprecated("Use AmityUIKit instead")
class AmitySLEUIKit extends AmityUIKit {
  @Deprecated("Use AmityUIKit.setup() instead")
  Future<void> initUIKit({
    required String apikey,
    required AmityRegion region,
    String? customEndpoint,
    String? customSocketEndpoint,
    String? customMqttEndpoint,
  }) {
    return super.setup(
      apikey: apikey,
      region: region.toEndpointRegion(),
      customEndpoint: customEndpoint,
      customSocketEndpoint: customSocketEndpoint,
      customMqttEndpoint: customMqttEndpoint,
    );
  }
}

@Deprecated("Use AmityUIKitProvider instead")
class AmitySLEProvider extends AmityUIKitProvider {
  const AmitySLEProvider({super.key, required super.child});
}
