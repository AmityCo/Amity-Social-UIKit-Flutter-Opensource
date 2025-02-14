import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/amity_social_behaviour_helper.dart';
import '../../../utils/user_image.dart';
import '../amity_post_content_component.dart';

class PostPollContent extends StatefulWidget {
  final AmityPost post;
  final AmityPostContentComponentStyle style;
  final AmityThemeColor theme;
  final bool hideMenu;
  final Function goToDetail;

  const PostPollContent({
    Key? key,
    required this.post,
    required this.style,
    required this.theme,
    required this.hideMenu,
    required this.goToDetail,
  }) : super(key: key);

  @override
  _PostPollContentState createState() => _PostPollContentState();
}

class _PostPollContentState extends State<PostPollContent> {
  late AmityPoll? currentPoll;
  bool isResultState = false;
  bool isVoting = false;
  bool isExpanded = false;
  bool get canVote {
    if (widget.post.targetType == AmityPostTargetType.COMMUNITY) {
      return !widget.hideMenu &&
          !isVoting &&
          widget.post.feedType != AmityFeedType.REVIEWING;
    } else {
      return !isVoting && widget.post.feedType != AmityFeedType.REVIEWING;
    }
  }

  late StreamSubscription<AmityPoll> subscription;

  final ValueNotifier<List<int>> selectedIndicesNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    final pollData = widget.post.data as PollData;
    currentPoll = pollData.poll;
    final poll = currentPoll; // Accessing poll
    if (poll != null) {
      // cache value before reset to prevent racing condition
      final shouldShowResultForCreator =
          widget.style == AmityPostContentComponentStyle.detail &&
              AmitySocialBehaviorHelper.showPollResultInDetailFirst;
      setState(() {
        isResultState = widget.post.feedType != AmityFeedType.REVIEWING &&
            (poll.isVoted! || poll.isClose || shouldShowResultForCreator);

        isExpanded = widget.style == AmityPostContentComponentStyle.detail ||
            widget.post.feedType == AmityFeedType.REVIEWING;

        // reset flag
        if (shouldShowResultForCreator) {
          AmitySocialBehaviorHelper.showPollResultInDetailFirst = false;
        }
      });
    }

