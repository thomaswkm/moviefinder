import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moviefinder/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders intro then login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieFinderApp());

    expect(find.text('MovieApp'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido!'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('navigates from login to register page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MovieFinderApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    final registerButton = find.byKey(const Key('go_to_register_button'));
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('¡Únete y encuentra\ntus películas!'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('restores mock session from stored token', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'mock-jwt-token'});

    await tester.pumpWidget(const MovieFinderApp());
    await tester.pumpAndSettle();

    expect(find.text('For you'), findsOneWidget);
    expect(find.text('The Godfather'), findsOneWidget);
  });

  testWidgets('opens media detail placeholder from home card', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'mock-jwt-token'});

    await tester.pumpWidget(const MovieFinderApp());
    await tester.pumpAndSettle();

    final mediaCard = find.byKey(const ValueKey('media_card_1'));
    await tester.ensureVisible(mediaCard);
    await tester.pumpAndSettle();
    await tester.tap(mediaCard);
    await tester.pumpAndSettle();

    expect(
      find.text('Detalle de contenido se implementara en el siguiente CU.'),
      findsOneWidget,
    );
  });

  testWidgets('filters home content by series tab', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'mock-jwt-token'});

    await tester.pumpWidget(const MovieFinderApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home_filter_series')));
    await tester.pumpAndSettle();

    expect(find.text('Breaking Bad'), findsOneWidget);
    expect(find.text('5 seasons'), findsOneWidget);
  });
}
