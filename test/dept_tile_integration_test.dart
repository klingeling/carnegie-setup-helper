import 'dart:io';
import 'dart:math';

import 'package:carnegie_departments/departments.dart';
import 'package:carnegie_departments/dept_tile.dart';
import 'package:carnegie_departments/main.dart';
import 'package:carnegie_departments/new_beginning.dart';
import 'package:carnegie_departments/reference.dart';
import 'package:carnegie_departments/rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ByteData> _font(String path) async {
  return ByteData.sublistView(await File(path).readAsBytes());
}

/// 새 타일이 들어간 화면들의 자체 검증 스위트.
/// 오버플로가 생기면 flutter_test가 예외로 실패시키므로, 렌더링만 통과해도
/// 레이아웃 파손 여부가 검증된다. (실제 폰트로 측정하도록 SUIT를 로드한다.)
void main() {
  setUpAll(() async {
    final loader = FontLoader('SUIT');
    for (final weight in ['Thin', 'Light', 'Regular', 'Bold', 'ExtraBold']) {
      loader.addFont(_font('assets/fonts/SUIT-$weight.otf'));
    }
    await loader.load();
  });

  // 폰 크기(390x844) 기준으로 검증한다.
  Future<void> pumpPhone(WidgetTester tester, Widget home) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'SUIT'),
        debugShowCheckedModeBanner: false,
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final players in [2, 3, 4]) {
    testWidgets('$players인 결과 화면: 타일 그리드가 오버플로 없이 렌더링된다', (tester) async {
      await pumpPhone(tester, ResultScreen(result: draw(players, Random(42))));
      expect(find.byType(DeptTile), findsWidgets);
    });
  }

  testWidgets('결과 화면: 타일 탭 → 상세 시트에 큰 타일이 뜬다', (tester) async {
    await pumpPhone(tester, ResultScreen(result: draw(3, Random(42))));
    await tester.tap(find.byType(DeptTile).first, warnIfMissed: false);
    await tester.pumpAndSettle();
    // 그리드 타일들 + 시트의 풀사이즈 타일.
    expect(find.byType(DeptTile), findsWidgets);
    expect(find.text('규칙'), findsOneWidget);
  });

  testWidgets('부서 도감: 기본판·확장 탭이 오버플로 없이 렌더링된다', (tester) async {
    await pumpPhone(tester, const DeptCatalogScreen());
    // 끝까지 스크롤해서 지연 생성 항목까지 전부 레이아웃시킨다.
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 30; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byType(DeptEmblem), findsWidgets);

    // 확장 탭으로 전환하면 확장 부서가 표시된다.
    await tester.drag(scrollable, const Offset(0, 20000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확장'));
    await tester.pumpAndSettle();
    expect(find.text('인사 행정'), findsOneWidget);
    for (var i = 0; i < 30; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byType(DeptEmblem), findsWidgets);
  });

  for (final players in [2, 3, 4]) {
    testWidgets('확장 $players인 결과 화면: 요약이 오버플로 없이 렌더링된다', (tester) async {
      await pumpPhone(
        tester,
        ResultScreen(result: drawExpansion(players, Random(42))),
      );
      expect(find.text('사용할 종류'), findsOneWidget);
      expect(find.text('종류 고르기'), findsOneWidget);
    });
  }

  testWidgets('확장 결과 화면: 상세 전환 시 32종이 유형별로 렌더링된다', (tester) async {
    await pumpPhone(tester, ResultScreen(result: drawExpansion(3, Random(42))));
    await tester.tap(find.text('상세'));
    await tester.pump();
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 60; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byType(DeptTile), findsWidgets);
  });

  testWidgets('游戏设置: 확장 토글 후 뽑으면 확장 요약이 표시된다', (tester) async {
    await pumpPhone(tester, const SetupScreen());
    await tester.tap(find.text('확장 포함'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3인'));
    await tester.pumpAndSettle();
    expect(find.text('사용할 종류'), findsOneWidget);
  });

  testWidgets('새로운 시작 계산기: 선택에 따라 예산이 갱신된다', (tester) async {
    await pumpPhone(tester, const NewBeginningScreen());
    // 기본값: 큐브 2개($6) + 이동 4회($5) = 지출 $11.
    expect(find.text('남는 예산 \$39'), findsOneWidget);
    await tester.tap(find.text('6개'));
    await tester.pumpAndSettle();
    // 큐브 6개($18)로 변경 → 지출 $23.
    expect(find.text('남는 예산 \$27'), findsOneWidget);
  });

  testWidgets('1-2인: 중립 디스크 탭에 18개가 표시된다', (tester) async {
    await pumpPhone(tester, ResultScreen(result: draw(2, Random(42))));
    await tester.tap(find.text('중립 디스크'));
    await tester.pumpAndSettle();
    expect(find.text('중립 디스크 18개'), findsOneWidget);
  });

  testWidgets('3인: 중립 디스크 탭에 9개가 표시된다', (tester) async {
    await pumpPhone(tester, ResultScreen(result: draw(3, Random(42))));
    await tester.tap(find.text('중립 디스크'));
    await tester.pumpAndSettle();
    expect(find.text('중립 디스크 9개'), findsOneWidget);
  });

  testWidgets('4인: 중립 디스크 탭에 사용하지 않음 안내가 표시된다', (tester) async {
    await pumpPhone(tester, ResultScreen(result: draw(4, Random(42))));
    await tester.tap(find.text('중립 디스크'));
    await tester.pumpAndSettle();
    expect(find.text('중립 디스크를 사용하지 않습니다'), findsOneWidget);
  });

  testWidgets('1-2인: 1인 도우미 탭이 열린다', (tester) async {
    await pumpPhone(tester, ResultScreen(result: draw(2, Random(42))));
    await tester.tap(find.text('1인 도우미'));
    await tester.pumpAndSettle();
    expect(find.text('라운드 진행'), findsOneWidget);
  });

  testWidgets('아이콘 참조표 화면이 오버플로 없이 렌더링된다', (tester) async {
    await pumpPhone(tester, const IconReferenceScreen());
    expect(tester.takeException(), isNull);
  });

  testWidgets('게임 룰 요약 화면이 오버플로 없이 렌더링된다', (tester) async {
    await pumpPhone(tester, const RulesSummaryScreen());
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 10; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    // 끝까지 스크롤했으므로 마지막 섹션이 보여야 한다.
    expect(find.text('게임 종료 승점'), findsOneWidget);
  });

  testWidgets('게임 룰 요약: 체크리스트 버튼 → 초기 세팅 시트가 열린다', (tester) async {
    await pumpPhone(tester, const RulesSummaryScreen());
    await tester.tap(find.byIcon(Icons.checklist).first);
    await tester.pumpAndSettle();
    expect(find.text('초기 세팅'), findsOneWidget);
  });

  testWidgets('부서 도감: info 버튼 → 부서 조직 방법 시트가 열린다', (tester) async {
    await pumpPhone(tester, const DeptCatalogScreen());
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('부서 조직 방법'), findsOneWidget);
  });

  testWidgets('좁은 폭(320px)에서도 컴팩트 타일이 오버플로 없이 렌더링된다', (tester) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(320 * 2, 700 * 2);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'SUIT'),
        home: Scaffold(
          body: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: deptTileAspect,
            children: [for (final d in departments) DeptTile(dept: d)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DeptTile), findsWidgets);
  });
}
