import 'package:durga_puja_pandel/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CustomButton renders label and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            label: 'Explore pandals',
            icon: Icons.explore,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Explore pandals'), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
  });
}
