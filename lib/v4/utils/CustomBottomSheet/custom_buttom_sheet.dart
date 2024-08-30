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

  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  CustomBottomSheet({
    required this.theme,
    required this.collapsedContent,
    required this.expandedContent,
    required this.minSize,
    required this.maxSize,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomBottomSheetBloc(maxSize, minSize),
      child: BlocBuilder<CustomBottomSheetBloc, CustomBottomSheetState>(
        builder: (context, state) {
          final triggeredHeight = ((maxSize - minSize) * 0.5) + minSize;
          return DraggableScrollableSheet(
            initialChildSize: maxSize,
            minChildSize: minSize,
            maxChildSize: maxSize,
            controller: sheetController,
            snap: true,
            snapSizes: [minSize, maxSize],
            builder: (BuildContext context, ScrollController scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
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
                          Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 8, top: 12),
                            decoration: BoxDecoration(
                              color: theme.baseColorShade3,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          if (state is CustomBottomSheetExpanded)
                            expandedContent
                          else if (state is CustomBottomSheetCollapsed)
                            collapsedContent,
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
