import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/CustomBottomSheet/bloc/custom_bottom_sheet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomBottomSheet extends StatelessWidget {
  final AmityThemeColor theme;
  final Widget collapsedContent;
  final Widget expandedContent;
  final double minSize;
  final double maxSize;
  final bool isKeyboardVisible;

  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  CustomBottomSheet({
    Key? key,
    required this.theme,
    required this.collapsedContent,
    required this.expandedContent,
    required this.minSize,
    required this.maxSize,
    required this.isKeyboardVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocProvider(
      create: (context) => CustomBottomSheetBloc(maxSize, minSize),
      child: BlocBuilder<CustomBottomSheetBloc, CustomBottomSheetState>(
        builder: (context, state) {
          final triggeredHeight = ((maxSize - minSize) * 0.5) + minSize;
          
          // Determine currentSize based on keyboard and state
          final currentSize = isKeyboardVisible 
              ? minSize 
              : (state is CustomBottomSheetExpanded ? maxSize : minSize);
          
          if (isKeyboardVisible && sheetController.isAttached) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (sheetController.size > minSize) {
                sheetController.animateTo(
                  minSize,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });
          }
          
          return AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: DraggableScrollableSheet(
              key: ValueKey('sheet_keyboard_$isKeyboardVisible'),
              initialChildSize: currentSize,
              minChildSize: minSize - 0.005 ,
              maxChildSize: maxSize,
              controller: sheetController,
              snap: true,
              snapSizes: [minSize, maxSize],
              builder: (BuildContext context, ScrollController scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {

                  if (notification.extent <= minSize - 0.005) {
                    if (isKeyboardVisible) {
                      FocusScope.of(context).unfocus();
                    }
                    
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (sheetController.isAttached) {
                        sheetController.animateTo(
                          minSize,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                  
                  if (state is CustomBottomSheetCollapsed &&
                      notification.extent > triggeredHeight) {
                    context.read<CustomBottomSheetBloc>().add(
                          CustomBottomSheetExtentChanged(extent: notification.extent),
                        );
                  } else if (state is CustomBottomSheetExpanded &&
                      notification.extent < triggeredHeight) {
                    context.read<CustomBottomSheetBloc>().add(
                          CustomBottomSheetExtentChanged(extent: notification.extent),
                        );
                  }
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 12),
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: theme.baseColorShade3,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          if (isKeyboardVisible || state is CustomBottomSheetCollapsed)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: IntrinsicHeight(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: collapsedContent,
                                ),
                              ),
                            )
                          else if (state is CustomBottomSheetExpanded)
                            expandedContent
                          else
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: IntrinsicHeight(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: collapsedContent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
              },
            ),
          );
        },
      ),
    );
  }
}
