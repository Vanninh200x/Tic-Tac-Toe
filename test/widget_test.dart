// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_board_game/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Board game app shows its home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BoardGameApp());

    expect(find.text('BOARDLY'), findsOneWidget);
    expect(find.text('Một nước đi.\nMột chiến thắng.'), findsOneWidget);
    expect(find.text('Đấu với AI'), findsOneWidget);
  });

  testWidgets('home game cards open the playable setup screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BoardGameApp());
    await tester.ensureVisible(find.text('Đấu với AI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đấu với AI'));
    await tester.pumpAndSettle();

    expect(find.text('Thiết lập ván chơi'), findsOneWidget);
    expect(find.text('Đối đầu với AI'), findsOneWidget);
    expect(find.text('Độ khó AI'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bắt đầu ván chơi'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Bắt đầu ván chơi'), findsOneWidget);
  });

  testWidgets('Bluetooth mode opens the direct-connect lobby', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BoardGameApp());
    await tester.ensureVisible(find.text('Đấu qua Bluetooth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đấu qua Bluetooth'));
    await tester.pumpAndSettle();

    expect(find.text('Đấu qua Bluetooth'), findsOneWidget);
    expect(find.text('Tạo phòng · chơi quân X'), findsOneWidget);
    expect(find.text('Tìm và tham gia phòng'), findsOneWidget);
    expect(find.text('Số quân liên tiếp để thắng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('starting a game opens the board with the chosen mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BoardGameApp());
    await tester.ensureVisible(find.text('Hai người chơi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hai người chơi'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Bắt đầu ván chơi'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Bắt đầu ván chơi'));
    await tester.pumpAndSettle();

    expect(find.text('Ván đấu'), findsOneWidget);
    expect(find.text('Hai người chơi · 5 × 5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('statistics and settings remain reachable on the new theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BoardGameApp());
    await tester.tap(find.byTooltip('Cài đặt'));
    await tester.pumpAndSettle();

    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Theo cách của bạn'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thống kê'));
    await tester.pumpAndSettle();

    expect(find.text('Thống kê'), findsOneWidget);
    expect(find.text('Mỗi ván đều có ý nghĩa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the new home layout fits a compact phone viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BoardGameApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Đấu với AI'), findsOneWidget);
    expect(find.text('Hai người chơi'), findsOneWidget);
  });
}
