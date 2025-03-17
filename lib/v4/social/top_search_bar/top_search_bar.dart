import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityTopSearchBarComponent extends NewBaseComponent {
  final void Function(String)? onTextChanged;
  TextEditingController textcontroller;
  String hintText;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textcontroller,
              decoration: InputDecoration(
                prefixIcon: Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.only(
                      top: 12, bottom: 12, right: 8, left: 12),
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_navigation_search.svg',
                    package: 'amity_uikit_beta_service',
                    colorFilter: ColorFilter.mode(
                      theme.baseColorShade2,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: theme.baseColorShade2,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                    "Cancel",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              )
        ],
      ),
    );
  }
}
