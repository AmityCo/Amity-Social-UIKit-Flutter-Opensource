import 'dart:async';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/toast/amity_uikit_toast.dart';
import '../../core/toast/bloc/amity_uikit_toast_bloc.dart';
import '../../core/ui/mention/mention_text_editing_controller.dart';
import '../../utils/amity_dialog.dart';
import '../globalfeed/bloc/global_feed_bloc.dart';
import 'bloc/poll_post_composer_bloc.dart';

class AmityPollPostComposerPage extends NewBasePage {
  final String targetId;
  final AmityPostTargetType targetType;
  final String? targetCommunityName;
  final void Function(bool shouldPopCaller)? onPopRequested;

  final MentionTextEditingController _questionController =
      MentionTextEditingController();

  static const int maxQuestionLength = 500;
  static const int maxOptionLength = 60;
  static const int minOptionsRequired = 2;
  static const int maxPollDurationDays = 30;

  AmityPollPostComposerPage(
      {Key? key,
      required this.targetId,
      required this.targetType,
      this.targetCommunityName,
      this.onPopRequested})
      : super(key: key, pageId: 'poll_post_composer_page');

  @override
  Widget buildPage(BuildContext context) {
    String? communityId =
        (targetType == AmityPostTargetType.COMMUNITY) ? targetId : null;
    return BlocProvider(
      create: (context) =>
          PollComposerBloc()..add(UpdateOptionsEvent(options: ['', ''])),
      child: BlocBuilder<PollComposerBloc, PollComposerState>(
        builder: (context, state) {
          final bloc = context.read<PollComposerBloc>();

          return Scaffold(
            backgroundColor: theme.backgroundColor,
            appBar: AppBar(
              backgroundColor: theme.backgroundColor,
              title: Text(
                targetCommunityName ?? context.l10n.general_my_timeline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.baseColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.close, color: theme.baseColor),
                onPressed: () => handleClose(context),
              ),
              actions: [
                TextButton(
                  onPressed: state.isPosting ||
                          state.question.trim().isEmpty ||
                          state.options
                                  .where((o) => o.trim().isNotEmpty)
                                  .length <
                              minOptionsRequired
                      ? null
                      : () => _createPollPost(state, bloc, context),
                  child: Text(
                    context.l10n.general_post,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: state.isPosting ||
                              state.question.trim().isEmpty ||
                              state.options
                                      .where((o) => o.trim().isNotEmpty)
                                      .length <
                                  minOptionsRequired
                          ? theme.primaryColor.blend(ColorBlendingOption.shade3)
                          : theme.primaryColor,
                    ),
                  ),
                ),
              ],
              centerTitle: true,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildPollQuestionSection(
                    context, state, bloc, _questionController, communityId),
                const SizedBox(height: 24),
                _buildSectionTitle(context.l10n.general_options,
                    description: context.l10n
                        .poll_options_description(minOptionsRequired)),
                ..._buildOptionFields(context, state, bloc),
                _buildAddOptionButton(context, state, bloc),
                Divider(color: theme.baseColorShade4, height: 32),
                _buildMultipleSelectionRow(context, state, bloc),
                Divider(color: theme.baseColorShade4, height: 32),
                _buildPollDurationSection(state, bloc, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPollQuestionSection(
    BuildContext context,
    PollComposerState state,
    PollComposerBloc bloc,
    TextEditingController controller,
    String? communityId,
  ) {
    const int maxQuestionLength = 500;
    // Only set the controller's text if the state.question differs to prevent cursor reset.
    if (controller.text.isEmpty && state.question.isNotEmpty) {
      controller.text = state.question;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.poll_question,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.baseColor,
              ),
            ),
            Text(
              '${state.question.length}/$maxQuestionLength',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: theme.baseColorShade1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        MentionTextField(
          theme: theme,
          controller: _questionController,
          suggestionDisplayMode: SuggestionDisplayMode.inline,
          mentionContentType: MentionContentType.post,
          suggestionMaxRow: 2,
          communityId: communityId,
          maxLines: null,
          enabled: !state.isPosting,
          decoration: InputDecoration(
            hintText: context.l10n.poll_question_hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: theme.baseColorShade3,
            ),
          ),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: theme.baseColor,
          ),
          onChanged: (value) {
            bloc.add(UpdateQuestionEvent(question: value));
          },
        ),
        if (state.question.trim().length <= maxQuestionLength) ...[
          Divider(
            color: theme.baseColorShade4,
          ),
        ],
        if (state.question.trim().length > maxQuestionLength) ...[
          Divider(color: theme.alertColor),
          Text(
            context.l10n.error_max_poll_characters(maxQuestionLength),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: theme.alertColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, {String? description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AmityTextStyle.titleBold(theme.baseColor)),
          if (description != null) ...[
            Text(description,
                style: AmityTextStyle.caption(theme.baseColorShade1)),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildOptionFields(
      BuildContext context, PollComposerState state, PollComposerBloc bloc) {
    return state.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0), // Consistent spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              // Align items to the start
              children: [
                // Expanded TextField to support multiple lines
                Expanded(
                  child: TextField(
                    maxLines: null,
                    // Allows the field to expand to multiple lines
                    enabled: !state.isPosting,
                    controller: TextEditingController(text: option)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: option.length),
                      ),
                    // Preserve cursor position
                    onChanged: (value) {
                      if (!state.isPosting) {
                        final updatedOptions = [...state.options];
                        updatedOptions[index] = value;
                        bloc.add(UpdateOptionsEvent(options: updatedOptions));
                      }
                    },
                    decoration: InputDecoration(
                      hintText: context.l10n.poll_option_hint(index + 1),
                      // Dynamic hint text
                      hintStyle: AmityTextStyle.body(theme.baseColorShade2),
                      filled: true,
                      fillColor: theme.baseColorShade4,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: option.trim().length > maxOptionLength
                              ? theme.alertColor
                              : theme.baseColorShade4,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: option.trim().length > maxOptionLength
                              ? theme.alertColor
                              : theme.baseColorShade4,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                    ),
                    style: AmityTextStyle.body(theme.baseColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 0.0),
                  child: GestureDetector(
                    onTap: state.isPosting
                        ? null
                        : () {
                            final updatedOptions = [...state.options];
                            updatedOptions
                                .removeAt(index); // Remove the tapped option
                            if (updatedOptions.isEmpty) {
                              // Ensure at least one empty row remains
                              updatedOptions.add('');
                            }
                            bloc.add(
                                UpdateOptionsEvent(options: updatedOptions));
                          },
                    child: SvgPicture.asset(
                      'assets/Icons/amity_ic_poll_composer_delete_button.svg',
                                          package: 'amity_uikit_beta_service',

                      colorFilter: ColorFilter.mode(
                        state.isPosting
                            ? theme.secondaryColor
                            : theme.baseColor,
                        BlendMode.srcIn,
                      ),
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ],
            ),
            // Error text for exceeding max length
            if (option.trim().length > maxOptionLength)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  context.l10n
                      .error_max_poll_option_characters(maxOptionLength),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: theme.alertColor,
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAddOptionButton(
      BuildContext context, PollComposerState state, PollComposerBloc bloc) {
    return state.options.length < 10
        ? Padding(
            padding:
                const EdgeInsets.only(bottom: 12.0), // Matches option spacing
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: state.isPosting
                        ? null
                        : () {
                            final updatedOptions = [...state.options, ''];
                            bloc.add(
                                UpdateOptionsEvent(options: updatedOptions));
                          },
                    child: Container(
                      height: 40.0, // Consistent with text field height
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: state.isPosting
                              ? theme.secondaryColor
                                  .blend(ColorBlendingOption.shade3)
                              : theme.baseColorShade3,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add,
                              size: 16,
                              color: state.isPosting
                                  ? theme.secondaryColor
                                  : theme.baseColor),
                          const SizedBox(width: 8),
                          Text(context.l10n.poll_add_option,
                              style: AmityTextStyle.bodyBold(theme.secondaryColor)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Right padding to align with delete button space
                const SizedBox(width: 32.0),
                // Adjust width to match delete button's width
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget buildPollOptionsSection(PollComposerState state, PollComposerBloc bloc,
      BuildContext context, AmityThemeColor theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Poll must contain at least $minOptionsRequired options',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: theme.primaryColor.blend(ColorBlendingOption.shade2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._buildOptionFields(
          context,
          state,
          bloc,
        ),
        _buildAddOptionButton(context, state, bloc),
        const SizedBox(height: 24),
        Divider(
          color: theme.baseColorShade4,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  Widget _buildMultipleSelectionRow(
      BuildContext context, PollComposerState state, PollComposerBloc bloc) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.poll_multiple_selection_title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.baseColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.poll_multiple_selection_description,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: theme.baseColorShade1,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: state.isMultipleChoice,
          onChanged: state.isPosting
              ? null
              : (value) =>
                  bloc.add(UpdateMultipleChoiceEvent(isMultipleChoice: value)),
          activeColor: theme.backgroundColor,
          activeTrackColor: theme.primaryColor,
          inactiveThumbColor: theme.backgroundColor,
          inactiveTrackColor: theme.baseColorShade3,
        ),
      ],
    );
  }

  Widget _buildPollDurationSection(
      PollComposerState state, PollComposerBloc bloc, BuildContext context) {
    final DateFormat formatter = DateFormat(
        "dd MMM 'at' hh:mm a", Localizations.localeOf(context).toLanguageTag());
    final bool isCustomSelected = state.selectedPollDurationIndex == -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context.l10n.poll_duration,
          description: context.l10n.poll_duration_hint,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: state.isPosting
              ? null
              : () async {
                  final selectedIndex = await showModalBottomSheet<int>(
                    context: context,
                    backgroundColor: theme.backgroundColor,
                    builder: (context) {
                      return ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                        children: [
                          ...state.durationDays.asMap().entries.map((entry) {
                            final index = entry.key;
                            final days = entry.value;
                            final localizedDuration =
                                context.l10n.poll_duration_days(days);

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              title: Text(
                                localizedDuration,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.baseColor,
                                ),
                              ),
                              trailing: Radio<int>(
                                value: index,
                                groupValue: state.selectedPollDurationIndex,
                                onChanged: state.isPosting
                                    ? null
                                    : (value) {
                                        Navigator.pop(context, value);
                                      },
                                activeColor: theme.primaryColor,
                                visualDensity: const VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              onTap: state.isPosting
                                  ? null
                                  : () {
                                      Navigator.pop(context, index);
                                    },
                            );
                          }),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            title: Text(
                              context.l10n.poll_custom_edn_date,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.baseColor,
                              ),
                            ),
                            trailing: Radio<int>(
                              value: -1,
                              groupValue: state.selectedPollDurationIndex,
                              onChanged: state.isPosting
                                  ? null
                                  : (value) {
                                      Navigator.pop(context, value);
                                    },
                              activeColor: theme.primaryColor,
                              visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            onTap: state.isPosting
                                ? null
                                : () {
                                    Navigator.pop(context, -1);
                                  },
                          ),
                        ],
                      );
                    },
                  );

                  if (selectedIndex != null) {
                    bloc.add(UpdateDurationEvent(durationIndex: selectedIndex));
                    if (selectedIndex == -1) {
                      final DateTime? customDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(Duration(days: maxPollDurationDays)),
                        locale: Localizations.localeOf(context),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: getDatePickerTheme(context, theme),
                            child: child!,
                          );
                        },
                      );

                      if (customDate != null) {
                        final TimeOfDay? customTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: getTimePickerTheme(context, theme),
                              child: child!,
                            );
                          },
                          helpText: context.l10n.poll_select_time,
                          hourLabelText: context.l10n.poll_time_hour,
                          minuteLabelText: context.l10n.poll_time_minute,
                          cancelText: context.l10n.general_cancel,
                          confirmText: context.l10n.general_confirm,
                        );

                        if (customTime != null) {
                          final customDateTime = DateTime(
                            customDate.year,
                            customDate.month,
                            customDate.day,
                            customTime.hour,
                            customTime.minute,
                          );

                          bloc.add(UpdateCustomDateEvent(
                              customDate: customDateTime));
                        }
                      }
                    }
                  }
                },
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isCustomSelected
                          ? context.l10n.poll_custom_edn_date
                          : context.l10n.poll_duration_days(state
                              .durationDays[state.selectedPollDurationIndex]),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.baseColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.baseColor.blend(ColorBlendingOption.shade3),
                  ),
                ],
              ),
              Divider(
                color: theme.baseColorShade4,
              ), // Add horizontal line below the selector
            ],
          ),
        ),
        if (isCustomSelected && state.customDate != null) ...[
          _buildCustomDatePicker(context, state, bloc),
        ] else if (!isCustomSelected &&
            state.selectedPollDurationIndex >= 0) ...[
          Text(
            context.l10n.poll_ends_on(formatter.format(DateTime.now().add(
                Duration(
                    days:
                        state.durationDays[state.selectedPollDurationIndex])))),
            style: TextStyle(
              fontSize: 12,
              color: theme.baseColorShade1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomDatePicker(
      BuildContext context, PollComposerState state, PollComposerBloc bloc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          context.l10n.poll_ends_on_label,
          style: TextStyle(
            fontSize: 14,
            color: theme.baseColorShade1,
          ),
        ),
        const SizedBox(width: 8),
        // Date Picker Trigger
        GestureDetector(
          onTap: state.isPosting
              ? null
              : () async {
                  final DateTime? customDate = await showDatePicker(
                    context: context,
                    initialDate: state.customDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(Duration(days: maxPollDurationDays)),
                    locale: Localizations.localeOf(context),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: getDatePickerTheme(context, theme),
                        child: child!,
                      );
                    },
                  );

                  if (customDate != null) {
                    final updatedDate = DateTime(
                      customDate.year,
                      customDate.month,
                      customDate.day,
                      state.customDate?.hour ?? 0,
                      state.customDate?.minute ?? 0,
                    );
                    bloc.add(UpdateCustomDateEvent(customDate: updatedDate));
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.baseColorShade4,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.customDate != null
                  ? DateFormat("dd MMM yyyy",
                          Localizations.localeOf(context).toLanguageTag())
                      .format(state.customDate!)
                  : context.l10n.poll_select_date,
              style: TextStyle(
                fontSize: 14,
                color: theme.baseColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Time Picker Trigger
        GestureDetector(
          onTap: state.isPosting
              ? null
              : () async {
                  final TimeOfDay? customTime = await showTimePicker(
                    context: context,
                    initialTime: state.customDate != null
                        ? TimeOfDay(
                            hour: state.customDate!.hour,
                            minute: state.customDate!.minute,
                          )
                        : TimeOfDay.now(),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: getTimePickerTheme(context, theme),
                        child: child!,
                      );
                    },
                    helpText: context.l10n.poll_select_time,
                    hourLabelText: context.l10n.poll_time_hour,
                    minuteLabelText: context.l10n.poll_time_minute,
                    cancelText: context.l10n.general_cancel,
                    confirmText: context.l10n.general_confirm,
                  );

                  if (customTime != null) {
                    final updatedDate = DateTime(
                      state.customDate?.year ?? DateTime.now().year,
                      state.customDate?.month ?? DateTime.now().month,
                      state.customDate?.day ?? DateTime.now().day,
                      customTime.hour,
                      customTime.minute,
                    );
                    bloc.add(UpdateCustomDateEvent(customDate: updatedDate));
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.baseColorShade4,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.customDate != null
                  ? DateFormat("hh:mm a").format(state.customDate!)
                  : context.l10n.poll_select_time,
              style: TextStyle(
                fontSize: 14,
                color: theme.baseColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _createPollPost(
      PollComposerState state, PollComposerBloc bloc, BuildContext context) {
    bloc.add(UpdatePostingStateEvent(isPosting: true));

    context.read<AmityToastBloc>().add(AmityToastLoading(
        message: context.l10n.general_posting, icon: AmityToastIcon.loading));

    var targetBuilder = AmitySocialClient.newPostRepository().createPost();

    AmityPostCreateDataTypeSelector dataTypeSelector;
    if (targetType == AmityPostTargetType.COMMUNITY) {
      dataTypeSelector = targetBuilder.targetCommunity(targetId);
    } else {
      dataTypeSelector = targetBuilder.targetMe();
    }

    // Create the poll first
    AmitySocialClient.newPollRepository()
        .createPoll(question: state.question.trim())
        .answers(
          answers: state.options
              .where((option) => option.trim().isNotEmpty)
              .map((option) => AmityPollAnswer.text(option))
              .toList(),
        )
        .answerType(
          answerType: state.isMultipleChoice
              ? AmityPollAnswerType.MULTIPLE
              : AmityPollAnswerType.SINGLE,
        )
        .closedIn(
            closedIn: Duration(milliseconds: state.pollDurationInMilliseconds))
        .create()
        .then((amityPoll) {
      final mentionMetadataList = _questionController.getAmityMentionMetadata();
      final mentionUserIds = _questionController.getMentionUserIds();
      final mentionMetadataJson =
          AmityMentionMetadataCreator(mentionMetadataList).create();
      dataTypeSelector
          .poll(amityPoll.pollId!)
          .text(amityPoll.question!)
          .mentionUsers(mentionUserIds)
          .metadata(mentionMetadataJson)
          .post()
          .then((post) {
        _onPostSuccess(context, post);
      }).onError((error, stackTrace) {
        bloc.add(UpdatePostingStateEvent(isPosting: false));
        _showToast(
            context, context.l10n.error_create_poll, AmityToastIcon.warning);
      });
    }).onError((error, stackTrace) {
      bloc.add(UpdatePostingStateEvent(isPosting: false));
      _showToast(
          context, context.l10n.error_create_poll, AmityToastIcon.warning);
    });
  }

  ThemeData getDatePickerTheme(BuildContext context, AmityThemeColor theme) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: theme.primaryColor, // Header background color
        onPrimary: Colors.white, // Header text color
        onSurface: theme.baseColor, // Text color on the calendar
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.primaryColor, // Button text color
        ),
      ),
    );
  }

  ThemeData getTimePickerTheme(BuildContext context, AmityThemeColor theme) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: theme.primaryColor.blend(ColorBlendingOption.shade2),
        // Clock dial and selected text color
        onPrimary: theme.primaryColor,
        secondary: theme.primaryColor.blend(ColorBlendingOption.shade2),
        onSecondary: theme.primaryColor,
        onSurface: theme.baseColor, // Text color
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.primaryColor, // Button text color
        ),
      ),
    );
  }

  void _onPostSuccess(BuildContext context, AmityPost post) {
    context.read<AmityToastBloc>().add(AmityToastDismiss());
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<GlobalFeedBloc>().add(GlobalFeedAddLocalPost(post: post));
      Navigator.pop(context);
      onPopRequested?.call(true);
    });
  }

  void _showToast(BuildContext context, String message, AmityToastIcon icon) {
    context
        .read<AmityToastBloc>()
        .add(AmityToastShort(message: message, icon: icon));
  }

  void handleClose(BuildContext context) {
    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.post_discard,
      detailText: context.l10n.post_discard_description,
      leftButtonText: context.l10n.general_keep_editing,
      rightButtonText: context.l10n.general_discard,
      onConfirm: () {
        Navigator.pop(context);
        onPopRequested?.call(true);
      },
    );
  }
}
