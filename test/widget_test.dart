// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'test_helper.dart';

import 'package:todomini/main.dart';
import 'package:todomini/providers/theme_provider.dart';
import 'package:todomini/providers/task_provider.dart';

void main() {
  setupTestDatabase();
  testWidgets('ToDoMini app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: const ToDoMiniApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('ToDoMini'), findsOneWidget);

    // Verify that the add task button is present
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verify that the empty state message is shown when no tasks exist
    expect(find.text('No tasks yet'), findsOneWidget);
  });
}
