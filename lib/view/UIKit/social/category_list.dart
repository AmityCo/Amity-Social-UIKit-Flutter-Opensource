import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodel/category_viewmodel.dart';
import '../../../viewmodel/configuration_viewmodel.dart';

// ignore: must_be_immutable
class CategoryList extends StatefulWidget {
  AmityCommunity? community;
  TextEditingController categoryTextController;

  CategoryList(
      {super.key, this.community, required this.categoryTextController});
  @override
  CategoryListState createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList> {
  // AmityCommunity community = AmityCommunity();

  // void buildCategoryIds() {
  //   for (var category
  //       in Provider.of<CategoryVM>(context, listen: false).getCategories()) {
  //     Provider.of<CategoryVM>(context, listen: false)
  //         .addCategoryId(category.categoryId!);
  //   }

  //   if (community.categoryIds != null) {
  //     Provider.of<CategoryVM>(context, listen: false)
  //         .setSelectedCategory(community.categoryIds![0]);
  //     // log("checking community category ids ${community.categoryIds}");
  //     // for (var id in community.categoryIds!) {
  //     //   if (categoryIds.contains(id)) {
  //     //     log("category id has a match ${id}");
  //     //     selectedCategoryIds.add(id);
  //     //   }
  //     // }
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // community = widget.community;
    Future.delayed(Duration.zero, () {
      if (widget.community != null) {
        Provider.of<CategoryVM>(context, listen: false)
            .setCommunity(widget.community!);
        Provider.of<CategoryVM>(context, listen: false).initCategoryList(
            ids: Provider.of<CategoryVM>(context, listen: false)
                .getCommunity()
                ?.categoryIds!);
      } else {
        Provider.of<CategoryVM>(context, listen: false).initCategoryList();
      }
    });
  }

  int getLength() {
    int length =
        Provider.of<CategoryVM>(context, listen: false).getCategories().length;
    return length;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        AppBar().preferredSize.height;

    final theme = Theme.of(context);
    return Consumer<CategoryVM>(builder: (context, vm, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Select category',
            style: Provider.of<AmityUIConfiguration>(context)
                .titleTextStyle
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  height: bHeight,
                  color: Colors.white,
                  child: FadedSlideAnimation(
                    beginOffset: const Offset(0, 0.3),
                    endOffset: const Offset(0, 0),
                    slideCurve: Curves.linearToEaseOut,
                    child: Column(
                      children: [
                        // Align(
                        //   alignment: Alignment.topLeft,
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       Navigator.of(context).pop();
                        //     },
                        //     child: const Icon(Icons.chevron_left,
                        //         color: Colors.black, size: 35),
                        //   ),
                        // ),
                        getLength() < 1
                            ? Center(
                                child: CircularProgressIndicator(
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .primaryColor,
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: getLength(),
                                  itemBuilder: (context, index) {
                                    return CategoryWidget(
                                      category: Provider.of<CategoryVM>(context,
                                              listen: false)
                                          .getCategories()[index],
                                      theme: theme,
                                      textController:
                                          widget.categoryTextController,
                                      community: Provider.of<CategoryVM>(
                                              context,
                                              listen: false)
                                          .getCommunity(),
                                      index: index,
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget(
      {Key? key,
      required this.textController,
      required this.category,
      required this.theme,
      required this.community,
      required this.index})
      : super(key: key);

  final AmityCommunityCategory category;
  final ThemeData theme;
  final AmityCommunity? community;
  final int index;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(0),
          onTap: () {
            Provider.of<CategoryVM>(context, listen: false).setSelectedCategory(
                Provider.of<CategoryVM>(context, listen: false)
                    .getCategoryIds()[index]);
            textController.text =
                Provider.of<CategoryVM>(context, listen: false)
                    .getSelectedCommunityName(
                        Provider.of<CategoryVM>(context, listen: false)
                            .getCategoryIds()[index]);
            Navigator.of(context).pop();
          },
          leading: FadeAnimation(
            child: (category.avatar?.fileUrl != null)
                ? CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(category.avatar!.fileUrl!),
                  )
                : Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        color: Color(0xFFD9E5FC), shape: BoxShape.circle),
                    child: const Icon(
                      Icons.category,
                      color: Colors.white,
                    ),
                  ),
          ),
          title: Text(category.name ?? "Category",
              style: Provider.of<AmityUIConfiguration>(context).hintTextStyle),
          trailing: Provider.of<CategoryVM>(context, listen: true)
                  .checkIfSelected(
                      Provider.of<CategoryVM>(context, listen: false)
                          .getCategories()[index]
                          .categoryId!)
              ? Icon(
                  Icons.check_rounded,
                  color:
                      Provider.of<AmityUIConfiguration>(context).primaryColor,
                )
              : null,
        ),
      ),
    );
  }
}
