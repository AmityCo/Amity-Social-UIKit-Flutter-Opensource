import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/components/message_report_component.dart';
import 'package:flutter/material.dart';

class MessageReportComponentsSample {
  /* begin_sample_code
    gist_id: e7845bde7c331c5d26d58b22c657c456
    filename: MessageReportComponentSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Components for reporting chat messages
    */
  Widget messageReportComponent() {
    // Create a message for this example
    final AmityMessage message = AmityMessage();

    // Report component
    final reportComponent = AmityMessageReportComponent(
      message: message,
    );

    // Return the report component for the example
    return reportComponent;
  }
  /* end_sample_code */
}
