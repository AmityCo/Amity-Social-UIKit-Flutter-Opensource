import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityTopSearchBarComponent extends NewBaseComponent {
  final void Function(String)? onTextChanged;
  final TextEditingController textcontroller;
  final String hintText;
  final bool showCancelButton;

  AmityTopSearchBarComponent({
    Key? key,
    String? pageId,
    required this.textcontroller,
    this.hintText = '',
    this.onTextChanged,
    this.showCancelButton = true,
  }) : super(key: key, pageId: pageId, componentId: 'top_search_bar');

  @override
  Widget buildComponent(BuildContext context) {
    const borderRadius = 8.0;
    
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: textcontroller,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
            child: TextField(
              controller: textcontroller,
              style: AmityTextStyle.body(theme.baseColor),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_navigation_search.svg',
                    package: 'amity_uikit_beta_service',
                    fit: BoxFit.contain,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      theme.baseColorShade2,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  maxWidth: 40,
                  minHeight: 0,
                ),
                hintText: hintText,
                hintStyle: AmityTextStyle.body(theme.baseColorShade2),
                filled: true,
                contentPadding: const EdgeInsets.only(top: 4, bottom: 4, right: 12),
                fillColor: theme.baseColorShade4,
                focusColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                suffixIconColor: theme.baseColorShade3,
                suffixIcon: textcontroller.text.isNotEmpty
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.baseColorShade3,
                              shape: BoxShape.circle,
                            ),
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/Icons/amity_ic_close_button.svg',
                              package: 'amity_uikit_beta_service',
                              colorFilter: ColorFilter.mode(
                                theme.baseColorShade4,
                                BlendMode.srcIn,
                              ),
                              width: 17,
                              height: 17,
                            ),
                            onPressed: () {
                              textcontroller.clear();
                              onTextChanged?.call('');
                            },
                          )
                        ],
                      )
                    : null,
              ),
              onChanged: (value) {
                onTextChanged?.call(value);
              },
            ),
          ),
          if (showCancelButton)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    context.l10n.general_cancel,
                    style: AmityTextStyle.body(theme.primaryColor),
                  ),
                ),
              )
        ],
      ),
    );
      },
    );
  }
}
