import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Token resolution for widgets outside the NewBasePage / NewBaseComponent /
/// BaseElement hierarchy — roughly a third of the Chat surface is a plain
/// Stateless/StatefulWidget, and several take an `AmityThemeColor theme` down
/// the constructor instead.
///
/// Those base classes carry their own scope, so they expose `token(...)`
/// directly; use this where there is no such `this` to read. It watches the
/// [ConfigProvider], so the widget rebuilds when the theme or the OS brightness
/// changes — the same guarantee the base classes give.
extension AmityTokenContext on BuildContext {
  /// Resolve a semantic colour token. Supply whichever scope parts the call
  /// site knows; each omitted part is `*`, which still matches the wildcard
  /// customizations and falls through to the global theme.
  Color amityToken(
    AmityColorToken token, {
    String? pageId,
    String? componentId,
    String? elementId,
  }) =>
      watch<ConfigProvider>().token(token,
          pageId: pageId, componentId: componentId, elementId: elementId);

  /// Which palette tokens are resolving against right now. Use only to pick
  /// between two assets — for colour, resolve a token.
  bool get amityIsDarkTheme => watch<ConfigProvider>().isDarkTheme;

  /// The UIKit's current mode as a [Brightness].
  ///
  /// For the platform chrome the UIKit does not paint itself — the iOS
  /// keyboard (`TextField.keyboardAppearance`) and Cupertino popup surfaces
  /// (`CupertinoTheme.brightness`). Those read the ambient Material/Cupertino
  /// theme, which the UIKit never sets, so without this they stay light on a
  /// dark screen. Not a colour: resolve a token for anything the UIKit draws.
  Brightness get amityBrightness =>
      amityIsDarkTheme ? Brightness.dark : Brightness.light;
}
