import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service_example/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _cachedApiKey = "";
  AmityEndpointRegion _cachedRegion = AmityEndpointRegion.custom;
  String _cachedHttpUrl = "";
  String _cachedSocketUrl = "";
  String _cachedMqttUrl = "";
  String _cachedUploadUrl = "";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedApiKey = prefs.getString('apiKey') ?? "";
    final cachedRegionString = prefs.getString('selectedRegion');
    if (cachedRegionString != null) {
      _cachedRegion = AmityEndpointRegion.values.firstWhere(
        (e) => e.toString() == cachedRegionString,
        orElse: () => AmityEndpointRegion.sg,
      );
    } else {
      _cachedRegion = AmityEndpointRegion.custom;
    }
    _cachedHttpUrl = prefs.getString('customUrl') ?? "";
    _cachedSocketUrl = prefs.getString('customSocketUrl') ?? "";
    _cachedMqttUrl = prefs.getString('customMqttUrl') ?? "";
    _cachedUploadUrl = prefs.getString('customUploadUrl') ?? "";

    print('cachedApiKey: $_cachedApiKey');
    print('cachedRegion: $_cachedRegion');
    print('cachedHttpUrl: $_cachedHttpUrl');
    print('cachedSocketUrl: $_cachedSocketUrl');
    print('cachedMqttUrl: $_cachedMqttUrl');

    if (_cachedApiKey.isNotEmpty) {
      if (_cachedRegion != AmityEndpointRegion.custom) {
        await AmityUIKit().setup(
          apikey: _cachedApiKey,
          region: _cachedRegion,
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AmityApp()));
      } else if (_cachedRegion == AmityEndpointRegion.custom &&
          _cachedHttpUrl.isNotEmpty &&
          _cachedSocketUrl.isNotEmpty &&
          _cachedMqttUrl.isNotEmpty &&
          _cachedUploadUrl.isNotEmpty) {
        await AmityUIKit().setup(
            apikey: _cachedApiKey,
            region: _cachedRegion,
            customEndpoint: _cachedHttpUrl,
            customSocketEndpoint: _cachedSocketUrl,
            customMqttEndpoint: _cachedMqttUrl,
            customUploadEndpoint: _cachedUploadUrl);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AmityApp()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
