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
                        subtitle: tr('4个部分', '4 parts'),
                      ),
                      _card([
                        _numRow(
                          1,
                          tr('选择时间轴', 'Select Timeline'),
                          tr(
                            '起始玩家选择自己想使用哪个时间轴：人力资源、管理、建设或研发，然后将时间轴标记(齿轮)直接放到那一行的行动标记的右边。',
                            "The first player selects Human Resources, Management, Construction, or R&D and places the Timeline marker to the right of that action's marker.",
                          ),
                        ),
                        _numRow(
                          2,
                          tr('活动', 'Events'),
                          tr(
                            '放置时间轴标记将会为所有玩家触发1个活动(收入或捐赠)。',
                            'Placing the Timeline marker triggers an event (income or donation) for all players.',
                          ),
                        ),
                        _numRow(
                          3,
                          tr('使用部门', 'Use Departments'),
                          tr(
                            '起始玩家可以按任意顺序使用所选行动类型的所有部门。然后，按顺时针的顺序，其他玩家也可以使用各自相对应类型的所有部门。每有1名激活的员工，部门就可以使用1次。',
                            'Starting with the first player and going clockwise, players use their Departments that correspond to the chosen action type. Each Department may be used once for each active employee in it.',
                          ),
                        ),
                        _numRow(
                          4,
                          tr(
                            '激活员工&一轮结束',
                            'Activate Employees & End of Round',
                          ),
                          tr(
                            '玩家可以支付员工当前所在部门空闲工位下方的费用激活。最后，所选时间轴上的行动标记向右移动一格。',
                            'Pay the cost indicated on the Workstation to activate employees, then move the action marker one space to the right.',
                          ),
                        ),
                      ]),
                      _SectionHeader(title: tr('活动', 'Events')),
                      _card([
                        _iconRow(
                          Icons.payments_outlined,
                          tr('获得收入', 'Take Income'),
                          tr(
                            '从被激活的任务区收回1名或多名员工到自己的公司大厅；每名收回的员工都会引发运输收入。然后，每位从被激活的任务区收回了员工的玩家，都可以依据各自在游戏图版任意位置建造的每个项目来获得项目收入(每轮一次)。',
                            'Return 1 or more of your employees from the active Mission area to your Lobby; each one generates transport income. If you returned at least one, you also receive project income from your built projects (once per round).',
                          ),
                        ),
                        _iconRow(
                          Icons.volunteer_activism_outlined,
                          tr('进行1次捐赠', 'Make a Donation'),
                          tr(
                            '把自己的1个圆片放在捐赠表上1个未被占据的空格上。首次捐赠需要支付\$5，该玩家之后的每次捐赠都将增加\$5(第2次捐赠是\$10，第 3 次捐赠是\$15，以此类推……)。',
                            'Place a disk on an unoccupied space of the donation chart. Your first donation costs \$5; each subsequent donation costs \$5 more (\$10, \$15…).',
                          ),
                        ),
                      ]),
                      _SectionHeader(title: tr('4种行动', 'The Four Actions')),
                      _card([
                        _typeRow(
                          DeptType.hr,
                          tr(
                            '每名激活的员工提供3步移动(至少有3步移动可用)。必须是横着或竖着移动；移动1名激活的员工会使他变回未激活状态。',
                            'Each active employee in Human Resources provides 3 moves (always at least 3). Moves are orthogonal only; an active employee that moves becomes inactive.',
                          ),
                        ),
                        _typeRow(
                          DeptType.management,
                          tr(
                            '“商业和金融”提供货物或钱；“战略规划”可以建造新部门(2个货物方块，或者1个货物方块在至少1名员工的空格上)。',
                            '"Commerce and Finance" provides money or goods; "Strategic Planning" builds new Departments (2 goods cubes, or 1 on a free space that already contains an employee).',
                          ),
                        ),
                        _typeRow(
                          DeptType.construction,
                          tr(
                            '派出一名员工执行任务，并支付1-2个货物方块在该区域建造一个项目。在某些小城市上建造可以立刻获得运输收入。',
                            'Send an employee on a Mission and pay 1-2 goods cubes to build a project in that region. Building in certain small cities gives immediate transport income.',
                          ),
                        ),
                        _typeRow(
                          DeptType.rnd,
                          tr(
                            '每名激活的员工都能为自己提供研究点，可以提升运输网络，开发新的建设项目。玩家回合结束时未用完的研究点将清零。',
                            'Each active employee provides study points to advance project tabs or transport disks. Unused study points are lost at the end of the turn.',
                          ),
                        ),
                      ]),
                      _SectionHeader(title: tr('注意', 'Remember')),
                      _card([
                        _iconRow(
                          Icons.paid_outlined,
                          null,
                          tr(
                            '部门工位下的\$数值为激活费用；员工只能在一轮结束时被激活。',
                            'The activation cost is the amount shown under the Workstation; employees may only be activated at the end of a round.',
                          ),
                        ),
                        _iconRow(
                          Icons.outbound_outlined,
                          null,
                          tr(
                            '在任务区的员工不被视为激活的员工。',
                            'Employees on Missions are not considered to be active.',
                          ),
                        ),
                        _iconRow(
                          Icons.currency_exchange,
                          null,
                          tr(
                            '玩家可以在任何时候把自己的货物方块放回公共供应堆中，每放回1个可以换\$1。',
                            'Goods cubes may be sold to the supply at any time for \$1 each.',
                          ),
                        ),
                        _iconRow(
                          Icons.swap_horiz,
                          null,
                          tr(
                            '(3-4人游戏)每局游戏一次，可以选择1个不同于起始玩家所选的行动类型。在游戏结束时，未使用的行动选择板块价值3分。',
                            '(3-4 players) An Action Choice tile lets you select an action type different from the one chosen, once per game. An unused tile is worth 3 VP at the end of the game.',
                          ),
                        ),
                      ]),
                      _SectionHeader(
                        title: tr('终局计分', 'End-of-Game Scoring'),
                      ),
                      _card([
                        _iconRow(
                          Icons.person,
                          null,
                          tr(
                            '每名激活的员工1分。(执行任务和初始人力资源部门的永久员工不计算在内)。',
                            '1 VP per active employee (not counting employees on Missions or the permanent employee).',
                          ),
                        ),
                        _iconRow(
                          Icons.grid_view,
                          null,
                          tr(
                            '游戏过程中建造的每个部门2-3分(每个建造在公司顶层的部门价值3分)。',
                            "2-3 VP per Department built (3 VP in the Company board's topmost row).",
                          ),
                        ),
                        _iconRow(
                          Icons.trending_up,
                          null,
                          tr(
                            '项目标签的分数 — 住宅最多6分 · 商业最多9分 · 工业最多12分 · 公共设施最多15分。',
                            'Project tabs — up to 6 VP for Housing · 9 Commerce · 12 Industry · 15 Public Infrastructure.',
                          ),
                        ),
                        _iconRow(
                          Icons.route_outlined,
                          null,
                          tr(
                            '来自大城市(纽约、芝加哥、新奥尔良、旧金山)之间的连接分数，最多36分；每个建造在城市的建设项目0-3分。',
                            'Connections between major cities (New York, Chicago, New Orleans, San Francisco) up to 36 VP; 0-3 VP per project as shown for each city.',
                          ),
                        ),
                        _iconRow(
                          Icons.volunteer_activism_outlined,
                          null,
                          tr('每项捐赠最多12分。', 'Up to 12 VP per donation.'),
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
          isEn ? type.en : (type == DeptType.hr ? '人力\n资源' : type.zh),
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

/// 초기 세팅(游戏设置) 요약 모달 시트 (근거: 규칙서 4–5쪽 1~12번 —
/// UI에는 미표기). 부서 제외(4번)와 중립 디스크(9번)는 이 앱이 대신한다.
class _SetupGuideSheet extends StatelessWidget {
  const _SetupGuideSheet();

  static const _steps = <String>[
    '4个随机时间轴板块 + 起点和终点板块',
    '4个行动标记放到对应起点位置',
    '移除部门板块\n2人游戏：16个 · 3人游戏：8个 · 4人游戏：4个(由此APP设置)',
    '每位玩家: 4个货物方块 + \$12 · 公司图版 + 4个项目标签\n10名员工(5名站立，5名在大厅) · 5名放在旁边',
    '每位玩家的圆片：1个放到计分轨道“0” · 4个区域的运输轨道的第一格各放1个\n项目标签的3个空格上(住宅、商业和工业)各放1个',
    '选择起始玩家',
    '行动选择板块\n4人游戏：每人1个 · 3人游戏：第3顺位获得1个 · 2人游戏：无',
    '中立圆片\n2人游戏：18个 · 3人游戏：9个 · 4人游戏：跳过(由此APP设置)',
    '逆时针：1个住宅圆片 + 选择第1个部门板块',
    '顺时针：最多6步员工移动，然后激活',
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
