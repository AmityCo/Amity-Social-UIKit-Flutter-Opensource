import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class CommunityCategory extends Equatable {
  late String? id;
  late String? name;
  late AmityImage? icon;
  AmityCommunityCategory? category;

  CommunityCategory({required this.category}) {
    id = category?.categoryId;
    name = category?.name;
    icon = category?.avatar;
  }

  @override
  List<Object?> get props => [category];
}

// ignore: must_be_immutable
class CategoryGridView extends StatefulWidget {
  List<CommunityCategory> items;
  AmityThemeColor theme;
  Function(CommunityCategory)? onTap;

  CategoryGridView({
    super.key,
    required this.items,
    required this.theme,
    this.onTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoryGridViewState createState() => _CategoryGridViewState();
}

class _CategoryGridViewState extends State<CategoryGridView> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var item in widget.items)
          GestureDetector(
            onTap: () {
              widget.onTap?.call(item);
              setState(() {}); // Update the state when an item is tapped
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              decoration: BoxDecoration(
                border:
                    Border.all(color: widget.theme.baseColorShade4, width: 1.5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  item.icon != null
                      ? Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.theme.baseColorShade4,
                            image: item.icon != null
                                ? DecorationImage(
                                    image: NetworkImage(item.icon!
                                        .getUrl(AmityImageSize.SMALL)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        )
                      : _placeholderAvatar(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.theme.baseColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    'assets/Icons/amity_ic_close_button.svg',
                    width: 22,
                    height: 22,
                    color: widget.theme.baseColorShade1,
                    package: 'amity_uikit_beta_service',
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholderAvatar() {
    return SvgPicture.asset(
      'assets/Icons/amity_ic_default_category.svg',
      width: 28,
      height: 28,
      package: 'amity_uikit_beta_service',
      fit: BoxFit.contain,
    );
  }
}
