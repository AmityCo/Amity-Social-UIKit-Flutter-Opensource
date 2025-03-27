part of '../message_bubble_view.dart';

class ReactionBubble extends StatelessWidget {
  final List<String?> reactions; // up to 3 reactions, etc.
  final int totalReactionCount;
  final AmityThemeColor theme;
  final bool containMyReations;
  final VoidCallback? onTap;

  const ReactionBubble({
    Key? key,
    required this.reactions,
    required this.totalReactionCount,
    required this.theme,
    required this.containMyReations,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no reactions, show nothing
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    const double iconSize = 20;
    const double overlap = 13;
    // overlap is how much each icon shifts from the previous one

    return Transform.translate(
      offset: const Offset(0, -6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          decoration: BoxDecoration(
            color: containMyReations
                ? theme.highlightColor
                : theme.backgroundColor, // bubble background color
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: containMyReations
                    ? theme.backgroundColor
                    : theme.baseColorShade4),
            // border: Border.all(color: containMyReations ? theme.alertColor : theme.alertColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Overlapping icons using a Stack
              SizedBox(
                width: iconSize + (reactions.length - 1) * overlap,
                height: iconSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(reactions.length, (index) {
                    return Positioned(
                      left: index * overlap,
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.backgroundColor,
                        ),
                        child: SvgPicture.asset(
                          reactions[index] ?? "",
                          package: 'amity_uikit_beta_service',
                        ),
                      ),
                    );
                  }).reversed.toList(),
                ),
              ),
              const SizedBox(width: 2),
              // Total reaction count
              Text(
                '$totalReactionCount',
                style: AmityTextStyle.captionBold(containMyReations
                    ? theme.backgroundColor
                    : theme.baseColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
