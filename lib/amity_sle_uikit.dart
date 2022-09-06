import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:plugin_uikit/utils/env_manager.dart';
import 'package:provider/provider.dart';

import 'chat_viewmodel/amity_viewmodel.dart';
import 'chat_viewmodel/channel_list_viewmodel.dart';
import 'chat_viewmodel/configuration_viewmodel.dart';
import 'chat_viewmodel/custom_image_picker.dart';
import 'chat_viewmodel/user_viewmodel.dart';

class AmitySLEUIKit {
  Future<void> initUIKit(String apikey, String region) async {
    env = ENV(apikey, region);
    AmityRegionalHttpEndpoint? amityEndpoint;
    if (region.isNotEmpty) {
      switch (region) {
        case "":
          {
            log("REGION is not specify Please check .env file");
          }

          break;
        case "sg":
          {
            amityEndpoint = AmityRegionalHttpEndpoint.SG;
          }

          break;
        case "us":
          {
            amityEndpoint = AmityRegionalHttpEndpoint.US;
          }

          break;
        case "eu":
          {
            amityEndpoint = AmityRegionalHttpEndpoint.EU;
          }
      }
    } else {
      throw "REGION is not specify Please check .env file";
    }

    await AmityCoreClient.setup(
        option:
            AmityCoreClientOption(apiKey: apikey, httpEndpoint: amityEndpoint!),
        sycInitialization: true);
  }

  Future<void> registerDevice(BuildContext context, String userId) async {
    await Provider.of<AmityVM>(context, listen: false)
        .login(userId)
        .then((value) {
      Provider.of<UserVM>(context, listen: false).initAccessToken();
    });
  }

  void configAmityThemeColor(
      BuildContext context, Function(AmityUIConfiguration config) config) {
    var provider = Provider.of<AmityUIConfiguration>(context, listen: false);
    config(provider);
  }
}

class AmitySLEProvider extends StatelessWidget {
  final Widget child;
  const AmitySLEProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserVM>(create: ((context) => UserVM())),
        ChangeNotifierProvider<AmityVM>(create: ((context) => AmityVM())),
        ChangeNotifierProvider<ImagePickerVM>(
            create: ((context) => ImagePickerVM())),
        ChangeNotifierProvider<ChannelVM>(create: ((context) => ChannelVM())),
        ChangeNotifierProvider<AmityUIConfiguration>(
            create: ((context) => AmityUIConfiguration())),
      ],
      child: Builder(
        builder: (context) => child,
      ),
    );
  }
}
