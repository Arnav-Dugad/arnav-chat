import 'package:arnav_chat/core/design/theme.dart';
import 'package:arnav_chat/core/design/tokens.dart';
import 'package:arnav_chat/core/widgets/buttons.dart';
import 'package:arnav_chat/core/widgets/count_badge.dart';
import 'package:arnav_chat/core/widgets/empty_state.dart';
import 'package:arnav_chat/data/models/message.dart';
import 'package:arnav_chat/features/chat/widgets/receipt_ticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Brightness b = Brightness.light}) => MaterialApp(
      theme: AppTheme.build(b, AccentColor.sapphire),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('CountBadge shows count and caps at 99+', (tester) async {
    await tester.pumpWidget(_wrap(const CountBadge(count: 3)));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    await tester.pumpWidget(_wrap(const CountBadge(count: 250)));
    await tester.pumpAndSettle();
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('ReceiptTicks exposes an accessible label', (tester) async {
    await tester.pumpWidget(_wrap(const ReceiptTicks(receipt: Receipt.read)));
    expect(find.bySemanticsLabel('Read'), findsOneWidget);
    await tester.pumpWidget(_wrap(const ReceiptTicks(receipt: Receipt.pending)));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Sending'), findsOneWidget);
  });

  testWidgets('PillButton fires once and is disabled while busy', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(PillButton(label: 'Send', onPressed: () => taps++)));
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(taps, 1);

    await tester.pumpWidget(_wrap(PillButton(label: 'Send', busy: true, onPressed: () => taps++)));
    await tester.tap(find.byType(PillButton));
    await tester.pump(const Duration(milliseconds: 300));
    expect(taps, 1);
  });

  testWidgets('EmptyState renders in dark mode', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState(icon: Icons.chat, label: 'No chats yet'), b: Brightness.dark));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('No chats yet'), findsOneWidget);
  });
}
