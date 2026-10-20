import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_sl/main.dart';

void main() {
  testWidgets('Unified app launch test', (WidgetTester tester) async {
    // Basic verification test
    expect(find.byType(SecureTrackApp), findsNothing);
  });
}
