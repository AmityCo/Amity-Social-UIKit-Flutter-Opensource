import 'dart:developer';

import 'package:amity_uikit_beta_service/amity_sle_uikit.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_community_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/explore_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/my_community_feed.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/post_target_page.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
// import 'package:amity_uikit_beta_service_example/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  ///Step 1: Initialize amity SDK with the following function
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  // options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _apiKey = TextEditingController();
  AmityRegion? _selectedRegion;
  final TextEditingController _customUrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey.text = prefs.getString('apiKey') ?? "";

      String? selectedRegionString = prefs.getString('selectedRegion');
      if (selectedRegionString != null) {
        _selectedRegion = AmityRegion.values.firstWhere(
          (e) => e.toString() == selectedRegionString,
          orElse: () => AmityRegion.sg,
        );
      }
      if (_selectedRegion == AmityRegion.custom) {
        _customUrl.text = prefs.getString('customUrl') ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _apiKey,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select Region:'),
            ...AmityRegion.values.map((region) {
              return RadioListTile<AmityRegion>(
                title: Text(region.toString().split('.').last.toUpperCase()),
                value: region,
                groupValue: _selectedRegion,
                onChanged: (AmityRegion? value) {
                  setState(() {
                    _selectedRegion = value;
                    if (value != AmityRegion.custom) {
                      _customUrl.text = ""; // Reset custom URL
                    }
                  });
                },
              );
            }).toList(),
            if (_selectedRegion == AmityRegion.custom) ...[
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Custom URL',
                  border: OutlineInputBorder(),
                ),
                controller: _customUrl,
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
                child: const Text('Initialize'),
                onPressed: () async {
                  if (_selectedRegion != null &&
                      (_selectedRegion != AmityRegion.custom)) {
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.setString('apiKey', _apiKey.text);
                    await prefs.setString(
                        'selectedRegion', _selectedRegion.toString());
                    if (_selectedRegion == AmityRegion.custom) {
                      await prefs.setString('customUrl', _customUrl.text);
                    }
                    log("save pref");

                    await AmitySLEUIKit().initUIKit(
                        apikey: _apiKey.text,
                        region: _selectedRegion!,
                        customEndpoint: _customUrl.text);
                    // Navigate to the nextx page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AmityApp()),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}

class AmityApp extends StatelessWidget {
  const AmityApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AmitySLEProvider(
      child: Builder(builder: (context2) {
        return const UserListPage();
      }),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<String> _usernames = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsernames();
  }

  _loadUsernames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernames = prefs.getStringList('usernames') ?? [];
    });
  }

  _addUsername() async {
    if (_controller.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _usernames.add(_controller.text);
      prefs.setStringList('usernames', _usernames);
      _controller.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addUsername,
            child: const Text('Add Username'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _usernames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_usernames[index]),
                  onTap: () async {
                    log("login");

                    ///Step 3: login with Amity
                    await AmitySLEUIKit().registerDevice(
                      context: context,
                      userId: _usernames[index],
                      callback: (isSuccess, error) {
                        log("callback:$isSuccess");
                        if (isSuccess) {
                          log("success");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  SecondPage(username: _usernames[index]),
                            ),
                          );
                        } else {
                          AmityDialog().showAlertErrorDialog(
                              title: "Error", message: error.toString());
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key, required this.username});
  final String username;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ThirdPage(username: username),
                  ),
                );
              },
              child: const Text('Social'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pushNamed('/third',
                //     arguments: {'username': username, 'feature': 'Chat'});
              },
              child: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key, required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: const Text('Register push notification'),
              onTap: () async {
                // FirebaseMessaging messaging = FirebaseMessaging.instance;

                // NotificationSettings settings =
                //     await messaging.requestPermission();

                // if (settings.authorizationStatus ==
                //         AuthorizationStatus.authorized ||
                //     settings.authorizationStatus ==
                //         AuthorizationStatus.provisional) {
                //   String? token;
                //   String tokenType = Platform.isIOS ? "APNS" : "FCM";

                //   if (Platform.isIOS) {
                //     log("getting token");
                //     token =
                //         await messaging.getAPNSToken().catchError((e) async {
                //       await showDialog(
                //         context: context,
                //         builder: (BuildContext context) {
                //           return AlertDialog(
                //             title: const Text('Error'),
                //             content: Text(e),
                //           );
                //         },
                //       );
                //       return e;
                //     });
                //     log("apns Token : $token");
                //   } else {
                //     token = await messaging.getToken();
                //     log("getting 3token");
                //     token =
                //         await messaging.getAPNSToken().catchError((e) async {
                //       await showDialog(
                //         context: context,
                //         builder: (BuildContext context) {
                //           return AlertDialog(
                //             title: const Text('Error'),
                //             content: Text(e),
                //           );
                //         },
                //       );
                //       return e;
                //     });
                //     log("android token Token : $token");
                //   }

                //   log('Firebase Push Token ($tokenType): $token');
                //   await AmitySLEUIKit().registerNotification(token,
                //       (isSuccess, error) async {
                //     await showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return AlertDialog(
                //           title: isSuccess
                //               ? const Text('Success')
                //               : const Text('Error'),
                //           content: SingleChildScrollView(
                //             child: ListBody(
                //               children: <Widget>[
                //                 Text(isSuccess
                //                     ? 'Push notification registered successfully.\nToken Type: $tokenType\nToken: $token'
                //                     : 'Failed to register push notification.\nError: $error'),
                //                 if (isSuccess)
                //                   ElevatedButton(
                //                     onPressed: () {
                //                       Clipboard.setData(ClipboardData(
                //                           text: token ?? "no token"));
                //                     },
                //                     child: const Text('Copy Token'),
                //                   ),
                //               ],
                //             ),
                //           ),
                //           actions: <Widget>[
                //             TextButton(
                //                 child: const Text('Close'),
                //                 onPressed: () {
                //                   Navigator.of(context).pop();
                //                 }),
                //           ],
                //         );
                //       },
                //     );
                //   });
                // } else {
                //   log('Push notification permission was declined');

                //   // ignore: use_build_context_synchronously
                //   showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return const AlertDialog(
                //         title: Text('Error'),
                //         content:
                //             Text('Push notification permission was declined'),
                //       );
                //     },
                //   );
                // }
              },
            ),
            ListTile(
              title: const Text('unregister'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                AmitySLEUIKit().unRegisterDevice();
              },
            ),
            ListTile(
              title: const Text('Global Feed'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const Scaffold(body: GlobalFeedScreen()),
                ));
              },
            ),
            ListTile(
              title: const Text('User Profile'),
              onTap: () {
                // Navigate or perform action based on 'User Profile' tap
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserProfileScreen(
                          amityUserId: username,
                          amityUser: null,
                        )));
              },
            ),
            ListTile(
              title: const Text('Newsfeed'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
              },
            ),
            ListTile(
              title: const Text('Create Community'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const Scaffold(body: CreateCommunityPage()),
                ));
              },
            ),
            ListTile(
              title: const Text('Create Post'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Scaffold(body: PostToPage()),
                ));
              },
            ),
            ListTile(
              title: const Text('My Community'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Scaffold(body: MyCommunityPage()),
                ));
              },
            ),
            ListTile(
              title: const Text('Explore'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Scaffold(body: CommunityPage()),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
