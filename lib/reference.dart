import 'package:flutter/material.dart';

import 'carbon.dart';
import 'departments.dart';
import 'dept_tile.dart';
import 'l10n.dart';

// ---------------------------------------------------------------------------
// Department catalog screen（部门图鉴）
// ---------------------------------------------------------------------------

class DeptCatalogScreen extends StatefulWidget {
  const DeptCatalogScreen({super.key});

  @override
  State<DeptCatalogScreen> createState() => _DeptCatalogScreenState();
}

class _DeptCatalogScreenState extends State<DeptCatalogScreen> {
  /// 0 = 基础版（1~16），1 = 扩展（17~32）。
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final shown = _tab == 0 ? departments : expansionDepartments;
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
                        icon: Icons.info_outline,
                        tooltip: tr('建造部门', 'Building Departments'),
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: CarbonColors.background,
                          shape: const RoundedRectangleBorder(),
                          constraints: const BoxConstraints(maxWidth: 672),
                          isScrollControlled: true,
                          builder: (context) => const _OrganizeGuideSheet(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(CarbonSpacing.s5),
                    children: [
                      // 标题·开关始终一行（用户已确认）。英文用短标记
                      // （Departments / Base | Expansion），若原尺寸
                      // 放不下则缩为 "Depts."（用户已确认）。若在极端
                      // 宽度下仍溢出，则仅将标题按宽度缩小。
                      Row(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                var title = tr('部门', 'Departments');
                                if (isEn) {
                                  final full = TextPainter(
                                    text: TextSpan(
                                      text: title,
                                      style: CarbonText.heading05,
                                    ),
                                    textDirection: Directionality.of(context),
                                    textScaler: MediaQuery.textScalerOf(
                                      context,
                                    ),
                                  )..layout();
                                  if (full.width > constraints.maxWidth) {
                                    title = 'Depts.';
                                  }
                                }
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    style: CarbonText.heading05,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: CarbonSpacing.s3),
                          CarbonContentSwitcher(
                            labels: [tr('基础', 'Base'), tr('扩展', 'Expansion')],
                            selected: _tab,
                            onChanged: (i) => setState(() => _tab = i),
                          ),
                        ],
                      ),
                      const SizedBox(height: CarbonSpacing.s3),
                      // 两段说明叠放，只显示选中一侧。高度始终固定为
                      // 较长的一侧，因此基础版↔扩展切换时下方不会抖动
                      // （与宽度·语言无关）。
                      IndexedStack(
                        index: _tab,
                        children: [
                          for (final text in [
                            tr(
                              '기본판 부서 16종(1~16번) — 종류별 4개씩, 각 2장씩 '
                                  '들어 있습니다. 4·8·12·16번 부서는 색이 다르며 '
                                  '지속 효과를 제공합니다.',
                              'The 16 base-game Departments (1-16) — 4 of each '
                                  'type, 2 copies of each. Departments 4, 8, 12 '
                                  '& 16 are colored differently; they provide '
                                  'passive or ongoing effects.',
                            ),
                            tr(
                              '확장 부서 16종(17~32번) — 종류별 4개씩, 각 2장씩 '
                                  '들어 있습니다. 지속 효과 부서와 게임 종료 시 '
                                  '득점하는 부서가 있습니다.',
                              'The 16 expansion Departments (17-32) — 4 of '
                                  'each type, 2 copies of each. Some have '
                                  'ongoing effects; others affect final '
                                  'scoring.',
                            ),
                          ])
                            Text(
                              text,
                              style: CarbonText.body01.copyWith(
                                color: CarbonColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: CarbonSpacing.s3),
                      for (final type in DeptType.values) ...[
                        Container(
                          margin: const EdgeInsets.only(top: CarbonSpacing.s4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: CarbonSpacing.s4,
                            vertical: CarbonSpacing.s3,
                          ),
                          // 白色卡片标题 —— 用户已确认。
                          decoration: BoxDecoration(
                            color: CarbonColors.background,
                            border: Border(
                              // 与瓷砖编号板相同的类型色。
                              left: BorderSide(
                                color: deptTypeColorOf(type),
                                width: 4,
                              ),
                              top: const BorderSide(color: Color(0xFFE4E6E7)),
                              right: const BorderSide(color: Color(0xFFE4E6E7)),
                              bottom: const BorderSide(
                                color: Color(0xFFE4E6E7),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/reficons/i0${DeptType.values.indexOf(type) + 1}.webp',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: CarbonSpacing.s3),
                              Text(type.label, style: CarbonText.heading02),
                              const SizedBox(width: CarbonSpacing.s3),
                              Text(
                                type.altLabel,
                                style: CarbonText.helperText01,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: CarbonSpacing.s4),
                        for (final d in shown.where((d) => d.type == type)) ...[
                          _CatalogRow(dept: d),
                          const SizedBox(height: CarbonSpacing.s4),
                        ],
                      ],
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
}

/// 部门组织方法·费用说明弹窗
/// （依据：规则书第 10 页 "战略规划"，第 6 页 4.2 激活费用 —— UI 中不标注）。
class _OrganizeGuideSheet extends StatelessWidget {
  const _OrganizeGuideSheet();

  static const _rows = <(IconData, String)>[
    (
      Icons.work_outline,
      '在管理行动中，“战略规划”部门中每名激活的员工可以建造1个新部门。',
    ),
    (
      Icons.inventory_2_outlined,
      '费用：2个货物方块 — 放在自己公司图版的任意1个空格上。若该空格有至少1名'
          '员工，则只需支付1个货物方块。',
    ),
    (
      Icons.looks_one_outlined,
      '玩家放置的第1个部门必须是在游戏设置步骤10中选取的。',
    ),
    (Icons.block, '1个公司永远不能有2个相同的部门。'),
    (
      Icons.paid_outlined,
      '板块工位下方的费用不是建造费用，而是一轮结束时激活该工位员工'
          '需要支付的费用。',
    ),
  ];

  /// 英文规则书第 10 页 Strategic Planning，第 6 页 4.2 Recruiting Employees。
  static const _rowsEn = <(IconData, String)>[
    (
      Icons.work_outline,
      'In the Management action, each active employee in "Strategic '
          'Planning" lets you build 1 new Department.',
    ),
    (
      Icons.inventory_2_outlined,
      'Cost: 2 goods cubes — any free space on your Company board. Only 1 '
          'goods cube if the free space already contains at least one '
          'employee.',
    ),
    (
      Icons.looks_one_outlined,
      'The first Department you build must be the one you chose during '
          'step 10 of setup.',
    ),
    (Icons.block, 'A Company may never contain two identical Departments.'),
    (
      Icons.paid_outlined,
      'The dollar value under a Workstation is not a building cost — it is '
          'the cost to activate an employee there at the end of a round.',
    ),
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
                  Icons.add_business_outlined,
                  size: 20,
                  color: CarbonColors.textSecondary,
                ),
                const SizedBox(width: CarbonSpacing.s3),
                Expanded(
                  child: Text(
                    tr('建造部门', 'Building Departments'),
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
            for (final (icon, text) in isEn ? _rowsEn : _rows)
              Padding(
                padding: const EdgeInsets.only(bottom: CarbonSpacing.s3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        icon,
                        size: 16,
                        color: CarbonColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: CarbonSpacing.s3),
                    Expanded(
                      child: Text(
                        text,
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

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({required this.dept});

  final Department dept;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      // 板+名称 → 双规线 → 徽章 → 效果栏 → 说明。用与瓷砖相同的部件
      // 按画面宽度直接布置。
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DeptNumberPlate(dept: dept, size: 40),
              const SizedBox(width: CarbonSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WordSafeText(
                      dept.name,
                      style: CarbonText.heading03.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(dept.altName, style: CarbonText.helperText01),
                  ],
                ),
              ),
              if (dept.ongoing)
                Padding(
                  padding: const EdgeInsets.only(left: CarbonSpacing.s2),
                  child: CarbonTag(
                    text: tr('持续', 'Ongoing'),
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                ),
              if (dept.endgame)
                Padding(
                  padding: const EdgeInsets.only(left: CarbonSpacing.s2),
                  child: CarbonTag(
                    text: tr('终局计分', 'Final Scoring'),
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: CarbonSpacing.s4),
          DeptDoubleRule(dept: dept),
          const SizedBox(height: CarbonSpacing.s5),
          Center(child: DeptEmblem(dept: dept, scale: 0.85)),
          const SizedBox(height: CarbonSpacing.s5),
          DeptEffectBar(dept: dept, scale: 0.9),
          const SizedBox(height: CarbonSpacing.s5),
          Text(dept.ruleText, style: CarbonText.body01.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon reference screen（图标参考表，规则书第 20 页）—— legend 风格的单个
// 图标网格，附文字说明。
// ---------------------------------------------------------------------------

class _RefItem {
  const _RefItem(this.icon, this.label, this.labelEn);
  final int icon; // reficons/iNN.webp
  final String label;

  /// 英文规则书第 20 页 Icon Reference 标注。
  final String labelEn;
  String get text => tr(label, labelEn);
}

class _RefSection {
  const _RefSection(this.title, this.titleEn, this.items);
  final String title;
  final String titleEn;
  final List<_RefItem> items;
  String get text => tr(title, titleEn);
}

const _refSections = <_RefSection>[
  _RefSection('部门类型', 'Department Types', [
    _RefItem(1, '人力资源', 'Human Resources'),
    _RefItem(2, '管理', 'Management'),
    _RefItem(3, '建设', 'Construction'),
    _RefItem(4, '研究&开发', 'Research & Development'),
  ]),
  _RefSection('任务区', 'Mission Areas', [
    _RefItem(5, '在任务区的员工', 'Employee on Mission area'),
    _RefItem(
      6,
      '从任务区收回员工（回到大厅）',
      'Take employee from Mission area (return to Lobby)',
    ),
    _RefItem(
      7,
      '从任务区收回1名或多名员工（回到大厅）',
      'Take one or more employees from Mission area (return to Lobby)',
    ),
    _RefItem(8, '派出员工到任务区', 'Place employee on Mission area'),
  ]),
  _RefSection('员工', 'Employees', [
    _RefItem(9, '激活的员工', 'Active employee'),
    _RefItem(10, '未激活的员工', 'Inactive employee'),
    _RefItem(
      11,
      '获得1名新员工放入大厅',
      'Gain one new employee from supply to Lobby',
    ),
    _RefItem(12, '员工放入大厅', 'Employees arriving into Lobby'),
    _RefItem(
      13,
      '在公司图版上移动1名员工一格（不能斜着）。可以停在任何格。员工变成未激活的状态。',
      'Move an employee one space (no diagonals) on Department board. May end on any space. Employee becomes inactive.',
    ),
  ]),
  _RefSection('部门', 'Departments', [
    _RefItem(14, '部门', 'Department'),
    _RefItem(15, '有激活的员工的部门', 'Department with an active employee'),
    _RefItem(16, '有未激活的员工的部门', 'Department with an inactive employee'),
    _RefItem(17, '移动1名员工到这个部门', 'Move an employee to this Department'),
    _RefItem(
      18,
      '在1个没有部门的格上建造1个新部门',
      'Build a new Department on a space with no Department',
    ),
    _RefItem(
      19,
      '在1个没有部门并且有未激活的员工的格上建造1个新部门',
      'Build a new Department on a space with no Department and an inactive employee',
    ),
  ]),
  _RefSection('捐赠', 'Donations', [
    _RefItem(20, '捐赠', 'Donation'),
    _RefItem(21, '进行1次捐赠', 'Make a donation'),
    _RefItem(
      22,
      '放置1个捐赠圆片在包含其他玩家圆片的捐赠格',
      "Place a donation disk on a space containing another player's disk",
    ),
  ]),
  _RefSection('地图', 'Map', [
    _RefItem(23, '地图中的建设圆片', 'Construction disk on map'),
    _RefItem(24, '小城市上的建设圆片', 'Construction disk on small city'),
    _RefItem(25, '大城市的连接分数', 'Major city connection points'),
  ]),
  _RefSection('收入', 'Income', [
    _RefItem(
      26,
      '获得运输轨道上圆片所在位置的收入',
      'Income from current space on transport track',
    ),
    _RefItem(
      27,
      '获得项目标签上露出的格上的收入',
      'Income from revealed spaces on project tabs',
    ),
    _RefItem(28, '选择1个货物方块或\$3', 'Choose one goods cube or \$3'),
    _RefItem(29, '选择1个新员工或\$1', 'Choose one new employee or \$1'),
    _RefItem(
      30,
      '每个捐赠的分数上限增加3',
      'The VP limit for each donation is increased by 3',
    ),
  ]),
  _RefSection('胜利分数', 'Victory Points', [
    _RefItem(31, '即时分数', 'Immediate VP'),
    _RefItem(32, '终局分数', 'Game-end VP'),
  ]),
  _RefSection('项目类型', 'Project Types', [
    _RefItem(33, '公共设施', 'Public Infrastructure'),
    _RefItem(34, '工业', 'Industry'),
    _RefItem(35, '商业', 'Commerce'),
    _RefItem(36, '住宅', 'Housing'),
  ]),
  _RefSection('研究', 'Study', [
    _RefItem(37, '可以花费的研究点', 'Study points available to spend'),
    _RefItem(38, '研究点费用', 'Study point cost'),
    _RefItem(39, '研究点费用的折扣', 'Discount on study point cost'),
  ]),
  _RefSection('运输轨道', 'Transport Tracks', [
    _RefItem(40, '运输轨道', 'Transport track'),
    _RefItem(41, '马车', 'Cart'),
    _RefItem(42, '驿站马车', 'Stagecoach'),
    _RefItem(43, '铁路', 'Railroad'),
  ]),
  _RefSection('货物&钱', 'Goods & Money', [
    _RefItem(44, '获得钱', 'Gain money'),
    _RefItem(45, '花钱', 'Spend money'),
    _RefItem(46, '获得1个货物方块', 'Gain a goods cube'),
    _RefItem(47, '花费1个货物方块', 'Spend a goods cube'),
  ]),
];

// 参考表强调色 —— 遵循规则书第 20 页的结构（上标线·双下划线·细点线），
// 但颜色统一为应用调色板（用户已确认）。
const _refAccent = CarbonColors.interactive;
const _refDot = CarbonColors.borderStrong;

class IconReferenceScreen extends StatelessWidget {
  const IconReferenceScreen({super.key});

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
                  child: TopBar(onBack: () => Navigator.of(context).pop()),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(CarbonSpacing.s5),
                    children: [
                      // 规则书第 20 页的标题结构：标题 + 双下划线。
                      Text(
                        tr('图标参考', 'Icon Reference'),
                        style: CarbonText.heading05.copyWith(color: _refAccent),
                      ),
                      const SizedBox(height: CarbonSpacing.s3),
                      Container(height: 1.4, color: _refAccent),
                      const SizedBox(height: 2.5),
                      Container(height: 1.4, color: _refAccent),
                      const SizedBox(height: CarbonSpacing.s5),
                      // 列组顺序按规则书原样，项之间无线，
                      // 列之间用细点线。新栏以上标线开始。
                      Container(
                        decoration: BoxDecoration(
                          color: CarbonColors.background,
                          border: Border.all(color: CarbonColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: CarbonSpacing.s3,
                          vertical: CarbonSpacing.s5,
                        ),
                        child: Column(
                          children: [
                            for (final (i, row) in _refRows.indexed) ...[
                              if (i > 0)
                                const SizedBox(height: CarbonSpacing.s6),
                              _RefPairRow(left: row.$1, right: row.$2),
                            ],
                          ],
                        ),
                      ),
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
}

/// 按规则书第 20 页的列组顺序，两列一组配对布置。
final _refRows = <(List<_RefSection>, List<_RefSection>)>[
  ([_refSections[0]], [_refSections[1]]),
  ([_refSections[2]], [_refSections[3]]),
  ([_refSections[4], _refSections[5]], [_refSections[6], _refSections[7]]),
  ([_refSections[8], _refSections[9]], [_refSections[10], _refSections[11]]),
];

/// 两列条带 + 中间点线。（IntrinsicHeight 会以列宽为基准过大地估算图像
/// 固有高度，因此点线画在 Stack 之上。）
class _RefPairRow extends StatelessWidget {
  const _RefPairRow({required this.left, required this.right});

  final List<_RefSection> left;
  final List<_RefSection> right;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _VDashPainter())),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _RefStrip(sections: left)),
            const SizedBox(width: CarbonSpacing.s4),
            Expanded(child: _RefStrip(sections: right)),
          ],
        ),
      ],
    );
  }
}

/// 纵向条带：标题（带下划线）下方密集堆叠图标·说明。
/// 与规则书一样，项之间不加分隔线。
class _RefStrip extends StatelessWidget {
  const _RefStrip({required this.sections});

  final List<_RefSection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, s) in sections.indexed) ...[
          // 规则书的列头：粗上标线 + 深色标题。
          Padding(
            padding: EdgeInsets.fromLTRB(
              CarbonSpacing.s3,
              i == 0 ? 0 : CarbonSpacing.s6,
              CarbonSpacing.s3,
              CarbonSpacing.s2,
            ),
            child: Column(
              children: [
                Container(height: 3.5, color: _refAccent),
                const SizedBox(height: CarbonSpacing.s3),
                Text(
                  s.text,
                  textAlign: TextAlign.center,
                  style: CarbonText.heading01,
                ),
              ],
            ),
          ),
          for (final item in s.items)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CarbonSpacing.s3,
                CarbonSpacing.s3,
                CarbonSpacing.s3,
                CarbonSpacing.s2,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    child: Image.asset(
                      'assets/reficons/i${item.icon.toString().padLeft(2, '0')}.webp',
                      cacheWidth: 180,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(height: CarbonSpacing.s2),
                  Text(
                    item.text,
                    textAlign: TextAlign.center,
                    style: CarbonText.label01.copyWith(
                      color: CarbonColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// 规则书的列间细点线（纵向，居中）。
class _VDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _refDot;
    final x = size.width / 2;
    for (var y = 2.0; y < size.height; y += 6) {
      canvas.drawCircle(Offset(x, y), 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}