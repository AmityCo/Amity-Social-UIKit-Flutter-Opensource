import 'package:amity_uikit_beta_service/amity_sle_uikit.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';

import 'package:amity_uikit_beta_service/view/UIKit/social/my_community_feed.dart';

import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_community_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/explore_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/post_target_page.dart';

void main() {
  ///Step 1: Initialize amity SDK with the following function
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
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
      print(_apiKey);
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
        title: Text('API Configuration'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _apiKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('Select Region:'),
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
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Custom URL',
                  border: OutlineInputBorder(),
                ),
                controller: _customUrl,
              ),
            ],
            SizedBox(height: 40),
            ElevatedButton(
                child: Text('Initialize'),
                onPressed: () async {
                  if (_apiKey != null &&
                      _selectedRegion != null &&
                      (_selectedRegion != AmityRegion.custom ||
                          _customUrl != null)) {
                    final prefs = await SharedPreferences.getInstance();
                    print(_apiKey);
                    await prefs.setString('apiKey', _apiKey.text);
                    await prefs.setString(
                        'selectedRegion', _selectedRegion.toString());
                    if (_selectedRegion == AmityRegion.custom &&
                        _customUrl != null) {
                      await prefs.setString('customUrl', _customUrl.text);
                    }
                    print("save pref");

                    await AmitySLEUIKit().initUIKit(
                        apikey: _apiKey.text,
                        region: _selectedRegion!,
                        customEndpoint: _customUrl.text);
                    // Navigate to the nextx page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AmityApp()),
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
        return UserListPage();
      }),
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<String> _usernames = [];
  TextEditingController _controller = TextEditingController();

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
        title: Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addUsername,
            child: Text('Add Username'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _usernames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_usernames[index]),
                  onTap: () async {
                    print("login");

                    ///Step 3: login with Amity
                    await AmitySLEUIKit().registerDevice(
                      context: context,
                      userId: _usernames[index],
                      callback: (isSuccess, error) {
                        print("callback:${isSuccess}");
                        if (isSuccess) {
                          print("success");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  SecondPage(username: _usernames[index]),
                            ),
                          );
                        } else {
                          print(error);
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
              child: Text('Social'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pushNamed('/third',
                //     arguments: {'username': username, 'feature': 'Chat'});
              },
              child: Text('Chat'),
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text('Register push notification'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                AmitySLEUIKit().registerNotification("asdasdasdasd",
                    (isSuccess, error) {
                  return;
                });
              },
            ),
            ListTile(
              title: Text('unregister'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                AmitySLEUIKit().unRegisterDevice();
              },
            ),
            ListTile(
              title: Text('Global Feed'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const Scaffold(body: GlobalFeedScreen()),
                ));
              },
            ),
            ListTile(
              title: Text('User Profile'),
              onTap: () {
                // Navigate or perform action based on 'User Profile' tap
              },
            ),
            ListTile(
              title: Text('Newsfeed'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
              },
            ),
            ListTile(
              title: Text('Create Community'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(body: CreateCommunityPage()),
                ));
              },
            ),
            ListTile(
              title: Text('Create Post'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(body: PostToPage()),
                ));
              },
            ),
            ListTile(
              title: Text('My Community'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(body: MyCommunityPage()),
                ));
              },
            ),
            ListTile(
              title: Text('Explore'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(body: CommunityPage()),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
