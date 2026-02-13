import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:go_router/go_router.dart';

class EmojiSelector extends StatelessWidget {
  const EmojiSelector({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Emoji'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SizedBox.expand(
        child: EmojiPicker(
          onEmojiSelected: (Category? category, Emoji? emoji) {
            context.pop<String?>(emoji?.emoji);
          },
          config: Config(
            viewOrderConfig: ViewOrderConfig(
                top: EmojiPickerItem.categoryBar,
                middle: EmojiPickerItem.emojiView),
            bottomActionBarConfig: BottomActionBarConfig(enabled: false),
            categoryViewConfig: CategoryViewConfig(
              iconColor: Theme.of(context).colorScheme.onSurface,
              iconColorSelected: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              indicatorColor: Theme.of(context).colorScheme.primary,
              recentTabBehavior: RecentTabBehavior.NONE,
              extraTab: CategoryExtraTab.SEARCH,
            ),
            emojiViewConfig: EmojiViewConfig(
                backgroundColor: Theme.of(context).colorScheme.surface),
            searchViewConfig: SearchViewConfig(
              backgroundColor: Theme.of(context).colorScheme.surface,
              buttonIconColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
