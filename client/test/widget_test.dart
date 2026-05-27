import 'package:duanju_client/app/duanju_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows drama list title', (tester) async {
    await tester.pumpWidget(const DuanjuApp());
    await tester.pumpAndSettle();

    expect(find.text('短剧互动客户端'), findsOneWidget);
    expect(find.text('北派寻宝笔记'), findsOneWidget);
  });
}
