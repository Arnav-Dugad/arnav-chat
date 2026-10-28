import 'package:flutter/material.dart';

import '../../../core/design/palette.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/widgets/glass.dart';

class DaySeparator extends StatelessWidget {
  const DaySeparator({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Glass(
        pill: true,
        blur: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(TimeFormat.daySeparator(date), style: context.text.labelSmall),
      ),
    ),
  );
}
