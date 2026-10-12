import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:carnegie_departments/departments.dart';
import 'package:carnegie_departments/main.dart';

void main() {
  test('draw removes the correct number of tiles per player count', () {
    for (final entry in removalByPlayerCount.entries) {
      final result = draw(entry.key, Random(42));
      final removed = result.removed.values.fold<int>(0, (sum, c) => sum + c);
      expect(removed, entry.value);
      expect(result.removed.values.every((c) => c >= 1 && c <= 2), isTrue);
      expect(result.totalKept, 32 - entry.value);
    }
  });

  test('drawExpansion picks 4 kinds per type and removes correctly', () {
    for (final entry in removalByPlayerCount.entries) {
      final result = drawExpansion(entry.key, Random(42));
      expect(result.isExpansion, isTrue);

      // 유형마다 정확히 4종씩, 총 16종이 선택된다.
      final selected = result.selectedKinds!;
      expect(selected.length, 16);
      for (final type in DeptType.values) {
        final ofType = allDepartments
            .where((d) => d.type == type && selected.contains(d.number))
            .length;
        expect(ofType, 4);
      }

      // 제외 타일은 모두 선택된 종류에서만 나오고, 수량이 규칙과 일치한다.
      expect(result.removed.keys.every(selected.contains), isTrue);
      final removed = result.removed.values.fold<int>(0, (sum, c) => sum + c);
      expect(removed, entry.value);
      expect(result.removed.values.every((c) => c >= 1 && c <= 2), isTrue);
      expect(result.totalKept, 32 - entry.value);
    }
  });

  testWidgets('setup screen renders and can draw', (tester) async {
    await tester.pumpWidget(const CarnegieApp());
    expect(find.text('游戏设置'), findsOneWidget);

    // 인원 카드를 누르면 바로 결과 화면으로 이동한다.
    await tester.tap(find.text('1-2인'));
    await tester.pumpAndSettle();
    expect(find.text('상자에 되돌릴 타일'), findsWidgets);
    expect(find.text('테이블에 놓을 타일'), findsWidgets);
  });
}
