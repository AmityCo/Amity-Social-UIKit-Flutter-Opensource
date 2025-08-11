import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_event.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollableTabs extends NewBaseComponent {
  ScrollableTabs({Key? key, required String pageId})
      : super(key: key, pageId: pageId, componentId: '');

  final bool showExploreTab =
      AmityUIKit4Manager.freedomBehavior.socialHomePageBehavior.showExploreTab;
  final bool showMyCommunitiesTab = AmityUIKit4Manager
      .freedomBehavior.socialHomePageBehavior.showMyCommunitiesTab;

  @override
  Widget buildComponent(BuildContext context) {
    return BlocBuilder<SocialHomeBloc, SocialHomeState>(
      builder: (context, state) {
        final selectedIndex = state is TabState ? state.selectedIndex : 0;

        return Container(
          alignment: AlignmentDirectional.centerStart,
          color: theme.backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(
                    context, context.l10n.community_title, 0, selectedIndex),
                if (showExploreTab)
                  _buildTabButton(
                      context, context.l10n.tab_explore, 1, selectedIndex),
                if (showMyCommunitiesTab)
                  _buildTabButton(context, context.l10n.tab_my_communities, 2,
                      selectedIndex),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(
      BuildContext context, String text, int index, int selectedIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
        onPressed: () =>
            context.read<SocialHomeBloc>().add(TabSelectedEvent(index)),
        style: ElevatedButton.styleFrom(
          foregroundColor: selectedIndex == index
              ? theme.primaryColor
              : theme.baseColorShade1,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        child: Column(
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              height: 2,
              thickness: 2,
              color: selectedIndex == index
                  ? theme.primaryColor
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
    //   child: ElevatedButton(
    //     onPressed: () =>
    //         context.read<SocialHomeBloc>().add(TabSelectedEvent(index)),
    //     style: ElevatedButton.styleFrom(
    //         foregroundColor:
    //             selectedIndex == index ? Colors.white : theme.baseColorShade1,
    //         backgroundColor: selectedIndex == index
    //             ? theme.primaryColor
    //             : Colors.transparent,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(24),
    //         ),
    //         side: BorderSide(
    //             color: selectedIndex == index
    //                 ? theme.primaryColor
    //                 : theme.baseColorShade4,
    //             width: 1.0),
    //         elevation: 0,
    //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
    //     child: Text(
    //       text,
    //       style: TextStyle(
    //         fontSize: 17,
    //         fontWeight:
    //             selectedIndex == index ? FontWeight.bold : FontWeight.normal,
    //       ),
    //     ),
    //   ),
    // );
  }
}
