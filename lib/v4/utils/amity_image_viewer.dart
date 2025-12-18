import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AmityImageViewer extends StatefulWidget {
  final String imageUrl;
  final bool showDeleteButton;
  final bool showSaveButton;
  final Function()? onDelete;
  final Function()? onSave;

  const AmityImageViewer({
    Key? key,
    required this.imageUrl,
    this.showDeleteButton = false,
    this.showSaveButton = false,
    this.onDelete,
    this.onSave,
  }) : super(key: key);

  @override
  _AmityImageViewerState createState() => _AmityImageViewerState();
}

class _AmityImageViewerState extends State<AmityImageViewer> {
  late bool _showDeleteButton;
  late bool _showSaveButton;
  late Function()? _onDelete;
  late Function()? _onSave;

  @override
  void initState() {
    super.initState();
    _showDeleteButton = widget.showDeleteButton;
    _showSaveButton = widget.showSaveButton;
    _onDelete = widget.onDelete ?? () {};
    _onSave = widget.onSave ?? () {};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Dismissible(
          key: const Key('dismissible'),
          direction: DismissDirection.down,
          onDismissed: (_) => Navigator.of(context).pop(),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Image.network(
                      widget.imageUrl,
                      errorBuilder: (context, error, stackTrace) {
                        context.read<AmityToastBloc>().add(AmityToastShort(
                          message: context.l10n.image_load_error,
                          icon: AmityToastIcon.warning,
                          bottomPadding: AmityChatPage.toastBottomPadding
                        ));
                        return Image.asset(
                          'assets/Icons/amity_ic_image_error.png',
                          package: 'amity_uikit_beta_service',
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_showDeleteButton) ...[
                            GestureDetector(
                              onTap: () {
                                if (_onDelete != null) _onDelete!();
                              },
                              child: Container(
                                child: SvgPicture.asset(
                                  'assets/Icons/amity_ic_deleted_message.svg',
                                  package: 'amity_uikit_beta_service',
                                  width: 28,
                                  height: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(
                              width: 28,
                              height: 24,
                            ),
                          ],
                          if (_showSaveButton)
                            GestureDetector(
                              onTap: () {
                                if (_onSave != null) _onSave!();
                              },
                              child: Container(
                                child: SvgPicture.asset(
                                  'assets/Icons/amity_ic_save_image_white.svg',
                                  package: 'amity_uikit_beta_service',
                                  width: 28,
                                  height: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(left: 16),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/Icons/amity_ic_close_viewer.svg',
                    package: 'amity_uikit_beta_service',
                    width: 32,
                    height: 32,
                  ),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
