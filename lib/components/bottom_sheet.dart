import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showOptionsBottomSheet(
  BuildContext context,
  AmityUser user,
) {
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Wrap(
            children: [
              user.isFlaggedByMe
                  ? ListTile(
                      title: const Text('Unreport User'),
                      onTap: () {
                        Provider.of<UserVM>(context, listen: false)
                            .reportOrUnReportUser(user);
                        Navigator.pop(context);
                      },
                    )
                  : ListTile(
                      title: const Text('Report User'),
                      onTap: () {
                        Provider.of<UserVM>(context, listen: false)
                            .reportOrUnReportUser(user);
                        Navigator.pop(context);
                      },
                    ),
            ],
          ),
        );
      });
}
