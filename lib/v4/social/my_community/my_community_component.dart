import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/bloc/my_community_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/shared/community_list.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/view/social/community_feedV2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

part 'my_community_elements.dart';
part 'my_community_ui_ids.dart';

class AmityMyCommunitiesComponent extends NewBaseComponent {
  ScrollController scrollController = ScrollController();
  AmityMyCommunitiesComponent({Key? key, required String pageId})
      : super(
            key: key,
            pageId: pageId,
            componentId: AmityComponent.myCommunities.stringValue);

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => MyCommunityBloc(),
      child: Builder(builder: (context) {
        context.read<MyCommunityBloc>().add(MyCommunityEventInitial());

        return BlocBuilder<MyCommunityBloc, MyCommunityState>(
          builder: (context, state) {
            if (state is MyCommunityLoading) {
              return communitySkeletonList(theme, configProvider);
            } else if (state is MyCommunityLoaded) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      color: theme.baseColorShade4,
                      height: 8,
                    ),
                    Expanded(
                      child: communityList(
                          context, scrollController, state.list, theme, () {
                        context
                            .read<MyCommunityBloc>()
                            .add(MyCommunityEventLoadMore());
                      }),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        );
      }),
    );
  }
}
