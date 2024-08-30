import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
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

class HyperLinkBottomSheetContent extends StatefulWidget {
  final HyperLink? hyperLink;
  final Function(HyperLink) onHyperLinkAdded;
  final Function() onHyperLinkRemoved;
  const HyperLinkBottomSheetContent({super.key, this.hyperLink, required this.onHyperLinkAdded, required this.onHyperLinkRemoved});

  @override
  State<HyperLinkBottomSheetContent> createState() => _HyperLinkBottomSheetContentState();
}

class _HyperLinkBottomSheetContentState extends State<HyperLinkBottomSheetContent> {
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
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
                    style: TextButton.styleFrom(foregroundColor: Colors.black, textStyle: const TextStyle(fontSize: 15, fontFamily: "SF Pro Text")),
                    onPressed: () {

                      // if(urlTextController.text == widget.hyperLink?.url && customizedTextController.text == widget.hyperLink?.customText){
                      //   Navigator.of(context).pop();
                      //   return;
                      // }

                      // if ( state.hyperLink != null ) {
                      //   Navigator.of(context).pop();
                      // }else 
                      if(widget.hyperLink==null && state.hyperLink==null && urlTextController.text.isEmpty && customizedTextController.text.isEmpty){
                        Navigator.of(context).pop();
                      }else if(urlTextController.text == (state.hyperLink?.url??"") && customizedTextController.text == (state.hyperLink?.customText??"")){
                        Navigator.of(context).pop();
                      } 
                      else {
                        ConfirmationDialog().show(
                          context: context,
                          title: 'Unsaved changes',
                          detailText: 'are you sure you want to cancel? Your Changes won\'t be saved.',
                          leftButtonText: 'No',
                          rightButtonText: 'Yes',
                          confrimColor: Colors.blue,
                          onConfirm: () {
                             Navigator.of(context).pop();
                            // context.read<HyperlinkBloc>().add(OnRemoveHyperLink());
                            // Navigator.of(context).pop();
                          },
                        );
                      }
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  (state is LoadingStateHyperLink)
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Add Link',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, fontFamily: "SF Pro Text"),
                        ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.blue, textStyle: const TextStyle(fontSize: 15, fontFamily: "SF Pro Text") , disabledForegroundColor:const Color(0xffA0BDF8)),
                    onPressed: (state is HyperlinkErrorState && ( state.urlError!=null || state.customizedError!=null ))? null : () {
                      context.read<HyperlinkBloc>().add(VerifyAndSaveHyperLinkEvent(
                            urlText: urlTextController.text,
                            customizedText: customizedTextController.text,
                          ));
                    },
                    child: const Text(
                      'Done',
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "URL",
                    style: TextStyle(fontFamily: "SF Pro Text", fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Text(
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
                textEditingController: urlTextController,
                onChanged: (value) {
                  var urlPattern = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                  setState(() {
                    var isValid = isURL(value, requireTld: true , requireProtocol: false);
                    if (!isValid) {
                      BlocProvider.of<HyperlinkBloc>(context).add(OnURLErrorEvent(error: "Please enter a valid URL."));
                    }else{
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
              child: Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Customize link text",
                      style: TextStyle(fontFamily: "SF Pro Text", fontSize: 17, fontWeight: FontWeight.w600),
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
                              const Text(
                                "Remove link",
                                style: TextStyle(
                                  fontFamily: "SF Pro Text",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
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
