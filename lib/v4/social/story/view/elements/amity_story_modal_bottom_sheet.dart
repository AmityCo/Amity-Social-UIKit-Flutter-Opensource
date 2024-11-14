import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

void amityStoryModalBottomSheetOverFlowMenu({required BuildContext context, required String storyId, required Function onDeleted , required AmityStory story , required Function (String) deleteClicked}) {
  showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AmityStoryModelBottomSheet(
          storyId: storyId,
          onDeleted: onDeleted,
          deleteClicked: deleteClicked, 
          // parentContext: context,
        );
      }).then((value) {
  });
}

class AmityStoryModelBottomSheet extends StatelessWidget {
  final String storyId;
  final Function onDeleted;
  final Function (String) deleteClicked;
  // final BuildContext parentContext ;
  // final Function (String) deleteStory;
  const AmityStoryModelBottomSheet({super.key, required this.storyId, required this.onDeleted  , required this.deleteClicked});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewStoryBloc(),
      child: BlocConsumer<ViewStoryBloc, ViewStoryState>(listener: (context, state) {
        if (state is StoryDeletedState) {
          onDeleted();
          Navigator.of(context).pop();
        }
      }, builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 148,
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 22),
                child: AmityBottomSheetActionItem(
                  icon: "assets/Icons/ic_bin_red.svg",
                  text: 'Delete story',
                  onTap: () {
                    deleteClicked(storyId);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class AmityBottomSheetActionItem extends StatelessWidget {
  final String icon;
  final String text;
  final Function onTap;
  const AmityBottomSheetActionItem({super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              package: 'amity_uikit_beta_service',
              height: 20,
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: "SF Pro Text",
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
