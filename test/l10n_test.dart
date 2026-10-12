import 'dart:io';
import 'dart:math';

import 'package:carnegie_departments/departments.dart';
import 'package:carnegie_departments/l10n.dart';
import 'package:carnegie_departments/main.dart';
import 'package:carnegie_departments/new_beginning.dart';
import 'package:carnegie_departments/reference.dart';
import 'package:carnegie_departments/rules.dart';
import 'package:carnegie_departments/setup9.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ByteData> _font(String path) async {
  return ByteData.sublistView(await File(path).readAsBytes());
}

/// 한영 전환 검증. 영문 문구는 한글보다 길어서, 폰 폭에서 오버플로 없이
/// 렌더링되는지(오버플로 시 flutter_test가 예외로 실패) 화면별로 확인한다.
void main() {
  setUpAll(() async {
    final loader = FontLoader('SUIT');
    for (final weight in ['Light', 'Regular', 'Bold', 'ExtraBold']) {
      loader.addFont(_font('assets/fonts/SUIT-$weight.otf'));
    }
    await loader.load();
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => appLang.value = AppLang.ko);

  group('시작 언어', () {
    testWidgets('저장값이 없으면 기기 언어: 한국어 → KO', (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      await loadAppLang();
      expect(appLang.value, AppLang.ko);
    });

    testWidgets('저장값이 없으면 기기 언어: 그 외 → EN', (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      await loadAppLang();
      expect(appLang.value, AppLang.en);

      tester.platformDispatcher.localeTestValue = const Locale('ja', 'JP');
      await loadAppLang();
      expect(appLang.value, AppLang.en);
    });

    testWidgets('저장값이 없으면 늦게 전달된 기기 언어를 따라간다 (안드로이드)', (tester) async {
      // main() 시점에는 아직 로캘이 없어 영어로 시작했다가,
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      await loadAppLang();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'SUIT'),
          home: const SetupScreen(),
        ),
      );
      expect(find.text('Game Setup'), findsOneWidget);

      // 엔진이 기기 로캘(ko-KR)을 전달하면 첫 화면이 한국어로 바뀐다.
      tester.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
      await tester.pumpAndSettle();
      expect(appLang.value, AppLang.ko);
      expect(find.text('게임 준비'), findsOneWidget);

      // 사용자가 스위치로 고른 뒤에는 기기 언어가 바뀌어도 따라가지 않는다.
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      tester.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
      tester.platformDispatcher.localeTestValue = const Locale('fr', 'FR');
      tester.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
      await tester.pumpAndSettle();
      expect(appLang.value, AppLang.en);
      expect(find.text('Game Setup'), findsOneWidget);
    });

    testWidgets('스위치로 바꾼 값은 저장되어 기기 언어보다 우선한다', (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      await setAppLang(AppLang.en);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_lang'), 'en');

      appLang.value = AppLang.ko; // 앱 재시작 흉내
      await loadAppLang();
      expect(appLang.value, AppLang.en);
    });
  });

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

  Future<void> scrollToEnd(WidgetTester tester, int times) async {
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < times; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('첫 화면 스위치로 한국어 ↔ 영어가 전환된다', (tester) async {
    await pumpPhone(tester, const SetupScreen());
    expect(find.text('게임 준비'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Game Setup'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_lang'), 'en');
    expect(find.text('1-2 Players'), findsOneWidget);

    // 영어 상태로 들어간 결과 화면도 영어로 표시된다.
    await tester.tap(find.text('1-2 Players'));
    await tester.pumpAndSettle();
    expect(find.text('Return to Box'), findsOneWidget);
    expect(find.text('Place on Table'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('KO'));
    await tester.pumpAndSettle();
    expect(find.text('게임 준비'), findsOneWidget);
  });

  group('영어 모드 화면', () {
    setUp(() => appLang.value = AppLang.en);

    testWidgets('게임 준비: 확장 토글', (tester) async {
      await pumpPhone(tester, const SetupScreen());
      await tester.tap(find.text('With Expansion'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3 Players'));
      await tester.pumpAndSettle();
      expect(find.text('Departments Used'), findsOneWidget);
      expect(find.text('Choose Departments'), findsOneWidget);
    });

    for (final players in [2, 3, 4]) {
      testWidgets('$players인 결과 화면 요약·상세', (tester) async {
        await pumpPhone(tester, ResultScreen(result: draw(players, Random(1))));
        expect(find.text('Remove Tiles'), findsOneWidget);
        await tester.tap(find.text('Details'));
        await tester.pump();
        await scrollToEnd(tester, 40);
      });

      testWidgets('확장 $players인 결과 화면 요약·상세', (tester) async {
        await pumpPhone(
          tester,
          ResultScreen(result: drawExpansion(players, Random(1))),
        );
        await tester.tap(find.text('Details'));
        await tester.pump();
        await scrollToEnd(tester, 60);
      });
    }

    testWidgets('상세 시트에 영문 규칙이 뜬다', (tester) async {
      await pumpPhone(tester, ResultScreen(result: draw(3, Random(42))));
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Training and Partnerships').first);
      await tester.pumpAndSettle();
      expect(find.text('Rules'), findsOneWidget);
      expect(find.text(departments.first.ruleEn), findsOneWidget);
    });

    testWidgets('중립 디스크 탭 (1-2인)', (tester) async {
      await pumpPhone(tester, ResultScreen(result: draw(2, Random(42))));
      await tester.tap(find.text('Disks'));
      await tester.pumpAndSettle();
      expect(find.text('18 Neutral Disks'), findsOneWidget);
      await scrollToEnd(tester, 10);
    });

    testWidgets('중립 디스크 탭 (4인)', (tester) async {
      await pumpPhone(tester, ResultScreen(result: draw(4, Random(42))));
      await tester.tap(find.text('Disks'));
      await tester.pumpAndSettle();
      expect(find.text('No Neutral Disks Used'), findsOneWidget);
    });

    testWidgets('1인 도우미 탭', (tester) async {
      await pumpPhone(tester, ResultScreen(result: draw(2, Random(42))));
      await tester.tap(find.text('Solo'));
      await tester.pumpAndSettle();
      expect(find.text('Round Sequence'), findsOneWidget);
      await scrollToEnd(tester, 10);
    });

    testWidgets('게임 룰 요약 + 초기 세팅 시트', (tester) async {
      await pumpPhone(tester, const RulesSummaryScreen());
      await tester.tap(find.byIcon(Icons.checklist).first);
      await tester.pumpAndSettle();
      expect(find.text('Setup Checklist'), findsOneWidget);
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      await scrollToEnd(tester, 10);
      expect(find.text('End-of-Game Scoring'), findsOneWidget);
    });

    testWidgets('부서 도감 기본판·확장 + 조직 방법 시트', (tester) async {
      await pumpPhone(tester, const DeptCatalogScreen());
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();
      expect(find.text('Building Departments'), findsOneWidget);
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      await scrollToEnd(tester, 30);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 20000));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expansion'));
      await tester.pumpAndSettle();
      expect(find.text('Human Resources Administration'), findsOneWidget);
      await scrollToEnd(tester, 30);
    });

    testWidgets('아이콘 참조표', (tester) async {
      await pumpPhone(tester, const IconReferenceScreen());
      expect(find.text('Icon Reference'), findsOneWidget);
      await scrollToEnd(tester, 10);
    });

    testWidgets('새로운 시작 계산기', (tester) async {
      await pumpPhone(tester, const NewBeginningScreen());
      expect(find.text('Remaining \$39'), findsOneWidget);
      await tester.tap(find.text('6 cubes'));
      await tester.pumpAndSettle();
      expect(find.text('Remaining \$27'), findsOneWidget);
    });
  });

  for (final lang in AppLang.values) {
    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('부서 도감: 기본판↔확장 전환 시 아래가 흔들리지 않는다 '
          '(${lang.name}, ${width.toInt()}px)', (tester) async {
        appLang.value = lang;
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = Size(width, 844);
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
        });
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'SUIT'),
            home: const DeptCatalogScreen(),
          ),
        );
        await tester.pumpAndSettle();
        final header = find.text(DeptType.hr.label).first;
        final before = tester.getTopLeft(header);
        await tester.tap(find.text(tr('扩展', 'Expansion')));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(header), before);
        await tester.tap(find.text(tr('基础', 'Base')));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(header), before);
      });
    }
  }

  test('모든 부서·도시에 영문 데이터가 있다', () {
    for (final d in allDepartments) {
      expect(d.ruleEn, isNotEmpty, reason: 'dept ${d.number}');
    }
    for (final region in cityRegions.keys) {
      expect(regionNamesEn[region], isNotNull, reason: region);
      for (final city in cityRegions[region]!) {
        expect(cityNamesEn[city], isNotNull, reason: city);
      }
    }
    for (final card in setupCards) {
      expect(donationRowsEn[card.donation[0]], isNotNull);
      for (final city in card.cities) {
        expect(cityNamesEn[city], isNotNull, reason: city);
      }
    }
  });
}
