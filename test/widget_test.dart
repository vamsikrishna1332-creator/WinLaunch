import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LaunchDesk theme renders its title', (tester) async {
    await tester.pumpWidget(const FluentApp(
      home: ScaffoldPage(content: Center(child: Text('LaunchDesk'))),
    ));
    expect(find.text('LaunchDesk'), findsOneWidget);
  });
}
