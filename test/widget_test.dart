// Calculator App Widget Tests
//
// Tests for the calculator app functionality including basic operations,
// clear functionality, and edge cases.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculatorapp/main.dart';

void main() {
  group('Calculator App Tests', () {
    testWidgets('Calculator displays initial value of 0', (WidgetTester tester) async {
    // Build our app and trigger a frame.
      await tester.pumpWidget(const CalculatorApp());

      // Verify that the calculator starts with 0 displayed in the main display area
      expect(find.text('Calculator App'), findsOneWidget);
      
      // Find the main display text (larger font size)
      final displayText = find.byWidgetPredicate(
        (widget) => widget is Text && 
                    widget.data == '0' && 
                    widget.style?.fontSize == 36.0
      );
      expect(displayText, findsOneWidget);
    });

    testWidgets('Number buttons work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Tap number 5 button
      await tester.tap(find.widgetWithText(ElevatedButton, '5'));
      await tester.pump();

      // Verify that 5 is displayed in the main display
      final displayText5 = find.byWidgetPredicate(
        (widget) => widget is Text && 
                    widget.data == '5' && 
                    widget.style?.fontSize == 36.0
      );
      expect(displayText5, findsOneWidget);

      // Tap number 3 button
      await tester.tap(find.widgetWithText(ElevatedButton, '3'));
      await tester.pump();

      // Verify that 53 is displayed in the main display
      final displayText53 = find.byWidgetPredicate(
        (widget) => widget is Text && 
                    widget.data == '53' && 
                    widget.style?.fontSize == 36.0
      );
      expect(displayText53, findsOneWidget);
    });

    testWidgets('Clear button resets calculator', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Enter some numbers
      await tester.tap(find.widgetWithText(ElevatedButton, '1'));
      await tester.tap(find.widgetWithText(ElevatedButton, '2'));
      await tester.tap(find.widgetWithText(ElevatedButton, '3'));
      await tester.pump();

      // Verify numbers are displayed
      final displayText123 = find.byWidgetPredicate(
        (widget) => widget is Text && 
                    widget.data == '123' && 
                    widget.style?.fontSize == 36.0
      );
      expect(displayText123, findsOneWidget);

      // Tap clear button
      await tester.tap(find.widgetWithText(ElevatedButton, 'C'));
      await tester.pump();

      // Verify calculator is reset to 0
      final displayText0 = find.byWidgetPredicate(
        (widget) => widget is Text && 
                    widget.data == '0' && 
                    widget.style?.fontSize == 36.0
      );
      expect(displayText0, findsOneWidget);
    });

    testWidgets('Addition operation works', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Enter 5 + 3
      await tester.tap(find.widgetWithText(ElevatedButton, '5'));
      await tester.tap(find.widgetWithText(ElevatedButton, '+'));
      await tester.tap(find.widgetWithText(ElevatedButton, '3'));
      await tester.tap(find.widgetWithText(ElevatedButton, '='));
      await tester.pump();

      // Verify result is 8 in the main display
      final displayText8 = find.byWidgetPredicate(
        (widget) => widget is Text && 
                    widget.data == '8' && 
                    widget.style?.fontSize == 36.0
      );
      expect(displayText8, findsOneWidget);
    });

    testWidgets('Division by zero shows error', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Enter 5 ÷ 0
      await tester.tap(find.widgetWithText(ElevatedButton, '5'));
      await tester.tap(find.widgetWithText(ElevatedButton, '÷'));
      await tester.tap(find.widgetWithText(ElevatedButton, '0'));
      await tester.tap(find.widgetWithText(ElevatedButton, '='));
      await tester.pump();

      // Verify error message appears
      expect(find.text('Cannot divide by zero'), findsOneWidget);
    });

    testWidgets('Theme toggle button exists', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Verify theme toggle button exists
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('History button appears after calculations', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Initially history button should be visible but disabled
      final historyButton = find.byIcon(Icons.history);
      expect(historyButton, findsOneWidget);

      // Perform a calculation
      await tester.tap(find.widgetWithText(ElevatedButton, '2'));
      await tester.tap(find.widgetWithText(ElevatedButton, '+'));
      await tester.tap(find.widgetWithText(ElevatedButton, '3'));
      await tester.tap(find.widgetWithText(ElevatedButton, '='));
      await tester.pump();

      // History button should still be visible (it's always there, just enabled/disabled)
      expect(historyButton, findsOneWidget);
      
      // Verify that we can tap the history button (it should be enabled now)
      await tester.tap(historyButton);
      await tester.pump();
      
      // Should show history dialog
      expect(find.text('Calculation History'), findsOneWidget);
    });
  });
}
