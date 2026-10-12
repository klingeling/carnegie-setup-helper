import 'package:flutter/material.dart';

import 'carbon.dart';
import 'departments.dart';
import 'dept_tile.dart';
import 'l10n.dart';

// ---------------------------------------------------------------------------
// 게임 룰 요약 화면 — 근거: 규칙서 6–13쪽 (라운드 진행 7쪽, 이벤트 8쪽,
// 행동 9–12쪽, 활성화·종료·승점 13쪽). UI에는 쪽수를 노출하지 않는다.
// ---------------------------------------------------------------------------

class RulesSummaryScreen extends StatelessWidget {
  const RulesSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s5,
                  ),
                  child: TopBar(
                    onBack: () => Navigator.of(context).pop(),
                    actions: [
                      TopIconButton(
                        icon: Icons.checklist,
                        tooltip: tr('游戏设置清单', 'Setup Checklist'),
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: CarbonColors.background,
                          shape: const RoundedRectangleBorder(),
                          constraints: BoxConstraints(
                            maxWidth: 672,
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.85,
                          ),
                          isScrollControlled: true,
                          builder: (context) => const _SetupGuideSheet(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(CarbonSpacing.s5),
                    children: [
                      Text(
                        tr('规则摘要', 'Rules Summary'),
                        style: CarbonText.heading05,
                      ),
                      const SizedBox(height: CarbonSpacing.s3),
                      Text(
                        tr(
                          '20轮游戏中，玩家经营他们的公司；'
                              '游戏结束时分数最多的玩家获胜。',
                          'Over 20 rounds, players run their Companies; the '
                              'player with the most VP at the end of the game '
                              'wins.',
                        ),
                        style: CarbonText.body02.copyWith(
                          color: CarbonColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: CarbonSpacing.s5),
                      _SectionHeader(
                        title: tr('回合流程', 'Round Sequence'),
                        subtitle: tr('4단계', '4 parts'),
                      ),
                      _card([
                        _numRow(
                          1,
                          tr('타임라인 선택', 'Select Timeline'),
                          tr(
                            '시작 플레이어가 인사·경영·건설·연구개발 중 하나를 골라 타임라인 마커를 놓습니다.',
                            "The first player selects Human Resources, Management, Construction, or R&D and places the Timeline marker to the right of that action's marker.",
                          ),
                        ),
                        _numRow(
                          2,
                          tr('이벤트', 'Events'),
                          tr(
                            '마커가 놓인 칸의 이벤트(수입 또는 기부)가 모든 플레이어에게 발생합니다.',
                            'Placing the Timeline marker triggers an event (income or donation) for all players.',
                          ),
                        ),
                        _numRow(
                          3,
                          tr('부서 사용', 'Use Departments'),
                          tr(
                            '시작 플레이어부터 시계 방향으로, 선택된 행동과 같은 종류의 자기 부서들을 사용합니다. 각 부서는 활성화된 직원 1명당 1번씩 쓸 수 있습니다.',
                            'Starting with the first player and going clockwise, players use their Departments that correspond to the chosen action type. Each Department may be used once for each active employee in it.',
                          ),
                        ),
                        _numRow(
                          4,
                          tr(
                            '직원 활성화·라운드 종료',
                            'Activate Employees & End of Round',
                          ),
                          tr(
                            '사무공간에 표시된 비용을 내고 직원을 활성화한 뒤, 행동 마커를 오른쪽으로 1칸 전진시킵니다.',
                            'Pay the cost indicated on the Workstation to activate employees, then move the action marker one space to the right.',
                          ),
                        ),
                      ]),
                      _SectionHeader(title: tr('이벤트', 'Events')),
                      _card([
                        _iconRow(
                          Icons.payments_outlined,
                          tr('수입 받기', 'Take Income'),
                          tr(
                            '활성화된 파견 지역의 직원을 원하는 만큼 로비로 복귀시키고, 복귀한 직원마다 운송 수입을 받습니다. 1명 이상 복귀시켰다면 지어 둔 프로젝트 수입도 받습니다(라운드당 1번).',
                            'Return 1 or more of your employees from the active Mission area to your Lobby; each one generates transport income. If you returned at least one, you also receive project income from your built projects (once per round).',
                          ),
                        ),
                        _iconRow(
                          Icons.volunteer_activism_outlined,
                          tr('기부하기', 'Make a Donation'),
                          tr(
                            '기부 차트의 빈칸에 디스크를 놓습니다. 첫 기부는 \$5이고, 이후 기부할 때마다 \$5씩 비싸집니다(\$10, \$15…).',
                            'Place a disk on an unoccupied space of the donation chart. Your first donation costs \$5; each subsequent donation costs \$5 more (\$10, \$15…).',
                          ),
                        ),
                      ]),
                      _SectionHeader(title: tr('4가지 행동', 'The Four Actions')),
                      _card([
                        _typeRow(
                          DeptType.hr,
                          tr(
                            '활성화된 인사 직원 1명당 직원 이동 3회(항상 최소 3회). 가로·세로로만 이동하며, 활성화된 직원은 이동하면 비활성화됩니다.',
                            'Each active employee in Human Resources provides 3 moves (always at least 3). Moves are orthogonal only; an active employee that moves becomes inactive.',
                          ),
                        ),
                        _typeRow(
                          DeptType.management,
                          tr(
                            '"상업과 재무"로 돈·상품을 얻고, "전략 기획"으로 새 부서를 조직합니다(큐브 2개, 직원이 있는 빈칸이면 1개).',
                            '"Commerce and Finance" provides money or goods; "Strategic Planning" builds new Departments (2 goods cubes, or 1 on a free space that already contains an employee).',
                          ),
                        ),
                        _typeRow(
                          DeptType.construction,
                          tr(
                            '직원 1명을 파견 보내고 큐브 1~2개를 지불해 그 지역에 프로젝트를 짓습니다. 소도시에 지으면 즉시 운송 수입을 받습니다.',
                            'Send an employee on a Mission and pay 1-2 goods cubes to build a project in that region. Building in certain small cities gives immediate transport income.',
                          ),
                        ),
                        _typeRow(
                          DeptType.rnd,
                          tr(
                            '활성화된 직원마다 연구 점수를 얻어 프로젝트 탭이나 운송 트랙을 전진시킵니다. 남은 점수는 차례가 끝나면 사라집니다.',
                            'Each active employee provides study points to advance project tabs or transport disks. Unused study points are lost at the end of the turn.',
                          ),
                        ),
                      ]),
                      _SectionHeader(title: tr('꼭 기억할 것', 'Remember')),
                      _card([
                        _iconRow(
                          Icons.paid_outlined,
                          null,
                          tr(
                            '직원 활성화 비용은 사무공간 아래 금액이며, 라운드 종료 시에만 활성화할 수 있습니다.',
                            'The activation cost is the amount shown under the Workstation; employees may only be activated at the end of a round.',
                          ),
                        ),
                        _iconRow(
                          Icons.outbound_outlined,
                          null,
                          tr(
                            '파견 중인 직원은 활성화된 것으로 치지 않습니다.',
                            'Employees on Missions are not considered to be active.',
                          ),
                        ),
                        _iconRow(
                          Icons.currency_exchange,
                          null,
                          tr(
                            '상품 큐브는 언제든 개당 \$1에 팔 수 있습니다.',
                            'Goods cubes may be sold to the supply at any time for \$1 each.',
                          ),
                        ),
                        _iconRow(
                          Icons.swap_horiz,
                          null,
                          tr(
                            '(3·4인) 행동 선택 타일로 선택된 것과 다른 행동을 게임당 1번 할 수 있습니다. 쓰지 않으면 종료 시 3점입니다.',
                            '(3-4 players) An Action Choice tile lets you select an action type different from the one chosen, once per game. An unused tile is worth 3 VP at the end of the game.',
                          ),
                        ),
                      ]),
                      _SectionHeader(
                        title: tr('게임 종료 승점', 'End-of-Game Scoring'),
                      ),
                      _card([
                        _iconRow(
                          Icons.person,
                          null,
                          tr(
                            '활성화된 직원 1명당 1점 (파견 나간 직원과 영구 직원은 제외).',
                            '1 VP per active employee (not counting employees on Missions or the permanent employee).',
                          ),
                        ),
                        _iconRow(
                          Icons.grid_view,
                          null,
                          tr(
                            '조직한 부서당 2~3점 (회사판 최상단 행에 놓인 부서는 3점).',
                            "2-3 VP per Department built (3 VP in the Company board's topmost row).",
                          ),
                        ),
                        _iconRow(
                          Icons.trending_up,
                          null,
                          tr(
                            '프로젝트 탭 전진 — 주거 최대 6점 · 상업 9점 · 산업 12점 · 사회 기반시설 15점.',
                            'Project tabs — up to 6 VP for Housing · 9 Commerce · 12 Industry · 15 Public Infrastructure.',
                          ),
                        ),
                        _iconRow(
                          Icons.route_outlined,
                          null,
                          tr(
                            '대도시(뉴욕·시카고·뉴올리언스·샌프란시스코) 연결 최대 36점, 지은 프로젝트마다 도시별 0~3점.',
                            'Connections between major cities (New York, Chicago, New Orleans, San Francisco) up to 36 VP; 0-3 VP per project as shown for each city.',
                          ),
                        ),
                        _iconRow(
                          Icons.volunteer_activism_outlined,
                          null,
                          tr('기부당 최대 12점.', 'Up to 12 VP per donation.'),
                        ),
                      ]),
                      const SizedBox(height: CarbonSpacing.s7),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(List<Widget> rows) {
    return Container(
      margin: const EdgeInsets.only(bottom: CarbonSpacing.s4),
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: CarbonSpacing.s4),
            row,
          ],
        ],
      ),
    );
  }

  Widget _numRow(int n, String title, String text) {
    return _row(
      leading: Container(
        width: 26,
        height: 26,
        color: CarbonColors.layer01,
        alignment: Alignment.center,
        child: Text('$n', style: CarbonText.heading01.copyWith(fontSize: 13)),
      ),
      title: title,
      text: text,
    );
  }

  Widget _iconRow(IconData icon, String? title, String text) {
    return _row(
      leading: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(icon, size: 18, color: CarbonColors.textSecondary),
      ),
      title: title,
      text: text,
    );
  }

  /// 유형 칩 — 모두 2글자 폭(연구개발은 두 줄)이라 자연히 같은 크기가 되고,
  /// 상하좌우 여백을 비슷하게 맞춘다.
  Widget _typeRow(DeptType type, String text) {
    return _row(
      leading: Container(
        // 영문 유형명은 길이가 제각각이라 고정 폭으로 본문 시작선을 맞춘다.
        width: isEn ? 100 : null,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        color: deptTypeColorOf(type),
        child: WordSafeText(
          isEn ? type.en : (type == DeptType.rnd ? '연구\n개발' : type.ko),
          textAlign: TextAlign.center,
          style: CarbonText.label01.copyWith(
            color: CarbonColors.textOnColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: null,
      text: text,
    );
  }

  Widget _row({
    required Widget leading,
    required String? title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        const SizedBox(width: CarbonSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title, style: CarbonText.heading01),
                const SizedBox(height: 2),
              ],
              Text(text, style: CarbonText.body01.copyWith(height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 초기 세팅(게임 준비) 요약 모달 시트 (근거: 규칙서 4–5쪽 1~12번 —
/// UI에는 미표기). 부서 제외(4번)와 중립 디스크(9번)는 이 앱이 대신한다.
class _SetupGuideSheet extends StatelessWidget {
  const _SetupGuideSheet();

  static const _steps = <String>[
    '타임라인 타일 무작위 4개 + 시작·종료 타일',
    '행동 마커 4개를 시작 위치에',
    '부서 타일 제외\n2인 16 · 3인 8 · 4인 4 (이 앱이 대신)',
    '각자: 큐브 4 + \$12 · 회사판 + 탭 4\n직원 10(5 세움, 5 로비, 5 예비)',
    '각자 디스크 배치: 승점 0칸 · 운송 트랙 4곳 첫 칸\n주거·상업·산업 탭 '
        '1개씩',
    '시작 플레이어 정하기',
    '행동 선택 타일\n4인 전원 · 3인 셋째만 · 2인 없음',
    '중립 디스크\n2인 18 · 3인 9 · 4인 생략 (이 앱이 대신)',
    '반시계로: 주거 디스크 1개 + 첫 부서 타일 고르기',
    '시계로: 직원 최대 6회 이동 후 활성화',
  ];

  /// 영문 규칙서 4–5쪽 Game Setup 2~11번 요약.
  static const _stepsEn = <String>[
    '4 random Timeline tiles + Start and End tiles',
    '4 action markers on their starting positions',
    'Remove Department tiles\n2P 16 · 3P 8 · 4P 4 (done by this app)',
    'Each player: 4 goods cubes + \$12 · Company board + 4 project tabs\n'
        '10 employees (5 standing, 5 in Lobby) · 5 set aside',
    'Each player\'s disks: "0" on the score track · first space of the 4 '
        'transportation tracks\n1 each on Housing, Commerce, Industry tabs',
    'Choose the first player',
    'Action Choice tiles\n4P everyone · 3P third player only · 2P none',
    'Neutral disks\n2P 18 · 3P 9 · 4P skip (done by this app)',
    'Counter-clockwise: 1 Housing disk + choose a first Department tile',
    'Clockwise: move employees up to 6 steps, then activate',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CarbonSpacing.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.checklist,
                  size: 20,
                  color: CarbonColors.textSecondary,
                ),
                const SizedBox(width: CarbonSpacing.s3),
                Expanded(
                  child: Text(
                    tr('초기 세팅', 'Setup Checklist'),
                    style: CarbonText.heading03,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(CarbonSpacing.s2),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: CarbonColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: CarbonSpacing.s5),
            for (final (i, step) in (isEn ? _stepsEn : _steps).indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: CarbonSpacing.s4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      color: CarbonColors.layer01,
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: CarbonText.heading01.copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: CarbonSpacing.s4),
                    Expanded(
                      child: Text(
                        step,
                        style: CarbonText.body01.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: CarbonSpacing.s4,
        bottom: CarbonSpacing.s4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: CarbonSpacing.s4,
        vertical: CarbonSpacing.s3,
      ),
      // 흰색 카드 헤더(컬러 바 + 옅은 보더) — 사용자 확정.
      decoration: const BoxDecoration(
        color: CarbonColors.background,
        border: Border(
          left: BorderSide(color: CarbonColors.interactive, width: 4),
          top: BorderSide(color: Color(0xFFE4E6E7)),
          right: BorderSide(color: Color(0xFFE4E6E7)),
          bottom: BorderSide(color: Color(0xFFE4E6E7)),
        ),
      ),
      child: Row(
        children: [
          Text(title, style: CarbonText.heading02),
          if (subtitle != null) ...[
            const SizedBox(width: CarbonSpacing.s3),
            Text(subtitle!, style: CarbonText.helperText01),
          ],
        ],
      ),
    );
  }
}
