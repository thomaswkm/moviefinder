import 'package:flutter_test/flutter_test.dart';

import 'package:moviefinder/main.dart';

void main() {
  testWidgets('renders register page', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieFinderApp());

    expect(find.text('¡Unete y encuentra\ntus peliculas!'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });
}
