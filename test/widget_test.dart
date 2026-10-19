import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokmotorn/main.dart';

void main() {
  test('home URL is punycode of sökmotorn.se', () {
    expect(Uri.parse(kHomeUrl).host, 'xn--skmotorn-n4a.se');
  });

  test('internal host detection', () {
    expect(isInternalHost('xn--skmotorn-n4a.se'), isTrue);
    expect(isInternalHost('www.xn--skmotorn-n4a.se'), isTrue);
    expect(isInternalHost('google.com'), isFalse);
  });

  testWidgets('app builds with title', (tester) async {
    await tester.pumpWidget(const MyApp(home: Text('stub')));
    expect(find.text('stub'), findsOneWidget);
  });
}
