// import 'dart:io';

// import 'package:amity_sdk/amity_sdk.dart';
// import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
// import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
// import 'package:amity_uikit_beta_service/components/video_player.dart';
// import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/posts/post_cpmponent.dart';
// import 'package:amity_uikit_beta_service/viewmodel/amity_viewmodel.dart';
// import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
// import 'package:amity_uikit_beta_service/viewmodel/create_post_viewmodel.dart';
// import 'package:amity_uikit_beta_service/viewmodel/media_viewmodel.dart';
// import 'package:animation_wrappers/animations/fade_animation.dart';
// import 'package:animation_wrappers/animations/faded_slide_animation.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

// class AmityCreatePostScreen extends StatefulWidget {
//   final AmityCommunity? community;

//   const AmityCreatePostScreen({
//     super.key,
//     this.community,
//   });

//   @override
//   State<AmityCreatePostScreen> createState() => _AmityCreatePostScreenState();
// }

// class _AmityCreatePostScreenState extends State<AmityCreatePostScreen> {
//   bool hasContent = true;

//   @override
//   void initState() {
//     Provider.of<CreatePostVM>(context, listen: false).inits();
//     Provider.of<MediaPickerVM>(context, listen: false).clearFiles();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Consumer2<CreatePostVM, MediaPickerVM>(
//         builder: (context, vm, vm2, _) {
//       return WillPopScope(
//         onWillPop: () async {
//           if (hasContent) {
//             _showDiscardDialog();
//             return false;
//           }
//           return true;
//         },
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             title: Text(
//               widget.community != null
//                   ? widget.community?.displayName ?? "Community"
//                   : "My Feed",
//               style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
//             ),
//             leading: IconButton(
//               icon: Icon(
//                 Icons.chevron_left,
//                 color: Colors.black,
//               ),
//               onPressed: () {
//                 if (hasContent) {
//                   ConfirmationDialog().show(
//                     context: context,
//                     title: 'Discard Post?',
//                     detailText: 'Do you want to discard your post?',
//                     leftButtonText: 'Cancel',
//                     rightButtonText: 'Discard',
//                     onConfirm: () {
//                       Navigator.of(context).pop();
//                     },
//                   );
//                 } else {
//                   Navigator.of(context).pop();
//                 }
//               },
//             ),
//             actions: [
//               TextButton(
//                 onPressed: hasContent
//                     ? () async {
//                         if (vm.areAllFilesComplete) {
//                           if (widget.community == null) {
//                             //creat post in user Timeline
//                             await vm.createPost(context,
//                                 callback: (isSuccess, error) {
//                               if (isSuccess) {
//                                 Navigator.of(context).pop();
//                                 Navigator.of(context).pop();
//                               } else {}
//                             });
//                           } else {
//                             //create post in Community
//                             await vm.createPost(context,
//                                 communityId: widget.community?.communityId ??
//                                     "null", callback: (isSuccess, error) {
//                               if (isSuccess) {
//                                 Navigator.of(context).pop();
//                                 Navigator.of(context).pop();
//                               }
//                             });
//                           }
//                         }

//                         // ignore: use_build_context_synchronously
//                       }
//                     : null,
//                 child: Text("Post",
//                     style: TextStyle(
//                         color: vm.areAllFilesComplete
//                             ? Provider.of<AmityUIConfiguration>(context)
//                                 .primaryColor
//                             : Colors.grey)),
//               ),
//             ],
//           ),
//           body: SafeArea(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           TextField(
//                             controller: vm.textEditingController,
//                             scrollPhysics: const NeverScrollableScrollPhysics(),
//                             maxLines: null,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               hintText: "Write something to post",
//                             ),
//                             // style: t/1heme.textTheme.bodyText1.copyWith(color: Colors.grey),
//                           ),
//                           Consumer<MediaPickerVM>(
//                             builder: (context, mediaPickerVM, _) =>
//                                 PostMedia(files: mediaPickerVM.selectedFiles),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Divider(),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16, bottom: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _iconButton(
//                         Icons.camera_alt_outlined,
//                         isEnable: vm2.isNotSelectVideoYet() &&
//                             vm2.isNotSelectedFileYet(),
//                         label: "Photo",
//                         // debugingText:
//                         //     "${vm2.isNotSelectVideoYet()}&& ${vm2.isNotSelectedFileYet()}",
//                         onTap: () {
//                           _handleCameraTap();
//                         },
//                       ),
//                       _iconButton(
//                         Icons.image_outlined,
//                         label: "Image",
//                         isEnable: vm2.isNotSelectVideoYet() &&
//                             vm2.isNotSelectedFileYet(),
//                         onTap: () async {
//                           _handleImageTap();
//                         },
//                       ),
//                       _iconButton(
//                         Icons.play_circle_outline,
//                         label: "Video",
//                         isEnable: vm2.isNotSelectedImageYet() &&
//                             vm2.isNotSelectedFileYet(),
//                         onTap: () async {
//                           _handleVideoTap();
//                         },
//                       ),
//                       _iconButton(
//                         Icons.attach_file_outlined,
//                         label: "File",
//                         isEnable: vm.isNotSelectedImageYet() &&
//                             vm.isNotSelectVideoYet(),
//                         onTap: () async {
//                           _handleFileTap();
//                         },
//                       ),
//                       _iconButton(
//                         Icons.more_horiz,
//                         isEnable: true,
//                         label: "More",
//                         onTap: () {
//                           // TODO: Implement more options logic
//                           _showMoreOptions(context);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   Widget _iconButton(IconData icon,
//       {required String label,
//       required VoidCallback onTap,
//       required bool isEnable,
//       String? debugingText}) {
//     return Column(
//       children: [
//         debugingText == null ? SizedBox() : Text(debugingText),
//         CircleAvatar(
//           radius: 16,
//           backgroundColor: Colors.grey[200],
//           child: IconButton(
//             icon: Icon(
//               icon,
//               size: 18,
//               color: isEnable ? Colors.black : Colors.grey,
//             ),
//             onPressed: () {
//               if (isEnable) {
//                 onTap();
//               }
//             },
//           ),
//         ),
//         // SizedBox(height: 4),
//         // Text(label),
//       ],
//     );
//   }

//   void _showMoreOptions(BuildContext context) {
//     showModalBottomSheet(
//       backgroundColor: Colors.transparent,
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(15.0),
//               topRight: Radius.circular(15.0),
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: EdgeInsets.only(top: 16.0), // Space at the top
//               child: Wrap(
//                 children: <Widget>[
//                   ListTile(
//                     leading: _iconButton(Icons.camera_alt_outlined,
//                         isEnable: true, label: "Camera", onTap: () {}),
//                     title: Text('Camera'),
//                     onTap: () {
//                       _handleCameraTap();
//                       Navigator.pop(context);
//                     },
//                   ),
//                   ListTile(
//                     leading: _iconButton(Icons.image_outlined,
//                         isEnable: true, label: "Photo", onTap: () {}),
//                     title: Text('Photo'),
//                     onTap: () {
//                       _handleImageTap();
//                       Navigator.pop(context);
//                     },
//                   ),
//                   ListTile(
//                     leading: _iconButton(Icons.attach_file_rounded,
//                         isEnable: true, label: "Attachment", onTap: () {}),
//                     title: Text('Attachment'),
//                     onTap: () {
//                       _handleFileTap();
//                       Navigator.pop(context);
//                     },
//                   ),
//                   ListTile(
//                     leading: _iconButton(Icons.play_circle_outline_outlined,
//                         isEnable: true, label: "Video", onTap: () {}),
//                     title: Text('Video'),
//                     onTap: () {
//                       _handleVideoTap();
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showDiscardDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Discard Post?'),
//         content: Text('Do you want to discard your post?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(true);
//               Navigator.of(context).pop();
//             },
//             child: Text('Discard'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _handleCameraTap() async {
//     print("pick image");
//     var mediaPickerVM = Provider.of<MediaPickerVM>(context, listen: false);
//     await mediaPickerVM.pickImagesfromCamera();
//     for (var image in mediaPickerVM.selectedFiles) {
//       if (Provider.of<CreatePostVM>(context, listen: false)
//               .getProgress(image.path) ==
//           null) {
//         print("image:${image.path}");
//         var file = File(image.path);
//         Provider.of<CreatePostVM>(context, listen: false)
//             .uploadFile(file, onSuccess: () {}, onError: (String) {});
//       }
//     }
//   }

//   Future<void> _handleImageTap() async {
//     print("pick image");
//     var mediaPickerVM = Provider.of<MediaPickerVM>(context, listen: false);
//     await mediaPickerVM.pickMultipleImages();
//     for (var image in mediaPickerVM.selectedFiles) {
//       if (Provider.of<CreatePostVM>(context, listen: false)
//               .getProgress(image.path) ==
//           null) {
//         print("image:${image.path}");
//         var file = File(image.path);
//         Provider.of<CreatePostVM>(context, listen: false)
//             .uploadFile(file, onSuccess: () {}, onError: (String) {});
//       }
//     }
//   }

//   Future<void> _handleVideoTap() async {
//     print("video");
//     var mediaPickerVM = Provider.of<MediaPickerVM>(context, listen: false);
//     await mediaPickerVM.pickVideo();
//     for (var video in mediaPickerVM.selectedFiles) {
//       if (Provider.of<CreatePostVM>(context, listen: false)
//               .getProgress(video.path) ==
//           null) {
//         print("video:${video.path}");
//         var file = File(video.path);
//         Provider.of<CreatePostVM>(context, listen: false)
//             .uploadFile(file, onSuccess: () {}, onError: (String) {});
//       }
//     }
//   }

//   Future<void> _handleFileTap() async {
//     print("file");
//     var mediaPickerVM = Provider.of<MediaPickerVM>(context, listen: false);
//     await mediaPickerVM.pickFile();
//     for (var file in mediaPickerVM.selectedFiles) {
//       if (Provider.of<CreatePostVM>(context, listen: false)
//               .getProgress(file.path) ==
//           null) {
//         print("file:${file.path}");
//         var fileObj = File(file.path);
//         Provider.of<CreatePostVM>(context, listen: false).uploadFile(fileObj,
//             onSuccess: () {
//           print("success");
//         }, onError: (error) {
//           // AmityDialog().showAlertErrorDialog(title: error, message: error);
//         });
//       }
//     }
//   }
// }
