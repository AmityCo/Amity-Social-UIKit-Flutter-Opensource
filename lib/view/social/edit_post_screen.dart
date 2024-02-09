// import 'package:amity_sdk/amity_sdk.dart';
// import 'package:amity_uikit_beta_service/viewmodel/community_feed_viewmodel.dart';
// import 'package:animation_wrappers/animations/fade_animation.dart';
// import 'package:animation_wrappers/animations/faded_slide_animation.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';

// import '../../components/custom_user_avatar.dart';
// import '../../components/video_player.dart';
// import '../../viewmodel/configuration_viewmodel.dart';
// import '../../viewmodel/edit_post_viewmodel.dart';
// import '../../viewmodel/user_feed_viewmodel.dart';
// import '../user/user_profile.dart';
// import 'community_feed.dart';

// // ignore: must_be_immutable
// class EditPostScreen extends StatefulWidget {
//   AmityPost? post; // Must extract children post from parent post

//   EditPostScreen({Key? key, this.post}) : super(key: key);
//   @override
//   EditPostScreenState createState() => EditPostScreenState();
// }

// class EditPostScreenState extends State<EditPostScreen> {
//   @override
//   void initState() {
//     Provider.of<EditPostVM>(context, listen: false)
//         .initForEditPost(widget.post!);

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     // final mediaQuery = MediaQuery.of(context);
//     final myAppbar = AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       title: Text("Edit",
//           style: theme.textTheme.titleLarge!
//               .copyWith(fontWeight: FontWeight.w500)),
//       leading: IconButton(
//         icon: Icon(
//           Icons.chevron_left,
//           color: theme.indicatorColor,
//         ),
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//       ),
//     );
//     // final bheight = mediaQuery.size.height -
//     //     mediaQuery.padding.top -
//     //     myAppbar.preferredSize.height;
//     return Consumer<EditPostVM>(builder: (context, vm, m) {
//       return Scaffold(
//         appBar: myAppbar,
//         body: SafeArea(
//           child: FadedSlideAnimation(
//             beginOffset: const Offset(0, 0.3),
//             endOffset: const Offset(0, 0),
//             slideCurve: Curves.linearToEaseOut,
//             child: Container(
//               // height: bheight,
//               color: Colors.white,
//               padding: const EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   ListTile(
//                     contentPadding: const EdgeInsets.all(0),
//                     leading: FadeAnimation(
//                         child: GestureDetector(
//                             onTap: () {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                   builder: (context) => ChangeNotifierProvider(
//                                       create: (context) => UserFeedVM(),
//                                       child: UserProfileScreen(
//                                         amityUser: widget.post!.postedUser!,
//                                         amityUserId:
//                                             widget.post!.postedUser!.userId!,
//                                       ))));
//                             },
//                             child: getAvatarImage(
//                                 widget.post!.postedUser?.avatarUrl))),
//                     title: Wrap(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) => ChangeNotifierProvider(
//                                     create: (context) => UserFeedVM(),
//                                     child: UserProfileScreen(
//                                       amityUser: widget.post!.postedUser!,
//                                       amityUserId:
//                                           widget.post!.postedUser!.userId!,
//                                     ))));
//                           },
//                           child: Text(
//                             widget.post!.postedUser?.displayName ??
//                                 "Display name",
//                             style: theme.textTheme.bodyLarge!
//                                 .copyWith(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         widget.post!.targetType == AmityPostTargetType.COMMUNITY
//                             ? const Icon(
//                                 Icons.arrow_right_rounded,
//                                 color: Colors.black,
//                               )
//                             : Container(),
//                         widget.post!.targetType == AmityPostTargetType.COMMUNITY
//                             ? GestureDetector(
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                       MaterialPageRoute(builder: (context) {
//                                     var changeNotifierProvider =
//                                         ChangeNotifierProvider(
//                                       create: (context) => CommuFeedVM(),
//                                       child: CommunityScreen(
//                                         isFromFeed: true,
//                                         community: (widget.post!.target
//                                                 as CommunityTarget)
//                                             .targetCommunity!,
//                                       ),
//                                     );
//                                     return changeNotifierProvider;
//                                   }));
//                                 },
//                                 child: Text(
//                                   (widget.post!.target as CommunityTarget)
//                                           .targetCommunity!
//                                           .displayName ??
//                                       "Community name",
//                                   style: theme.textTheme.bodyLarge!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                               )
//                             : Container()
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           TextField(
//                             controller: vm.textEditingController,
//                             scrollPhysics: const NeverScrollableScrollPhysics(),
//                             maxLines: null,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               hintText: "Write something to Post",
//                             ),
//                             // style: t/1heme.textTheme.bodyText1.copyWith(color: Colors.grey),
//                           ),
//                           (vm.videoUrl != null)
//                               ? MyVideoPlayer2(
//                                   post: widget.post!,
//                                   url: vm.videoUrl!,
//                                   isInFeed: true,
//                                   isEnableVideoTools: false,
//                                 )
//                               : Container(),
//                           GridView.builder(
//                             physics: const NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             gridDelegate:
//                                 const SliverGridDelegateWithMaxCrossAxisExtent(
//                                     maxCrossAxisExtent: 150,
//                                     childAspectRatio: 1,
//                                     crossAxisSpacing: 10,
//                                     mainAxisSpacing: 10),
//                             itemCount: vm.imageUrlList.length,
//                             itemBuilder: (_, i) {
//                               return FadeAnimation(
//                                 child: Stack(
//                                   fit: StackFit.expand,
//                                   children: [
//                                     Image.network(
//                                       vm.imageUrlList[i],
//                                       fit: BoxFit.cover,
//                                     ),
//                                     Align(
//                                         alignment: Alignment.topRight,
//                                         child: GestureDetector(
//                                             onTap: () {
//                                               vm.deleteImageAt(index: i);
//                                             },
//                                             child: Icon(
//                                               Icons.cancel,
//                                               color: Colors.grey.shade100,
//                                             ))),
//                                   ],
//                                 ),
//                               );
//                             },
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () async {
//                           await vm.addVideo();
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.all(10),
//                           margin: const EdgeInsets.fromLTRB(5, 0, 10, 5),
//                           child: FaIcon(
//                             FontAwesomeIcons.video,
//                             color: vm.isNotSelectedImageYet()
//                                 ? Provider.of<AmityUIConfiguration>(context)
//                                     .primaryColor
//                                 : theme.disabledColor,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           await vm.addFiles();
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.all(10),
//                           margin: const EdgeInsets.fromLTRB(5, 0, 10, 5),
//                           child: Icon(
//                             Icons.photo,
//                             color: vm.isNotSelectVideoYet()
//                                 ? Provider.of<AmityUIConfiguration>(context)
//                                     .primaryColor
//                                 : theme.disabledColor,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           await vm.addFileFromCamera();
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.all(10),
//                           margin: const EdgeInsets.fromLTRB(5, 0, 10, 5),
//                           child: Icon(
//                             Icons.camera_alt,
//                             color: vm.isNotSelectVideoYet()
//                                 ? Provider.of<AmityUIConfiguration>(context)
//                                     .primaryColor
//                                 : theme.disabledColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       //edit post
//                       //TODO: waiting for update

//                       Navigator.of(context).pop();
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(top: 15),
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
//                       decoration: BoxDecoration(
//                         color: Provider.of<AmityUIConfiguration>(context)
//                             .primaryColor,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         "Edit",
//                         style: theme.textTheme.labelLarge,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
