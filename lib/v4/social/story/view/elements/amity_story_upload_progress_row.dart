import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:flutter/material.dart';

class AmityStoryUploadProgressRow extends StatelessWidget {
  AmityStoryUploadProgressRow({super.key});

  final _getText =
      AmityUIKit4Manager.freedomBehavior.localizationBehavior.getText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _getText(context, 'story_uploading') ?? "Uploading...",
            style: const TextStyle(color: Colors.white , fontSize: 15 , fontFamily: "SF Pro Text" , fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
