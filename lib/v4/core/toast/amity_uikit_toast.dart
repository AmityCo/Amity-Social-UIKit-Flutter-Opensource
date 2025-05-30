import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/rotating_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

enum AmityToastIcon { success, warning, loading }

class AmityToast extends StatefulWidget {
  final String? pageId;
  final String? componentId;
  final String elementId;

  const AmityToast({super.key, this.pageId, this.componentId, required this.elementId});

  @override
  State<AmityToast> createState() => _AmityToastState();
}

class _AmityToastState extends State<AmityToast> {
  late final AmityThemeColor theme;
  late final ConfigProvider configProvider;
  late final AmityUIConfig uiConfig;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    configProvider = context.watch<ConfigProvider>();
    theme = configProvider.getTheme(widget.pageId, widget.componentId);
    uiConfig = configProvider.getUIConfig(widget.pageId, widget.componentId, widget.elementId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AmityToastBloc, AmityToastState>(
        builder: (context, state) {
      return renderToast(context, state);
    });
  }

  Widget renderToast(BuildContext context, AmityToastState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if widget is still mounted
      
      if (state.style == AmityToastStyle.short) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: renderToastContent(
                message: state.message,
                icon: state.icon,
                bottomPadding: state.bottomPadding),
            elevation: 0,
            backgroundColor: const Color(0x00000000),
            onVisible: () => Future.delayed(const Duration(seconds: 3), () {
              // Safely access the context by checking if widget is still mounted
              if (mounted) {
                try {
                  context.read<AmityToastBloc>().add(AmityToastDismiss());
                } catch (e) {
                  // Widget might be disposed, ignore the error
                }
              }
            }),
          ));
      } else if (state.style == AmityToastStyle.loading) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: renderToastContent(
                message: state.message,
                icon: state.icon,
                bottomPadding: state.bottomPadding),
            elevation: 0,
            backgroundColor: const Color(0x00000000),
            duration: const Duration(days: 1),
          ));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
    return Container();
  }

  Widget renderToastContent(
      {required String message,
      AmityToastIcon? icon,
      double bottomPadding = 0}) {
    final toastIcon = icon ?? AmityToastIcon.warning;
    String iconAsset;
    var shouldRotate = false;
    if (toastIcon == AmityToastIcon.success) {
      iconAsset = 'assets/Icons/amity_ic_toast_success.svg';
    } else if (toastIcon == AmityToastIcon.warning) {
      iconAsset = 'assets/Icons/amity_ic_toast_warning.svg';
    } else {
      iconAsset = 'assets/Icons/amity_ic_toast_warning.svg';
    }
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: IntrinsicHeight(
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: theme.secondaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            shadows: const [
              BoxShadow(
                color: Color(0x28000000),
                blurRadius: 16,
                offset: Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 2,
                offset: Offset(0, 0),
                spreadRadius: 0,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: toastIcon == AmityToastIcon.loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.white.withOpacity(0.5),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.primaryColor),
                        ),
                      )
                    : SizedBox(
                        width: 24,
                        height: 24,
                        child: RotatingSvgPicture(
                          iconAsset: iconAsset,
                          shouldRotate: shouldRotate,
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 18, right: 16, bottom: 18),
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AmityTextStyle.body(Colors.white),
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