    subscription = pollData.live.getPoll().listen(
      (poll) {
        setState(() {
          // assign updated poll
          currentPoll = poll;

          final newIsResultState =
              widget.post.feedType != AmityFeedType.REVIEWING &&
                  (poll.isVoted! || poll.isClose);

          // trust existing state if poll is not voted or closed
          if (newIsResultState && newIsResultState != isResultState)
            isResultState = newIsResultState;
        });
      },
      onError: (error) {
        // ignore
      },
    );
  }

  @override
  void dispose() {
    selectedIndicesNotifier.dispose();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final pollData = widget.post.data as PollData;
    final poll = currentPoll; // Accessing poll
    if (poll == null) return Container();

    final timeLeft = poll.isClose
        ? 'Ended'
        : poll.closedAt == null
            ? ''
            : readableTimeLeft(poll.closedAt!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isResultState)
          PollOptions(
            poll: poll,
            selectedIndicesNotifier: selectedIndicesNotifier,
            theme: widget.theme,
            isExpanded: isExpanded,
            onSeeMore: () {
              // go to detail
              widget.goToDetail();
            },
            canVote: canVote,
          ),
        if (isResultState)
          PollResults(
            poll: poll,
            theme: widget.theme,
            isExpanded: isExpanded,
            onSeeFullResults: () {
              // go to detail
              widget.goToDetail();
            },
          ),
        const SizedBox(height: 8),
        if (!isResultState)
          ValueListenableBuilder<List<int>>(
            valueListenable: selectedIndicesNotifier,
            builder: (context, selectedIndices, _) {
              return ElevatedButton(
                onPressed: isVoting || selectedIndices.isEmpty || !canVote
                    ? () {}
                    : () => _votePoll(poll, selectedIndices),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: selectedIndices.isEmpty
                      ? widget.theme.primaryColor
                          .blend(ColorBlendingOption.shade2)
                      : widget.theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 40),
                  splashFactory: NoSplash.splashFactory,
                ),
                child: isVoting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text("Vote",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
              );
            },
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${NumberFormat.decimalPattern().format(poll.totalVote)} votes • $timeLeft',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.theme.baseColorShade2,
                ),
              ),
            ),
            if (widget.post.postedUserId ==
                    AmityCoreClient.getCurrentUser().userId &&
                !poll.isVoted! &&
                poll.status != AmityPollStatus.CLOSED)
              GestureDetector(
                onTap: () {
                  if (widget.style == AmityPostContentComponentStyle.detail) {
                    // Toggle result state
                    setState(() {
                      isResultState = !isResultState;
                    });
                  } else {
                    // Navigate to detail page and show results
                    AmitySocialBehaviorHelper.showPollResultInDetailFirst =
                        true;
                    widget.goToDetail();
                  }
                },
                child: Text(
                  isResultState ? "Back to vote" : "See results",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _votePoll(AmityPoll poll, List<int> selectedIndices) {
    setState(() {
      isVoting = true;
    });

    final answerIds =
        selectedIndices.map((index) => poll.answers![index].id!).toList();

    AmitySocialClient.newPollRepository()
        .vote(pollId: poll.pollId!, answerIds: answerIds)
        .then((value) {
      setState(() {
        isVoting = false;
        isResultState = true;
      });
    }).onError((error, stackTrace) {
      setState(() {
        isVoting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to vote: ${error.toString()}"),
          backgroundColor: widget.theme.alertColor,
        ),
      );
    });
  }

  String readableTimeLeft(DateTime targetTime, {DateTime? startTime}) {
    startTime ??= DateTime.now();

    if (targetTime.isBefore(startTime) || targetTime == startTime) {
      return "Ended";
    }

    final duration = targetTime.difference(startTime);

    final totalMinutes = duration.inMinutes;
    final totalHours = duration.inHours;
    final totalDays = duration.inDays;

    if (totalDays > 0) {
      final remainingHours = totalHours % 24;
      final daysLeft = remainingHours > 0 ? totalDays + 1 : totalDays;
      return "${daysLeft}d left";
    } else if (totalHours > 0) {
      return "${totalHours}h left";
    } else if (totalMinutes > 0) {
      return "${totalMinutes}m left";
    } else {
      return "0m left";
    }
  }
}

class PollOptions extends StatelessWidget {
  final AmityPoll poll;
  final ValueNotifier<List<int>> selectedIndicesNotifier;
  final AmityThemeColor theme;
  final bool isExpanded;
  final Function onSeeMore;
  final bool canVote;

  const PollOptions({
    Key? key,
    required this.poll,
    required this.selectedIndicesNotifier,
    required this.theme,
    required this.isExpanded,
    required this.onSeeMore,
    required this.canVote,
  }) : super(key: key);

  static const int threshold = 4; // Define threshold as a constant for clarity

  @override
  Widget build(BuildContext context) {
    final answers = poll.answers!;
    final isOptionsExpanded = isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          poll.answerType == AmityPollAnswerType.SINGLE
              ? "Select one option"
              : "Select one or more options",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.baseColorShade2,
          ),
        ),
        const SizedBox(height: 8),
        ...answers
            .take(isOptionsExpanded
                ? answers.length
                : min(threshold, answers.length))
            .map((answer) {
          final index = answers.indexOf(answer);

          return ValueListenableBuilder<List<int>>(
            valueListenable: selectedIndicesNotifier,
            builder: (context, selectedIndices, _) {
              final isSelected = selectedIndices.contains(index);

              return GestureDetector(
                onTap: canVote
                    ? () {
                        final newIndices = List<int>.from(selectedIndices);
                        if (poll.answerType == AmityPollAnswerType.SINGLE) {
                          newIndices.clear();
                          newIndices.add(index);
                        } else {
                          isSelected
                              ? newIndices.remove(index)
                              : newIndices.add(index);
                        }
                        selectedIndicesNotifier.value = newIndices;
                      }
                    : null, // Disable interaction if `canVote` is false
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  constraints: const BoxConstraints(
                    minHeight: 48, // Minimum height is 48 but grows dynamically
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : theme.baseColorShade4,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center vertically
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0), // Add vertical padding
                          child: Text(
                            answer.data ?? "",
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.bold,
                              color: canVote
                                  ? theme.baseColor
                                  : theme
                                      .baseColorShade3, // Dim text if disabled
                            ),
                          ),
                        ),
                      ),
                      if (poll.answerType == AmityPollAnswerType.SINGLE)
                        Radio(
                          visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: index,
                          groupValue: selectedIndices.isNotEmpty
                              ? selectedIndices.first
                              : null,
                          onChanged: canVote
                              ? (_) {
                                  final newIndices = [index];
                                  selectedIndicesNotifier.value = newIndices;
                                }
                              : null, // Disable if `canVote` is false
                          activeColor: theme.primaryColor,
                        ),
                      if (poll.answerType == AmityPollAnswerType.MULTIPLE)
                        Checkbox(
                          visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: isSelected,
                          onChanged: canVote
                              ? (_) {
                                  final newIndices =
                                      List<int>.from(selectedIndices);
                                  isSelected
                                      ? newIndices.remove(index)
                                      : newIndices.add(index);
                                  selectedIndicesNotifier.value = newIndices;
                                }
                              : null, // Disable if `canVote` is false
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          activeColor: theme.primaryColor,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
        if (answers.length > threshold && !isOptionsExpanded)
          const SizedBox(height: 8),
        if (answers.length > threshold && !isOptionsExpanded)
          ElevatedButton(
            onPressed: () => onSeeMore(),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: theme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: theme.baseColorShade3,
                  width: 1,
                ),
              ),
              minimumSize: const Size(double.infinity, 40),
              splashFactory: NoSplash.splashFactory,
            ),
            child: Text(
              "See ${answers.length - threshold} more options",
              style: TextStyle(
                color: theme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class PollResults extends StatelessWidget {
  final AmityPoll poll;
  final AmityThemeColor theme;
  final bool isExpanded;
  final Function onSeeFullResults;

  const PollResults({
    Key? key,
    required this.poll,
    required this.theme,
    this.isExpanded = false,
    required this.onSeeFullResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final answers = poll.answers!;
    const threshold = 4;

    // Reorder answers by vote count, retaining original order for equal votes
    final sortedAnswers = List<AmityPollAnswer>.from(answers);
    sortedAnswers.sort((a, b) {
      int compareVotes = (b.voteCount ?? 0).compareTo(a.voteCount ?? 0);
      if (compareVotes == 0) {
        // Retain original order for equal votes
        return answers.indexOf(a).compareTo(answers.indexOf(b));
      }
      return compareVotes;
    });

    // Determine the highest vote count
    final highestVoteCount = sortedAnswers.first.voteCount ?? 0;

    // If all answers have 0 votes, don't highlight anything
    final shouldHighlight = highestVoteCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sortedAnswers
            .take(isExpanded ? sortedAnswers.length : threshold)
            .map((answer) {
          final votePercentage = (poll.totalVote > 0)
              ? ((answer.voteCount ?? 0) / poll.totalVote) * 100
              : 0.0;

          // Check if the answer should be highlighted
          final isTopAnswer =
              shouldHighlight && (answer.voteCount == highestVoteCount);

          final userVoted = answer.isVotedByUser ?? false;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isTopAnswer ? theme.primaryColor : theme.baseColorShade4,
                width: isTopAnswer ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        answer.data ?? "",
                        style: TextStyle(
                          color: theme.baseColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${votePercentage % 1 == 0 ? votePercentage.toInt() : votePercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isTopAnswer
                            ? theme.primaryColor
                            : theme.baseColorShade1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        getVotedByText(answer.voteCount ?? 0, userVoted),
                        style: TextStyle(
                          color: theme.baseColorShade2,
                          fontSize: 12,
                        ),
                        maxLines: 1, // Ensures the text does not overflow
                        overflow: TextOverflow
                            .ellipsis, // Adds ellipsis if the text is too long
                      ),
                    ),
                    if (userVoted)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: ClipOval(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: AmityUserImage(
                              user: AmityCoreClient.getCurrentUser(),
                              theme: theme,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  // Apply corner radius here
                  child: LinearProgressIndicator(
                    value: votePercentage / 100,
                    backgroundColor: isTopAnswer
                        ? theme.primaryColor.blend(ColorBlendingOption.shade3)
                        : theme.baseColorShade4,
                    valueColor: AlwaysStoppedAnimation(
                      isTopAnswer ? theme.primaryColor : theme.baseColorShade1,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }),
        if (sortedAnswers.length > threshold && !isExpanded)
          const SizedBox(height: 8),
        if (sortedAnswers.length > threshold && !isExpanded)
          ElevatedButton(
            onPressed: () => onSeeFullResults(),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: theme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
                side: BorderSide(
                  color: theme.baseColorShade3, // Border color
                  width: 1, // Border width
                ),
              ),
              minimumSize: const Size(double.infinity, 40),
              splashFactory: NoSplash.splashFactory,
            ),
            child: Text(
              "See Full Results",
              style: TextStyle(
                color: theme.baseColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

String getVotedByText(int voteCount, bool isVotedByUser) {
  if (voteCount == 0) {
    return "No votes";
  } else if (voteCount == 1 && isVotedByUser) {
    return "Voted by you";
  } else if (voteCount == 1) {
    return "Voted by 1 participant";
  } else {
    // Check if the number needs a "+" sign
    final nextThreshold = _getNextThreshold(voteCount);
    final plusSign = voteCount > nextThreshold ? "+" : "";

    final displayVoteCount = isVotedByUser
        ? readableNumber(voteCount - 1)
        : readableNumber(voteCount);

    var votedByText = "Voted by $displayVoteCount$plusSign participants";
    if (isVotedByUser) {
      votedByText += " and you";
    }
    return votedByText;
  }
}

int _getNextThreshold(int count) {
  if (count < 1000) return count;
  final exp = (log(count) / log(1000)).floor();
  return (pow(1000, exp) * (count / pow(1000, exp)).ceil()).toInt();
}

String readableNumber(int count) {
  if (count < 1000) return count.toString();

  final exp = (log(count) / log(1000)).floor();
  final value = (count / pow(1000, exp))
      .toStringAsFixed(1)
      .replaceAll(RegExp(r'\.0$'), '');

  const suffixes = ['K', 'M', 'B', 'T', 'P', 'E'];
  return '$value${suffixes[exp - 1]}';
}
