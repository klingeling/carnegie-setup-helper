import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'carbon.dart';
import 'l10n.dart';

// ---------------------------------------------------------------------------
// 확장 #1 "새로운 시작" 입찰 시트 개인 계산기 (확장 룰북 1쪽).
// 실물 시트의 다섯 줄을 그대로 옮겼다: 선 플레이어 입찰(자유 금액) ·
// 상품 큐브 · 로비 직원 · 승점 · 준비 이동. 총합(입찰 포함)은 $50를 넘을 수
// 없고, 시작 자금 = $50 − (2~5행 순비용), 선 플레이어가 되면 입찰액도 뺀다.
// ---------------------------------------------------------------------------

/// 시트 한 줄의 선택지: (표시 값, 영문 표시 값, 비용 — 음수는 돈을 받음).
typedef _Option = (String, String, int);

/// 선택지의 현재 언어 표시 값.
String _optionLabel(_Option o) => tr(o.$1, o.$2);

/// 줄 이름의 영문은 실물 시트 표기(1st Player Auction, Goods Cubes,
/// Workers in Lobby, Victory Points, Setup Moves)를 따른다.
class _Line {
  const _Line(
    this.title,
    this.titleEn,
    this.subtitle,
    this.subtitleEn,
    this.icon,
    this.options,
  );

  final String title;
  final String titleEn;
  final String subtitle;
  final String subtitleEn;
  final IconData icon;
  final List<_Option> options;
}

const _lines = <_Line>[
  _Line(
    '货物方块',
    'Goods Cubes',
    '游戏开始时拥有的货物方块',
    'Goods cubes you start the game with',
    Icons.inventory_2_outlined,
    [
      ('2个', '2 cubes', 6),
      ('3个', '3 cubes', 9),
      ('4个', '4 cubes', 12),
      ('5个', '5 cubes', 15),
      ('6个', '6 cubes', 18),
    ],
  ),
  _Line(
    '大厅中的员工',
    'Workers in Lobby',
    '你大厅中未激活的员工，以及额外5名已激活的员工',
    'Inactive employees in your Lobby, in addition to the 5 active ones',
    Icons.person_outline,
    [
      ('3名', '3', 0),
      ('4名', '4', 8),
      ('5名', '5', 16),
      ('6名', '6', 24),
      ('7名', '7', 32),
    ],
  ),
  _Line(
    '胜利分数',
    'Victory Points',
    '调整你的初始分数 — 可以把钱换成分，反之亦然',
    'Adjust your starting score — giving up VP earns you money',
    Icons.star_outline,
    [
      ('-6分', '-6 VP', -12),
      ('-3分', '-3 VP', -6),
      ('0分', '0 VP', 0),
      ('+3分', '+3 VP', 6),
      ('+6分', '+6 VP', 12),
    ],
  ),
  _Line(
    '员工移动步数',
    'Setup Moves',
    '员工在最后一步设置中可以移动多少格',
    'Employee moves in the last step of setup',
    Icons.directions_walk,
    [
      ('4步', '4 moves', 5),
      ('5步', '5 moves', 8),
      ('6步', '6 moves', 10),
      ('8步', '8 moves', 15),
      ('10步', '10 moves', 20),
    ],
  ),
];

/// 예산 한도.
const _budget = 50;

class NewBeginningScreen extends StatefulWidget {
  const NewBeginningScreen({super.key});

  @override
  State<NewBeginningScreen> createState() => _NewBeginningScreenState();
}

class _NewBeginningScreenState extends State<NewBeginningScreen> {
  /// 줄별 선택 인덱스 (기본값: 각 줄의 최저가 선택지).
  final _selected = <int>[2, 2, 2, 2];
  final _bidController = TextEditingController();

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  int get _bid => int.tryParse(_bidController.text) ?? 0;

  /// 2~5행 순비용 (승점 줄은 음수일 수 있음).
  int get _spent {
    var sum = 0;
    for (final (i, line) in _lines.indexed) {
      sum += line.options[_selected[i]].$3;
    }
    return sum;
  }

