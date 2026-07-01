import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moviefinder/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders intro then login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieFinderApp(useMockData: true));

    expect(find.text('MovieApp'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido!'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.byKey(const Key('global_theme_mode_toggle')), findsOneWidget);
  });

  testWidgets('global theme toggle switches app theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MovieFinderApp(useMockData: true));

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );

    await tester.tap(find.byKey(const Key('global_theme_mode_toggle')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    await tester.tap(find.byKey(const Key('global_theme_mode_toggle')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('navigates from login to register page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MovieFinderApp(useMockData: true));
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

    await tester.pumpWidget(const MovieFinderApp(useMockData: true));
    await tester.pumpAndSettle();

    expect(find.text('For you'), findsOneWidget);
    expect(find.text('The Godfather'), findsOneWidget);
  });

  testWidgets('opens media detail from home card and goes back', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'mock-jwt-token'});

    await tester.pumpWidget(const MovieFinderApp(useMockData: true));
    await tester.pumpAndSettle();

    final mediaCard = find.byKey(const ValueKey('media_card_1'));
    await tester.ensureVisible(mediaCard);
    await tester.pumpAndSettle();
    await tester.tap(mediaCard);
    await tester.pumpAndSettle();

    expect(find.text('Pelicula'), findsOneWidget);

    final likeButton = find.byKey(
      const Key('media_detail_like_button'),
      skipOffstage: false,
    );

    await tester.scrollUntilVisible(
      likeButton,
      300,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Agregar a watchlist'), findsOneWidget);

    await tester.tap(likeButton);
    await tester.pumpAndSettle();

    expect(find.text('Agregada a tu watchlist'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Platforms'),
      300,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Platforms'), findsOneWidget);
    expect(find.text('HBO Max'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Incluida'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Francis Ford Coppola'),
      300,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sinopsis'), findsOneWidget);
    expect(find.text('Francis Ford Coppola'), findsOneWidget);
    expect(
      find.text(
        'El patriarca de una familia criminal transfiere el control de su imperio a su hijo menor.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('media_detail_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('For you'), findsOneWidget);
  });

  testWidgets('filters home content by series tab', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'mock-jwt-token'});

    await tester.pumpWidget(const MovieFinderApp(useMockData: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home_filter_series')));
    await tester.pumpAndSettle();

    expect(find.text('Breaking Bad'), findsOneWidget);
    expect(find.text('5 seasons'), findsOneWidget);
  });
}
