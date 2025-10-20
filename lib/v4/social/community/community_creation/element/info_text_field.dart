import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/bloc/info_text_field_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class InfoTextField extends BaseElement {
  String title;
  bool isOptional = false;
  String initialText = '';
  String hint;
  int maxLength;
  bool expandable = false;
  bool isDisabled;
  Function(String)? onChanged;

  InfoTextField(
      {super.key,
      this.title = '',
      this.isOptional = false,
      this.initialText = '',
      this.hint = '',
      this.maxLength = 30,
      this.expandable = false,
      this.isDisabled = false,
      this.onChanged})
      : super(elementId: 'info_text_field');

  @override
  Widget buildElement(BuildContext context) {
    return BlocProvider(
      key: key,
      create: (context) => InfoTextFieldBloc(text: initialText),
      child: BlocBuilder<InfoTextFieldBloc, InfoTextFieldState>(
        builder: (context, textFieldState) {
          return _getWidget(context, textFieldState);
        },
      ),
    );
  }

  Widget _getWidget(BuildContext context, InfoTextFieldState state) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(
              title,
              style: AmityTextStyle.titleBold(theme.baseColor),
            ),
            if (isOptional)
              Text(
                ' (${context.l10n.general_optional})',
                style: AmityTextStyle.caption(theme.baseColorShade3),
              ),
          ]),
          Text(
            '${state.text.length}/$maxLength',
            style: AmityTextStyle.body(theme.baseColorShade1),
          ),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: state.controller,
          maxLines: expandable ? null : 1,
          onChanged: (value) {
            onChanged?.call(value);
            context.read<InfoTextFieldBloc>().add(InfoTextFieldEvent(value));
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
          ],
          style: AmityTextStyle.body(
              isDisabled ? theme.baseColorShade2 : theme.baseColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: theme.baseColorShade3,
                fontSize: 15,
                fontWeight: FontWeight.w400),
            labelStyle: AmityTextStyle.body(theme.baseColor),
            border: InputBorder.none,
          ),
          readOnly: isDisabled,
        ),
        _getDividerWidget()
      ],
    );
  }

  Widget _getDividerWidget() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Divider(
          color: theme.baseColorShade4,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          height: 1,
        ));
  }
}
