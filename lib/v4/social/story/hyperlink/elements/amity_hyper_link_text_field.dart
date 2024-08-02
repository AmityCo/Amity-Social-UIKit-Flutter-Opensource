import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmityHyperlinkTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hint;
  final int maxCharacters;
  final String? error;
  final Function(String) onChanged;

  const AmityHyperlinkTextField({
    super.key,
    required this.hint,
    required this.textEditingController,
    required this.onChanged,
    this.maxCharacters = -1,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      onChanged: (value) {
        if (maxCharacters == -1) {
          onChanged(value);
        } else if (textEditingController.text.length <= maxCharacters) {
          onChanged(value);
        }
      },
      maxLength: maxCharacters!=-1?maxCharacters:null,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hint,
        errorText: error,
        counterText: "",
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color:
                Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color:
                Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color:
                Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
            width: 1,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        hintStyle:
            Provider.of<AmityUIConfiguration>(context).hintTextStyle.copyWith(
                  color: Provider.of<AmityUIConfiguration>(context)
                      .appColors
                      .primaryShade3,
                ),
      ),
    );
  }
}
