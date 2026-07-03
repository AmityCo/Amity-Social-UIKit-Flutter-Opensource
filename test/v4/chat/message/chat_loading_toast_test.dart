import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/bloc/chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_loading_toast.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ChatPageStateInitial initialState() => ChatPageStateInitial(
        channelId: 'c1',
        userDisplayName: null,
        avatarUrl: null,
        scrollController: ScrollController(),
      );

  ChatPageState changedState({required bool isFetching}) => ChatPageState(
        channelId: 'c1',
        messages: const [],
        scrollController: ScrollController(),
        isFetching: isFetching,
      );

  group('shouldShowChatLoadingToast', () {
    test('shows on Initial when not just-created', () {
      expect(shouldShowChatLoadingToast(initialState(), false), isTrue);
    });
    test('suppressed when just-created', () {
      expect(shouldShowChatLoadingToast(initialState(), true), isFalse);
    });
    test('not shown once out of Initial', () {
      expect(
          shouldShowChatLoadingToast(changedState(isFetching: true), false),
          isFalse);
    });
  });

  group('shouldDismissChatLoadingToast', () {
    test('dismisses on first non-Initial state with isFetching=false', () {
      expect(shouldDismissChatLoadingToast(changedState(isFetching: false)),
          isTrue);
    });
    test('does not dismiss while still Initial', () {
      expect(shouldDismissChatLoadingToast(initialState()), isFalse);
    });
    test('does not dismiss while fetching', () {
      expect(shouldDismissChatLoadingToast(changedState(isFetching: true)),
          isFalse);
    });
  });
}
