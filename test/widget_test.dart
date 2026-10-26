import 'package:flutter_test/flutter_test.dart';
import 'package:site_app/main.dart';

void main() {
  testWidgets('Login screen shows SiteApp brand', (WidgetTester tester) async {
    await tester.pumpWidget(const SiteApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('SiteApp'), findsWidgets);
    expect(find.textContaining('Sign in'), findsOneWidget);
  });
}
