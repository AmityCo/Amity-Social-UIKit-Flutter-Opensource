import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/configuration_viewmodel.dart';

class CreatePostScreen extends StatefulWidget {
  final AmityPost? post;
  const CreatePostScreen({super.key, this.post});
  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppbar = AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text("create Post",
          style: theme.textTheme.titleLarge!
              .copyWith(fontWeight: FontWeight.w500)),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left),
      ),
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppbar.preferredSize.height;
    return Scaffold(
      appBar: myAppbar,
      body: FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: Container(
          height: bheight,
          color: Colors.white,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  getAvatarImage(AmityCoreClient.getCurrentUser().avatarUrl),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: mediaQuery.size.width - 150,
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Say Something about this photo',
                      ),
                      // style: theme.textTheme.bodyText1.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Expanded(
                flex: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadedScaleAnimation(
                      child: Image.asset('assets/images/Layer884.png')),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const CreatePostScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  decoration: BoxDecoration(
                    color:
                        Provider.of<AmityUIConfiguration>(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Submit Post",
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApplicationColors {}
