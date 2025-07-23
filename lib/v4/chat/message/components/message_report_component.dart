import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/components/amity_message_report_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/components/amity_message_report_reason_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/components/message_report_error_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class AmityMessageReportComponent extends NewBaseComponent {
  final AmityMessage message;
  final Function()? onCancel;

  AmityMessageReportComponent({
    Key? key,
    required this.message,
    this.onCancel,
  }) : super(key: key, componentId: 'message_report');

  @override
  Widget buildComponent(BuildContext context) {
    return _MessageReportComponentContent(
      message: message,
      onCancel: onCancel,
      theme: theme,
    );
  }
}

class _MessageReportComponentContent extends StatefulWidget {
  final AmityMessage message;
  final Function()? onCancel;
  final AmityThemeColor theme;

  const _MessageReportComponentContent({
    Key? key,
    required this.message,
    required this.theme,
    this.onCancel,
  }) : super(key: key);

  @override
  _MessageReportComponentContentState createState() =>
      _MessageReportComponentContentState();
}

class _MessageReportComponentContentState
    extends State<_MessageReportComponentContent> {
  PageController _pageController = PageController();
  StreamSubscription<AmityMessage>? _messageStreamSubscription;
  bool _isMessageDeleted = false;

  @override
  void initState() {
    super.initState();
    _setupMessageListener();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _messageStreamSubscription?.cancel();
    super.dispose();
  }

  void _setupMessageListener() {
    _messageStreamSubscription =
        widget.message.listen.stream.listen((updatedMessage) {
      if (mounted) {
        final bool messageDeleted = updatedMessage.isDeleted == true ||
            updatedMessage.syncState == AmityMessageSyncState.FAILED;

        if (messageDeleted && !_isMessageDeleted) {
          setState(() {
            _isMessageDeleted = true;
          });
        }
      }
    });
  }

  void _goToReasonPage() {
    if (!_isMessageDeleted) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBackToMainPage() {
    if (!_isMessageDeleted) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildErrorState(BuildContext context) {
    return MessageReportErrorView(
      theme: widget.theme,
      onCancel: widget.onCancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show error state if message is deleted
    if (_isMessageDeleted) {
      return _buildErrorState(context);
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MessageReportView(
            message: widget.message,
            theme: widget.theme,
            onCancel: widget.onCancel,
            onOthersSelected: _goToReasonPage,
          ),
          MessageReportReasonView(
            message: widget.message,
            theme: widget.theme,
            onCancel: widget.onCancel,
            onBack: _goBackToMainPage,
          ),
        ],
      ),
    );
  }
}
