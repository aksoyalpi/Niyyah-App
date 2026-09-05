import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:niyyah_app/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app shell shows three tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NiyyahApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Niyyah'), findsOneWidget);
    expect(find.text('Block Apps'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
