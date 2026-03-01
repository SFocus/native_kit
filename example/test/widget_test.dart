import 'package:flutter_test/flutter_test.dart';
import 'package:native_kit_example/main.dart';

void main() {
  testWidgets('NativeKit example app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('NativeKit Example'), findsOneWidget);
    expect(find.text('Home Page'), findsOneWidget);
  });
}
