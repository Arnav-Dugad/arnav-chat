import 'package:flutter/material.dart';

import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/pressable.dart';
import '../../data/models/app_user.dart';

class UserRow extends StatelessWidget {
  const UserRow({super.key, required this.user, required this.onTap, this.trailing});

  final AppUser user;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Pressable(
    scale: 0.98,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gaps.x4, vertical: 9),
      child: Row(
        children: [
          Avatar(name: user.displayName, url: user.photoUrl, size: 48, heroTag: 'user-${user.uid}'),
          const SizedBox(width: Gaps.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(user.handle, style: context.text.bodySmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}
