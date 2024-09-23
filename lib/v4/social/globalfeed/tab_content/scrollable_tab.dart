import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_event.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollableTabs extends NewBaseComponent {
  ScrollableTabs({Key? key, required String pageId})
      : super(key: key, pageId: pageId, componentId: '');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocBuilder<SocialHomeBloc, SocialHomeState>(
      builder: (context, state) {
        final selectedIndex = state is TabState ? state.selectedIndex : 0;

        return Container(
          color: theme.backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(context, 'Newsfeed', 0, selectedIndex),
                _buildTabButton(context, 'Explore', 1, selectedIndex),
                _buildTabButton(context, 'My Communities', 2, selectedIndex),
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () =>
            context.read<SocialHomeBloc>().add(TabSelectedEvent(index)),
        style: ElevatedButton.styleFrom(
            foregroundColor:
                selectedIndex == index ? Colors.white : theme.baseColorShade1,
            backgroundColor: selectedIndex == index
                ? theme.primaryColor
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            side: BorderSide(
                color: selectedIndex == index
                    ? theme.primaryColor
                    : theme.baseColorShade4,
                width: 1.0),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            fontWeight:
                selectedIndex == index ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
