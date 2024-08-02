part of 'hyperlink_bloc.dart';

class HyperlinkEvent {}


class SetInitalStateEvent extends HyperlinkEvent {
  HyperLink? hyperlink;
  SetInitalStateEvent({ this.hyperlink,});
}

class OnURLErrorEvent extends HyperlinkEvent {
  String? error;
  OnURLErrorEvent({ this.error,});
}


class OnCustmizedErrorEvent extends HyperlinkEvent {
  String? error;
  OnCustmizedErrorEvent({ this.error,});
}


class OnHyperLinkAdded extends HyperlinkEvent {
  HyperLink? hyperlink;
  OnHyperLinkAdded({ this.hyperlink,});
}


class OnRemoveHyperLink extends HyperlinkEvent {
  OnRemoveHyperLink();
}


class LoadingStateHyperLink extends HyperlinkEvent {
  LoadingStateHyperLink();
}


class VerifyAndSaveHyperLinkEvent extends HyperlinkEvent {
  String urlText;
  String customizedText;
  VerifyAndSaveHyperLinkEvent({ required this.urlText, required this.customizedText,});
}
