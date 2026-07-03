import 'package:amity_uikit_beta_service/v4/chat/message/bloc/chat_page_bloc.dart';

/// Pure decision helpers for the one-to-one chat loading toast lifecycle.
///
/// Extracted from `chat_page.dart` so the show/dismiss conditions are
/// unit-testable without the Amity SDK, and so the dismiss can be driven
/// from a `BlocListener` (every state) instead of `BlocBuilder.builder`
/// (coalesced per frame).

/// The loading toast should be shown only while the page is still in its
/// initial state and the chat was not opened as a just-created conversation.
bool shouldShowChatLoadingToast(ChatPageState state, bool isJustCreated) =>
    state is ChatPageStateInitial && !isJustCreated;

/// The loading toast should be dismissed as soon as the page has left the
/// initial state and is no longer fetching.
bool shouldDismissChatLoadingToast(ChatPageState state) =>
    !state.isFetching && state is! ChatPageStateInitial;
