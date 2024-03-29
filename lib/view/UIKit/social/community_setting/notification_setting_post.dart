import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ReactPostNotificationSetting { everyone, onlyModerator, off }

enum NewPostNotificationSetting { everyone, onlyModerator, off }

class PostNotificationSettingPage extends StatefulWidget {
  final AmityCommunity community;

  const PostNotificationSettingPage({Key? key, required this.community})
      : super(key: key);

  @override
  _PostNotificationSettingPageState createState() =>
      _PostNotificationSettingPageState();
}

class _PostNotificationSettingPageState
    extends State<PostNotificationSettingPage> {
  ReactPostNotificationSetting _reactPostSetting =
      ReactPostNotificationSetting.everyone;
  NewPostNotificationSetting _newPostSetting =
      NewPostNotificationSetting.everyone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.chevron_left,
              color: Provider.of<AmityUIConfiguration>(context).appColors.base,
              size: 30),
        ),
        title: Text(
          'Posts',
          style: TextStyle(
            color: Provider.of<AmityUIConfiguration>(context).appColors.base,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          // Section 1: React Posts

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "React Posts",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color:
                    Provider.of<AmityUIConfiguration>(context).appColors.base,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 16, right: 16),
            child: Text(
              "Receive notifications when someone make a reaction to your posts in this community",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff636878),
              ),
            ),
          ),

          _buildRadioTile<ReactPostNotificationSetting>(
            title: 'Everyone',
            value: ReactPostNotificationSetting.everyone,
            groupValue: _reactPostSetting,
            onChanged: (value) {
              setState(() {
                _reactPostSetting = value!;
              });
            },
          ),
          _buildRadioTile<ReactPostNotificationSetting>(
            title: 'Only Moderator',
            value: ReactPostNotificationSetting.onlyModerator,
            groupValue: _reactPostSetting,
            onChanged: (value) {
              setState(() {
                _reactPostSetting = value!;
              });
            },
          ),
          _buildRadioTile<ReactPostNotificationSetting>(
            title: 'Off',
            value: ReactPostNotificationSetting.off,
            groupValue: _reactPostSetting,
            onChanged: (value) {
              setState(() {
                _reactPostSetting = value!;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Divider(
              thickness: 1,
            ),
          ),

          // Section 2: New Posts
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "React Posts",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xff292B32),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 16, right: 16),
            child: Text(
              "Receive notifications when someone make a reaction to your posts in this community",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff636878),
              ),
            ),
          ),
          _buildRadioTile<NewPostNotificationSetting>(
            title: 'Everyone',
            value: NewPostNotificationSetting.everyone,
            groupValue: _newPostSetting,
            onChanged: (value) {
              setState(() {
                _newPostSetting = value!;
              });
            },
          ),
          _buildRadioTile<NewPostNotificationSetting>(
            title: 'Only Moderator',
            value: NewPostNotificationSetting.onlyModerator,
            groupValue: _newPostSetting,
            onChanged: (value) {
              setState(() {
                _newPostSetting = value!;
              });
            },
          ),
          _buildRadioTile<NewPostNotificationSetting>(
            title: 'Off',
            value: NewPostNotificationSetting.off,
            groupValue: _newPostSetting,
            onChanged: (value) {
              setState(() {
                _newPostSetting = value!;
              });
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xff292B32),
        ),
      ),
    );
  }

  Widget _buildRadioTile<T>(
      {required String title,
      required T value,
      required T groupValue,
      required void Function(T?) onChanged}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Provider.of<AmityUIConfiguration>(context).appColors.base,
        ),
      ),
      trailing: Radio<T>(
        focusColor: Provider.of<AmityUIConfiguration>(context).primaryColor,
        activeColor: Provider.of<AmityUIConfiguration>(context).primaryColor,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }
}