  bool get _overBudget => _spent + _bid > _budget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s5,
                  ),
                  child: TopBar(onBack: () => Navigator.of(context).pop()),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(CarbonSpacing.s5),
                    children: [
                      Text(
                        tr('新开始', 'A New Beginning'),
                        style: CarbonText.heading05,
                      ),
                      const SizedBox(height: CarbonSpacing.s3),
                      Text(
                        tr(
                          '在总花费不超过\$$_budget的情况下选择自己的初始资源。'
                              '每位玩家秘密地记下出价纸的每项选择的花费，然后同时展示。'
                              '起始玩家出价最高的成为起始玩家。',
                          'Choose your starting resources within a \$$_budget '
                              'limit. Each player secretly chooses one option for '
                              'each line, then all reveal simultaneously. The high '
                              'bidder becomes the first player.',
                        ),
                        style: CarbonText.body01.copyWith(
                          color: CarbonColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: CarbonSpacing.s6),
                      _sectionHeader(
                        tr('起始玩家出价', '1st Player Auction'),
                        tr(
                          '仅起始玩家支付出价金额',
                          'Only the first player pays their bid',
                        ),
                        Icons.gavel_outlined,
                      ),
                      const SizedBox(height: CarbonSpacing.s4),
                      _bidField(),
                      for (final (i, line) in _lines.indexed) ...[
                        const SizedBox(height: CarbonSpacing.s6),
                        _sectionHeader(
                          tr(line.title, line.titleEn),
                          tr(line.subtitle, line.subtitleEn),
                          line.icon,
                        ),
                        const SizedBox(height: CarbonSpacing.s4),
                        _optionRows(i, line),
                      ],
                      const SizedBox(height: CarbonSpacing.s6),
                      _summaryCard(),
                      const SizedBox(height: CarbonSpacing.s8),
                    ],
                  ),
                ),
                _bottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 선택지 5개를 두 줄(3개 + 2개)로 배치한다 (사용자 확정 레이아웃).
  /// 모든 칸은 3열 기준의 같은 폭 — 아랫줄 2개도 윗줄과 동일한 크기.
  /// 5 个选项排成一行，等宽。
  Widget _optionRows(int lineIndex, _Line line) {
    Widget chip(int j, double width) => SizedBox(
      width: width,
      child: _OptionChip(
        label: _optionLabel(line.options[j]),
        cost: line.options[j].$3,
        selected: _selected[lineIndex] == j,
        onTap: () => setState(() => _selected[lineIndex] = j),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 4 * CarbonSpacing.s3) / 5;
        return Row(
          children: [
            for (var j = 0; j < line.options.length; j++) ...[
              if (j > 0) const SizedBox(width: CarbonSpacing.s3),
              chip(j, width),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: CarbonColors.textPrimary),
              const SizedBox(width: CarbonSpacing.s3),
              Expanded(child: Text(title, style: CarbonText.heading02)),
            ],
          ),
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subtitle, style: CarbonText.helperText01),
            ),
        ],
      ),
    );
  }

  Widget _bidField() {
    return TextField(
      controller: _bidController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      style: CarbonText.body02,
      decoration: const InputDecoration(
        filled: true,
        fillColor: CarbonColors.field01,
        prefixText: '\$ ',
        hintText: '0',
        hintStyle: TextStyle(color: CarbonColors.textHelper),
        contentPadding: EdgeInsets.symmetric(
          horizontal: CarbonSpacing.s5,
          vertical: CarbonSpacing.s4,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: CarbonColors.borderStrong),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CarbonColors.borderStrong),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CarbonColors.interactive, width: 2),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _summaryCard() {
    final goods = _optionLabel(_lines[0].options[_selected[0]]);
    final workers = _optionLabel(_lines[1].options[_selected[1]]);
    final vp = _optionLabel(_lines[2].options[_selected[2]]);
    final moves = _optionLabel(_lines[3].options[_selected[3]]);
    final rows = <(String, String)>[
      (tr('货物方块', 'Goods cubes'), goods),
      (
        tr('员工', 'Employees'),
        tr('5名激活的 + $workers大厅中的员工', '5 active + $workers in Lobby'),
      ),
      (tr('初始分数', 'Starting VP'), vp),
      (tr('员工移动步数', 'Setup moves'), moves),
      (
        tr('初始资金(非起始玩家)', 'Starting money (not first player)'),
        '\$${_budget - _spent}',
      ),
      (
        tr('初始资金(起始玩家)', 'Starting money (first player)'),
        '\$${_budget - _spent - _bid}',
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CarbonSpacing.s5,
              vertical: CarbonSpacing.s3,
            ),
            color: CarbonColors.layer01,
            child: Text(
              tr('初始摘要', 'Starting Summary'),
              style: CarbonText.heading01.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          for (final (i, row) in rows.indexed) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: CarbonSpacing.s5,
                color: Color(0xFFE4E6E7),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CarbonSpacing.s5,
                vertical: CarbonSpacing.s4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: WordSafeText(row.$1, style: CarbonText.body01),
                  ),
                  Text(
                    row.$2,
                    style: CarbonText.body01.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final remain = _budget - _spent - _bid;
    return Container(
      decoration: const BoxDecoration(
        color: CarbonColors.background,
        border: Border(top: BorderSide(color: CarbonColors.borderSubtle)),
      ),
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_overBudget) ...[
            Container(
              color: CarbonColors.notifErrorBg,
              padding: const EdgeInsets.symmetric(
                horizontal: CarbonSpacing.s4,
                vertical: CarbonSpacing.s3,
              ),
              child: Text(
                tr(
                  '总花费超出限额 — 包括你的出价在内，不得超出\$$_budget',
                  'Over the limit — the total cost, including your bid, may '
                      'not exceed \$$_budget',
                ),
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.supportError,
                ),
              ),
            ),
            const SizedBox(height: CarbonSpacing.s3),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  tr(
                    '花费\$$_spent · 出价\$$_bid',
                    'Spent \$$_spent · Bid \$$_bid',
                  ),
                  style: CarbonText.body01.copyWith(
                    color: CarbonColors.textSecondary,
                  ),
                ),
              ),
              Text(
                tr('剩余\$$remain', 'Remaining \$$remain'),
                style: CarbonText.heading02.copyWith(
                  color: _overBudget
                      ? CarbonColors.supportError
                      : CarbonColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 시트 선택지 칩: 값 + 비용, 각진 모서리, 선택 시 인터랙티브 보더.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.cost,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int cost;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final costLabel = switch (cost) {
      0 => tr('0', 'Free'),
      < 0 => '+\$${-cost}',
      _ => '\$$cost',
    };
    return Material(
      color: selected ? CarbonColors.interactiveTint : CarbonColors.background,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected
              ? CarbonColors.interactive
              : CarbonColors.borderSubtle,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: CarbonColors.interactiveTint,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: CarbonSpacing.s3),
          child: Column(
            children: [
              Text(
                label,
                style: CarbonText.body01.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                costLabel,
                style: CarbonText.helperText01.copyWith(
                  color: cost < 0
                      ? CarbonColors.supportSuccess
                      : CarbonColors.textHelper,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
