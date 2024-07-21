import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

enum AmityToastIcon { success, warning }

class AmityToast extends BaseElement {
  AmityToast({super.key, required super.elementId});

  @override
  Widget buildElement(BuildContext context) {
    return BlocBuilder<AmityToastBloc, AmityToastState>(
        builder: (context, state) {
      return renderToast(context, state);
    });
  }

  Widget renderToast(BuildContext context, AmityToastState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.style == AmityToastStyle.short) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: renderToastContent(message: state.message, icon: state.icon),
            elevation: 0,
            backgroundColor: const Color(0x00000000),
            onVisible: () => Future.delayed(const Duration(seconds: 5), () {
              context.read<AmityToastBloc>().add(AmityToastDismiss());
            }),
          ));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
    return Container();
  }

  Widget renderToastContent({required String message, AmityToastIcon? icon}) {
    final toastIcon = icon ?? AmityToastIcon.warning;
    String iconAsset;
    if (toastIcon == AmityToastIcon.success) {
      iconAsset = 'assets/Icons/amity_ic_toast_success.svg';
    } else if (toastIcon == AmityToastIcon.warning) {
      iconAsset = 'assets/Icons/amity_ic_toast_warning.svg';
    } else {
      iconAsset = 'assets/Icons/amity_ic_toast_warning.svg';
    }
    return IntrinsicHeight(
      child: Container(
        width: double.infinity,
        // height: 56,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: theme.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            Container(
              width: 48,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            iconAsset,
                            package: 'amity_uikit_beta_service',
                            width: 24,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 18, right: 16, bottom: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
