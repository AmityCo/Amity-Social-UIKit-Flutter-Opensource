import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/elements/amity_hyper_link_text_field.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/bloc/hyperlink_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:validators/validators.dart';

void showHyperLinkBottomSheet({required BuildContext context, HyperLink? hyperLink, required Function(HyperLink) onHyperLinkAdded, required Function() onHyperLinkRemoved}) {
  showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.96,
          widthFactor: 1,
          child: HyperLinkBottomSheetContent(
            hyperLink: hyperLink,
            onHyperLinkAdded: (hyperlink) {
              onHyperLinkAdded(hyperlink);
              Navigator.of(context).pop();
            },
            onHyperLinkRemoved: onHyperLinkRemoved,
          ),
        );
      });
}

class HyperLinkBottomSheetContent extends NewBaseComponent {
  final HyperLink? hyperLink;
  final Function(HyperLink) onHyperLinkAdded;
  final Function() onHyperLinkRemoved;
  HyperLinkBottomSheetContent({
    super.key,
    this.hyperLink,
    required this.onHyperLinkAdded,
    required this.onHyperLinkRemoved,
    String? pageId,
  }) : super(pageId: pageId, componentId: "hyperlink_bottom_sheet");

  @override
  Widget buildComponent(BuildContext context) {
    return HyperLinkBottomSheetBuilder(
      onHyperLinkAdded: onHyperLinkAdded,
      onHyperLinkRemoved: onHyperLinkRemoved,
      hyperLink: hyperLink,
      theme: theme,
    );
  }
}

class HyperLinkBottomSheetBuilder extends StatefulWidget {
  final HyperLink? hyperLink;
  final Function(HyperLink) onHyperLinkAdded;
  final Function() onHyperLinkRemoved;
  AmityThemeColor theme;
  HyperLinkBottomSheetBuilder({
    super.key,
    this.hyperLink,
    required this.theme,
    required this.onHyperLinkAdded,
    required this.onHyperLinkRemoved,
  });

  @override
  State<HyperLinkBottomSheetBuilder> createState() => _HyperLinkBottomSheetBuilderState();
}

class AmityColorTheme {}

