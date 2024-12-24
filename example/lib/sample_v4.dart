import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:flutter/material.dart';

class SampleV4 extends StatelessWidget {
  const SampleV4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Global Feed'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PopScope(
                      canPop: true,
                      child: const SocialHomePageConfigProviderWidget(),
                      onPopInvoked: (didPop) => {},
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
