import 'package:flutter_test/flutter_test.dart';

import 'package:lab_gastos/main.dart';
import 'package:lab_gastos/features/gastos/models/app_settings.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TuAhorroApp(
      initialSettings: AppSettings(),
    ));
    expect(find.text('TuAhorro'), findsWidgets);
  });
}