class _HyperLinkBottomSheetBuilderState extends State<HyperLinkBottomSheetBuilder> {
  TextEditingController urlTextController = TextEditingController();
  TextEditingController customizedTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HyperlinkBloc>().add(SetInitalStateEvent(hyperlink: widget.hyperLink));
    if (widget.hyperLink != null) {
      urlTextController.text = widget.hyperLink!.url ?? "";
      customizedTextController.text = widget.hyperLink!.customText ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HyperlinkBloc, HyperlinkState>(
      listener: (BuildContext context, HyperlinkState state) {
        if (state is HyperlinkAddedState) {
          if (state.hyperLink != null) {
            widget.onHyperLinkAdded(state.hyperLink!);
          }
        }
        if (state is HyperlinkRemovedState) {
          widget.onHyperLinkRemoved();
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: widget.theme.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(children: <Widget>[
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontFamily: "SF Pro Text",
                      ),
                    ),
                    onPressed: () {
                      if (widget.hyperLink == null && state.hyperLink == null && urlTextController.text.isEmpty && customizedTextController.text.isEmpty) {
                        Navigator.of(context).pop();
                      } else if (urlTextController.text == (state.hyperLink?.url ?? "") && customizedTextController.text == (state.hyperLink?.customText ?? "")) {
                        Navigator.of(context).pop();
                      } else {
                        ConfirmationDialog().show(
                          context: context,
                          title: 'Unsaved changes',
                          detailText: 'are you sure you want to cancel? Your Changes won\'t be saved.',
                          leftButtonText: 'No',
                          rightButtonText: 'Yes',
                          confrimColor: Colors.blue,
                          onConfirm: () {
                            Navigator.of(context).pop();
                          },
                        );
                      }
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "SF Pro Text",
                        color: widget.theme.baseColor,
                      ),
                    ),
                  ),
                  (state is LoadingStateHyperLink)
                      ? const CircularProgressIndicator()
                      : Text(
                          'Add Link',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: widget.theme.baseColor,
                            fontFamily: "SF Pro Text",
                          ),
                        ),
                  DoneButton(
                    componentId: "hyperlink_bottom_sheet",
                    onPressed: (state is HyperlinkErrorState && (state.urlError != null || state.customizedError != null))
                        ? null
                        : () {
                            context.read<HyperlinkBloc>().add(
                                  VerifyAndSaveHyperLinkEvent(
                                    urlText: urlTextController.text,
                                    customizedText: customizedTextController.text,
                                  ),
                                );
                          },
                  ),
                ],
              ),
            ),
            Divider(
              color: widget.theme.baseColorShade3,
              thickness: 1,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "URL",
                    style: TextStyle(fontFamily: "SF Pro Text", fontSize: 17, color: widget.theme.baseColor, fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    "*",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: "SF Pro Text",
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AmityHyperlinkTextField(
                hint: "Https://example.com",
                textColor: widget.theme.baseColor,
                hintColor: widget.theme.baseColorShade3,
                borderColor: widget.theme.baseColorShade3,
                textEditingController: urlTextController,
                onChanged: (value) {
                  setState(() {
                    var isValid = isURL(value, requireTld: true, requireProtocol: false);
                    if (!isValid) {
                      BlocProvider.of<HyperlinkBloc>(context).add(OnURLErrorEvent(error: "Please enter a valid URL."));
                    } else {
                      BlocProvider.of<HyperlinkBloc>(context).add(OnURLErrorEvent(error: null));
                    }
                    urlTextController.text = value;
                  });
                },
                error: state is HyperlinkErrorState ? (state).urlError : null,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Customize link text",
                      style: TextStyle(fontFamily: "SF Pro Text", color: widget.theme.baseColor, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${customizedTextController.text.length}/30",
                      style: const TextStyle(
                        fontFamily: "SF Pro Text",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AmityHyperlinkTextField(
                hint: "Name your link",
                textColor: widget.theme.baseColor,
                hintColor: widget.theme.baseColorShade3,
                borderColor: widget.theme.baseColorShade3,
                textEditingController: customizedTextController,
                error: state is HyperlinkErrorState ? (state).customizedError : null,
                maxCharacters: 30,
                onChanged: (value) {
                  setState(() {
                    BlocProvider.of<HyperlinkBloc>(context).add(OnCustmizedErrorEvent(error: null));
                    customizedTextController.text = value;
                  });
                },
              ),
            ),
            state is HyperlinkErrorState
                ? Container()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: const Text(
                      "This text will show on the link instead of URL.",
                      style: TextStyle(
                        fontFamily: "SF Pro Text",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
            state.hyperLink != null
                ? Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ConfirmationDialog().show(
                            context: context,
                            title: 'Remove Link?',
                            detailText: 'This link will be removed from story.',
                            leftButtonText: 'Cancel',
                            rightButtonText: 'Remove',
                            onConfirm: () {
                              context.read<HyperlinkBloc>().add(OnRemoveHyperLink());
                              Navigator.of(context).pop();
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/Icons/ic_bin_red.svg",
                                package: 'amity_uikit_beta_service',
                                height: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Remove link",
                                style: TextStyle(
                                  fontFamily: "SF Pro Text",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: widget.theme.alertColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ]),
        );
      },
    );
  }
}

class DoneButton extends BaseElement {
  final VoidCallback? onPressed;
  DoneButton({super.key, required this.onPressed, String? pageId, String? componentId}) : super(pageId: pageId, componentId: componentId, elementId: "done_button");

  @override
  Widget buildElement(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: theme.primaryColor,
        textStyle: const TextStyle(fontSize: 15, fontFamily: "SF Pro Text"),
        disabledForegroundColor: theme.primaryColor.blend(ColorBlendingOption.shade2),
      ),
      onPressed: onPressed,
      child: const Text(
        'Done',
      ),
    );
  }
}
