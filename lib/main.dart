import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'carbon.dart';
import 'departments.dart';
import 'dept_tile.dart';
import 'l10n.dart';
import 'new_beginning.dart';
import 'reference.dart';
import 'rules.dart';
import 'setup9.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // 读取已保存的韩英选择 → 如果没有，则按设备（浏览器）语言决定起始语言。
  await loadAppLang();
  runApp(const CarnegieApp());
}

/// 对所有滚动应用弹性（iOS 风格）物理效果。
class _BouncyScrollBehavior extends MaterialScrollBehavior {
  const _BouncyScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

class CarnegieApp extends StatelessWidget {
  const CarnegieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appLang,
      builder: (context, _, _) => _app(),
    );
  }

  Widget _app() {
    return MaterialApp(
      title: tr('卡内基部门板块选择器', 'Carnegie Department Tile Selector'),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _BouncyScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'SUIT',
        scaffoldBackgroundColor: CarbonColors.pageBackground,
        colorScheme: const ColorScheme.light(
          primary: CarbonColors.interactive,
          surface: CarbonColors.background,
        ),
        splashFactory: NoSplash.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
            TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SetupScreen(),
    );
  }
}

/// 规则书第 15 页地区横幅颜色。
const regionColors = <String, Color>{
  '西部': Color(0xFFC2B49B),
  '中西部': Color(0xFFC0503C),
  '南部': Color(0xFF65A76B),
  '东部': Color(0xFF885F88),
};

/// 单人游戏准备与双人相同，因此合并为一个选项。
String playerLabel(int p) =>
    p == 2 ? tr('1-2人', '1-2 Players') : tr('$p人', '$p Players');

/// 按部门移除状态，以实体设置术语表示。
/// [boxedKind]：在扩展模式中未能进入按类型 4 选的选择，从而整类放回盒中的种类。
enum TileState { removeBoth, removeOne, keepBoth, boxedKind }

extension on DrawResult {
  TileState stateOf(Department d) {
    // 开放式设置：全部种类上场，没有 boxedKind，每种最多 1 个。
    if (isOpenSetup) {
      return removedOf(d) > 0 ? TileState.removeOne : TileState.keepBoth;
    }
    if (isExpansion && !selectedKinds!.contains(d.number)) {
      return TileState.boxedKind;
    }
    return switch (removedOf(d)) {
      2 => TileState.removeBoth,
      1 => TileState.removeOne,
      _ => TileState.keepBoth,
    };
  }
}

// ---------------------------------------------------------------------------
// Setup screen
// ---------------------------------------------------------------------------

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

/// 首页上划线行（含韩英切换）的屏幕顶部基准位置。
/// 顶部图标字形底部（顶部 8 + 按钮边距 11 + 字形 22 ≈ 39）再向下 15px
/// （用户确认：图标与切换间距 15）。
const _homeHeaderTop = 54.0;

/// 韩英切换高度（dense 24 + 5，用户确认）。上划线行高度也相同。
const _langSwitchHeight = 29.0;

/// 韩英切换单元格宽度和总宽度（两格 + 边框 1px×2）— 原 69px 与
/// 1.5 倍 104px 的中间值 86px（用户确认）。
const _langSegmentWidth = 42.0;
const _langSwitchWidth = _langSegmentWidth * 2 + 2;

/// 从正文右端到切换右端 — 对齐图标参考表图标字形
/// 末端（44px 按钮内 22px 字形 → 按钮末端内 13px）。
const _langSwitchInset = 13.0;

class _SetupScreenState extends State<SetupScreen> {
  /// 是否包含扩展 #1“新部门”（仅本会话，默认关闭）。
  GameMode _mode = GameMode.base;

  // bool get _expansion =>
  //     _mode == GameMode.baseExpansion || _mode == GameMode.expansionOnly;
  // 设备区域设置延迟传入等情况导致语言在切换外变化时，也重绘首页。
  void _onLang() => setState(() {});

  @override
  void initState() {
    super.initState();
    appLang.addListener(_onLang);
  }

  @override
  void dispose() {
    appLang.removeListener(_onLang);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      // 三张人数卡平均分配剩余纵向空间，填满屏幕。
                      // 空间不足时切换为滚动列表。
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final header = <Widget>[
                            // 去掉正文内边距(16)，从上划线在 _homeHeaderTop 开始。
                            const SizedBox(
                              height: _homeHeaderTop - CarbonSpacing.s5,
                            ),
                            // 在首页展示应用定位（卡内基设置助手）的上划线
                            // （方案 A，docs/mockups/home-title.html）。
                            // 上划线行高与韩英切换(_langSwitchHeight)一致。
                            // 切换本身在下方 Stack 中按屏幕基准定位，以对齐图标末端。
                            // 右侧留出切换位置（+ 间距 8），狭窄
                            // 宽度下文字碰到切换时才缩小。
                            SizedBox(
                              height: _langSwitchHeight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right:
                                      _langSwitchInset + _langSwitchWidth + 8,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      tr(
                                        'CARNEGIE · 卡内基设置助手',
                                        'CARNEGIE · SETUP HELPER',
                                      ),
                                      maxLines: 1,
                                      style: CarbonText.helperText01,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: CarbonSpacing.s3),
                            Text(
                              tr('游戏设置', 'Game Setup'),
                              style: CarbonText.heading05,
                            ),
                            const SizedBox(height: CarbonSpacing.s4),
                            // 固定一行：狭窄宽度下换行会让头部变长，
                            // 人数卡溢出，因此仅在溢出时按宽度缩小。
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                tr(
                                  '移除部门板块 · 放置中立圆片',
                                  'Remove Department tiles · place neutral disks',
                                ),
                                maxLines: 1,
                                style: CarbonText.body02.copyWith(
                                  color: CarbonColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: CarbonSpacing.s5),
                            // 基础版/扩展切换放在副标题下方
                            // （用户确认）。
                            // 狭窄宽度、大字体下溢出时按宽度缩小。
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: CarbonContentSwitcher(
                                labels: [
                                  tr('基础游戏', 'Base Game'),
                                  tr('基础+扩展', 'Base + Expansion'),
                                  tr('仅扩展', 'Expansion Only'),
                                  tr('开放式设置', 'Open Setup'),
                                ],
                                selected: switch (_mode) {
                                  GameMode.base => 0,
                                  GameMode.baseExpansion => 1,
                                  GameMode.expansionOnly => 2,
                                  GameMode.openSetup => 3,
                                },
                                onChanged: (i) => setState(() {
                                  _mode = switch (i) {
                                    0 => GameMode.base,
                                    1 => GameMode.baseExpansion,
                                    2 => GameMode.expansionOnly,
                                    _ => GameMode.openSetup,
                                  };
                                }),
                              ),
                            ),
                            // 模式说明放在切换与人数卡中间，
                            // 用固定高度占位，只换文案，
                            // 切换时下方布局不抖动。
                            const SizedBox(height: CarbonSpacing.s4),
                            SizedBox(
                              height: 16,
                              child: Text(
                                switch (_mode) {
                                  GameMode.base => tr(
                                    '仅使用基础游戏16种部门',
                                    'Uses only the 16 base-game Departments',
                                  ),
                                  GameMode.baseExpansion => tr(
                                    '从每类8种中抽取4种，以16种进行游戏',
                                    'Draw 4 of the 8 Departments of each type — 16 in play',
                                  ),
                                  GameMode.expansionOnly => tr(
                                    '仅使用扩展中16种部门',
                                    'Uses only Expansion Departments',
                                  ),
                                  GameMode.openSetup => tr(
                                    '使用基础与扩展全部32种部门，每种1个',
                                    'Use all 32 base + expansion Departments, 1 copy each',
                                  ),
                                },
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CarbonText.helperText01,
                              ),
                            ),
                            const SizedBox(height: CarbonSpacing.s4),
                          ];
                          Widget tile(int p) => _PlayerTile(
                            players: p,
                            mode: _mode,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ResultScreen(
                                  result: switch (_mode) {
                                    GameMode.base => draw(p),
                                    GameMode.baseExpansion => drawExpansion(p),
                                    GameMode.expansionOnly => drawExpansionOnly(
                                      p,
                                    ),
                                    GameMode.openSetup => drawOpenSetup(p),
                                  },
                                ),
                              ),
                            ),
                          );
                          // 低于 700 时卡片最小高度（约 128px）不够，
                          // 会溢出，因此切换为滚动列表。
                          if (constraints.maxHeight < 700) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(CarbonSpacing.s5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...header,
                                  for (final p in const [2, 3, 4]) ...[
                                    tile(p),
                                    if (p != 4)
                                      const SizedBox(height: CarbonSpacing.s3),
                                  ],
                                ],
                              ),
                            );
                          }
                          // 卡片:间距 = 170:15 — 间距减为此前(85:15)的一半
                          // 比例，剩余空间由卡片占据。
                          return Padding(
                            padding: const EdgeInsets.all(CarbonSpacing.s5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...header,
                                for (final p in const [2, 3, 4]) ...[
                                  Expanded(flex: 170, child: tile(p)),
                                  const Spacer(flex: 15),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // 顶部图标：与详细页面相同的 TopBar（正文列内，左右 16、
                // 顶部 8）叠加在正文上方 — 正文位置不变（用户确认）。
                Positioned(
                  top: 0,
                  left: CarbonSpacing.s5,
                  right: CarbonSpacing.s5,
                  child: TopBar(
                    actions: [
                      // 把新开始计算器放在最左侧（用户确认）。
                      TopIconButton(
                        icon: Icons.calculate_outlined,
                        tooltip: tr('“新开始”计算器', 'A New Beginning Calculator'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NewBeginningScreen(),
                          ),
                        ),
                      ),
                      TopIconButton(
                        icon: Icons.article_outlined,
                        tooltip: tr('规则摘要', 'Rules Summary'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RulesSummaryScreen(),
                          ),
                        ),
                      ),
                      TopIconButton(
                        icon: Icons.menu_book_outlined,
                        tooltip: tr('部门图鉴', 'Department Guide'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DeptCatalogScreen(),
                          ),
                        ),
                      ),
                      TopIconButton(
                        icon: Icons.info_outline,
                        tooltip: tr('图标参考', 'Icon Reference'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const IconReferenceScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 韩英切换：放在上划线行高(_homeHeaderTop)，右端
                // 对齐图标参考表图标字形（44px 按钮内 22px →
                // 按钮末端内 13px）（用户确认）。放在图标行后面，
                // 以便触摸事件进入切换。
                Positioned(
                  top: _homeHeaderTop,
                  right: CarbonSpacing.s5 + _langSwitchInset,
                  child: CarbonContentSwitcher(
                    dense: true,
                    height: _langSwitchHeight,
                    segmentWidth: _langSegmentWidth,
                    labels: const ['ZH', 'EN'],
                    selected: isEn ? 1 : 0,
                    onChanged: (i) {
                      // 语言立即改变，保存在后台异步完成。
                      setAppLang(i == 1 ? AppLang.en : AppLang.zh);
                      setState(() {});
                    },
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

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.players,
    required this.mode,
    required this.onTap,
  });

  final int players;
  final GameMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final removed = removalByPlayerCount[players]!;

    final isOpen = mode == GameMode.openSetup;
    final totalTiles = isOpen
        ? allDepartments.length
        : departments.length * copiesPerDepartment;
    final kept = totalTiles - removed;

    // 扩展标记：基础+扩展 / 仅扩展显示扩展图标；开放式设置显示另一个图标。
    final showExpansionMark =
        mode == GameMode.baseExpansion || mode == GameMode.expansionOnly;
    final showOpenMark = mode == GameMode.openSetup;

    return Material(
      color: CarbonColors.background,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: CarbonColors.borderSubtle),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: CarbonColors.layerHover01,
        child: Padding(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/pcount/p$players.webp',
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: CarbonSpacing.s3),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          playerLabel(players),
                          style: CarbonText.heading03.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (showExpansionMark) ...[
                          const SizedBox(width: CarbonSpacing.s2),
                          const Icon(
                            Icons.dashboard_customize_outlined,
                            size: 14,
                            color: CarbonColors.textSecondary,
                          ),
                        ],
                        if (showOpenMark) ...[
                          const SizedBox(width: CarbonSpacing.s2),
                          const Icon(
                            Icons.extension_outlined,
                            size: 14,
                            color: CarbonColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: CarbonColors.interactive,
                  ),
                ],
              ),
              const SizedBox(height: CarbonSpacing.s5),
              Text(
                isOpen
                    ? tr('移除$removed个板块', 'Remove $removed tiles')
                    : tr('移除$removed个板块', 'Remove $removed tiles'),
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.supportError,
                ),
              ),
              Text(
                isOpen
                    ? tr(
                        '使用$kept种部门(每种1个)',
                        '$kept kinds in play (1 copy each)',
                      )
                    : tr('使用$kept个', '$kept tiles in play'),
                style: CarbonText.helperText01,
              ),
              Text(
                disksByPlayerCount[players]! > 0
                    ? tr(
                        '${disksByPlayerCount[players]}个中立圆片',
                        '${disksByPlayerCount[players]} neutral disks',
                      )
                    : tr('无中立圆片', 'No neutral disks'),
                style: CarbonText.helperText01,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result screen
// ---------------------------------------------------------------------------

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final DrawResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late DrawResult _result = widget.result;
  late DiskSetup _disks = drawDisks(widget.result.playerCount);
  int _tab = 0;
  bool _detail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1056),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s5,
                  ),
                  child: TopBar(onBack: () => Navigator.of(context).pop()),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s5,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: CarbonColors.borderSubtle),
                    ),
                  ),
                  // 线条（下边框）保持全宽，标签左对齐。
                  alignment: Alignment.centerLeft,
                  // 三个标签比手机宽度更宽时（360px 1-2 人等）整行
                  // 按宽度缩小。放得下时保持原样。
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        _TabButton(
                          label: tr('部门', 'Departments'),
                          icon: Icons.grid_view,
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                        _TabButton(
                          label: tr('圆片', 'Disks'),
                          icon: Icons.circle,
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                        if (_result.playerCount == 2)
                          _TabButton(
                            label: tr('单人', 'Solo'),
                            icon: Icons.person_outline,
                            selected: _tab == 2,
                            onTap: () => setState(() => _tab = 2),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: switch (_tab) {
                    0 => _deptTab(),
                    1 => _diskTab(),
                    _ => _soloAidTab(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 结果页面通用头部：标题行 + 摘要栏。
  /// 重新抽取为各模式第一个区块标题右侧图标，人数变更为返回。
  List<Widget> _deptHeaderChildren() {
    return [
      Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tr(
                        '${playerLabel(_result.playerCount)}游戏',
                        playerLabel(_result.playerCount),
                      ),
                      style: CarbonText.heading05,
                    ),
                  ),
                ),
                // 与人数卡相同比例（相对字号）的扩展标记。
                if (_result.isExpansion) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.dashboard_customize_outlined,
                    size: 22,
                    color: CarbonColors.textSecondary,
                  ),
                ],
                if (_result.isOpenSetup) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.extension_outlined,
                    size: 22,
                    color: CarbonColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          CarbonContentSwitcher(
            labels: [tr('摘要', 'Summary'), tr('详细', 'Details')],
            selected: _detail ? 1 : 0,
            onChanged: (i) => setState(() => _detail = i == 1),
          ),
        ],
      ),
      const SizedBox(height: CarbonSpacing.s5),
      _SummaryBar(result: _result),
      const SizedBox(height: CarbonSpacing.s5),
    ];
  }

  /// 扩展模式种类选择标题（摘要、详细通用）。
  String get _chooseKindsTitle => tr('选择部门', 'Choose Departments');
  String get _chooseKindsSubtitle => _result.isOpenSetup
      ? tr(
          '仅拿取所有编号各1个 — 剩余放回游戏盒子中',
          'Take 1 copy of every number only — return the rest to the box',
        )
      : tr(
          '仅拿取以下编号各2个 — 剩余放回游戏盒子中',
          'Take both copies of these numbers only — return the rest to the box',
        );

  void _reroll() => setState(() {
    final p = _result.playerCount;
    _result = switch (_result.mode) {
      GameMode.base => draw(p),
      GameMode.baseExpansion => drawExpansion(p),
      GameMode.expansionOnly => drawExpansionOnly(p),
      GameMode.openSetup => drawOpenSetup(p),
    };
  });

  /// 重新抽取：方形边框图标按钮（用于区块标题右侧）。
  /// 不传 [onTap] 时执行部门板块重新抽取([_reroll])。
  Widget _rerollIconButton([VoidCallback? onTap]) {
    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: CarbonColors.interactive),
      ),
      child: InkWell(
        onTap: onTap ?? _reroll,
        hoverColor: CarbonColors.interactiveTint,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.shuffle, size: 18, color: CarbonColors.interactive),
        ),
      ),
    );
  }

  /// 扩展摘要：选择种类（标题右侧重新抽取图标）→ 板块移除
  /// 纵向排列（用户确认布局）。
  Widget _expansionSummaryTab(List<Department> shown) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          sliver: SliverList.list(
            children: [
              ..._deptHeaderChildren(),
              _diskSectionHeader(
                _chooseKindsTitle,
                _chooseKindsSubtitle,
                Icons.grid_view,
                trailing: _rerollIconButton(),
              ),
              const SizedBox(height: CarbonSpacing.s4),
              _KindCleanupCard(result: _result, onTapDept: _showDetail),
              const SizedBox(height: CarbonSpacing.s6),
              _diskSectionHeader(
                tr('移除板块', 'Remove Tiles'),
                tr(
                  '从取出的32个中，按标示数量移除以下板块',
                  'From those 32 tiles, remove the tiles below in the quantities shown',
                ),
                Icons.archive_outlined,
              ),
            ],
          ),
        ),
        _deptGrid(shown),
        const SliverToBoxAdapter(child: SizedBox(height: CarbonSpacing.s8)),
      ],
    );
  }

  Widget _deptTab() {
    // 摘要（基础版）：只按编号顺序显示移除板块 · 摘要（扩展）：滑动标签两阶段 —
    // 选择种类（编号芯片）→ 板块移除（网格）（用户确认方案 B）。
    // 详细：全部种类按编号顺序（显示使用/移除）。
    final all = switch (_result.mode) {
      GameMode.base => departments,
      GameMode.openSetup => allDepartments,
      _ => allDepartments, // 扩展两种模式都从 allDepartments 里筛
    };
    final shown = _detail
        ? ([...all]..sort((a, b) => a.number.compareTo(b.number)))
        : (all
              .where(
                (d) =>
                    _result.stateOf(d) == TileState.removeBoth ||
                    _result.stateOf(d) == TileState.removeOne,
              )
              .toList()
            // 类型顺序（人事→经营→建设→研发），同类型内按编号顺序。
            ..sort((a, b) {
              final byType = a.type.index.compareTo(b.type.index);
              return byType != 0 ? byType : a.number.compareTo(b.number);
            }));
    if (!_detail && (_result.isExpansion || _result.isOpenSetup)) {
      return _expansionSummaryTab(shown);
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          // 所有模式中头部后直接是区块标题，因此不留底部边距
          // （摘要↔详细切换时位置不抖动，保持一致）。
          padding: const EdgeInsets.fromLTRB(
            CarbonSpacing.s5,
            CarbonSpacing.s5,
            CarbonSpacing.s5,
            0,
          ),
          sliver: SliverList.list(children: _deptHeaderChildren()),
        ),
        if (!_detail) ...[
          // 基础版摘要：与扩展相同的语法 — 区块标题右侧重新抽取图标。
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: CarbonSpacing.s5),
            sliver: SliverToBoxAdapter(
              child: _diskSectionHeader(
                tr('移除板块', 'Remove Tiles'),
                tr(
                  '将以下板块按标示数量放回游戏盒子中',
                  'Return the tiles below to the game box in the quantities shown',
                ),
                Icons.archive_outlined,
                trailing: _rerollIconButton(),
              ),
            ),
          ),
          _deptGrid(shown),
        ] else ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: CarbonSpacing.s5),
            sliver: SliverList.list(
              children: (_result.isExpansion || _result.isOpenSetup)
                  ? [
                      _diskSectionHeader(
                        _chooseKindsTitle,
                        _chooseKindsSubtitle,
                        Icons.grid_view,
                        trailing: _rerollIconButton(),
                      ),
                      const SizedBox(height: CarbonSpacing.s4),
                      _KindCleanupCard(result: _result, onTapDept: _showDetail),
                    ]
                  : [
                      _diskSectionHeader(
                        tr('全部部门', 'All Departments'),
                        tr(
                          '全部16种部门 — 使用/移除',
                          'All 16 Departments — in play / removed',
                        ),
                        Icons.grid_view,
                        trailing: _rerollIconButton(),
                      ),
                    ],
            ),
          ),
          for (final type in DeptType.values) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CarbonSpacing.s5,
                CarbonSpacing.s4,
                CarbonSpacing.s5,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s4,
                    vertical: CarbonSpacing.s3,
                  ),
                  // 白色卡片标题 — 用户确认。
                  decoration: BoxDecoration(
                    color: CarbonColors.background,
                    border: Border(
                      // 与板块编号牌相同的类型颜色。
                      left: BorderSide(color: deptTypeColorOf(type), width: 4),
                      top: const BorderSide(color: Color(0xFFE4E6E7)),
                      right: const BorderSide(color: Color(0xFFE4E6E7)),
                      bottom: const BorderSide(color: Color(0xFFE4E6E7)),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 与图鉴相同的官方类型图标（参考表 i01~i04）。
                      Image.asset(
                        'assets/reficons/i0${DeptType.values.indexOf(type) + 1}.webp',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: CarbonSpacing.s3),
                      Text(type.label, style: CarbonText.heading02),
                      const SizedBox(width: CarbonSpacing.s3),
                      Text(type.altLabel, style: CarbonText.helperText01),
                    ],
                  ),
                ),
              ),
            ),
            _deptGrid(shown.where((d) => d.type == type).toList()),
          ],
        ],
        const SliverToBoxAdapter(child: SizedBox(height: CarbonSpacing.s8)),
      ],
    );
  }

  Widget _deptGrid(List<Department> depts) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CarbonSpacing.s5,
        CarbonSpacing.s4,
        CarbonSpacing.s5,
        0,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          // 单元格 = 板块本身。板块就是卡片。
          final width = constraints.crossAxisExtent;
          final cols = (width / 240).ceil().clamp(1, 6);
          final colWidth = (width - (cols - 1) * CarbonSpacing.s4) / cols;
          final extent = colWidth / deptTileAspect;
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisExtent: extent,
              crossAxisSpacing: CarbonSpacing.s4,
              mainAxisSpacing: CarbonSpacing.s4,
            ),
            itemCount: depts.length,
            itemBuilder: (context, i) => _DeptCard(
              dept: depts[i],
              state: _result.stateOf(depts[i]),
              onTap: () => _showDetail(depts[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _diskTab() {
    if (_result.playerCount == 1) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(CarbonSpacing.s7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.block,
                size: 64,
                color: CarbonColors.borderStrong,
              ),
              const SizedBox(height: CarbonSpacing.s6),
              Text(
                tr('无中立圆片', 'No Neutral Disks'),
                style: CarbonText.heading03,
              ),
              const SizedBox(height: CarbonSpacing.s3),
              Text(
                tr(
                  '单人游戏中，没有预先放置在游戏图版上的圆片',
                  'In a solo game, no disks are placed on the board in advance',
                ),
                textAlign: TextAlign.center,
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.textHelper,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_disks.totalDisks == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(CarbonSpacing.s7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.block,
                size: 64,
                color: CarbonColors.borderStrong,
              ),
              const SizedBox(height: CarbonSpacing.s6),
              Text(
                tr('不使用中立圆片', 'No Neutral Disks Used'),
                style: CarbonText.heading03,
              ),
              const SizedBox(height: CarbonSpacing.s3),
              Text(
                tr('四人游戏中跳过此步骤', 'For a 4-player game, skip this step.'),
                textAlign: TextAlign.center,
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.textHelper,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      children: [
        Text(
          tr('${_disks.totalDisks}个中立圆片', '${_disks.totalDisks} Neutral Disks'),
          style: CarbonText.heading05,
        ),
        const SizedBox(height: CarbonSpacing.s3),
        Text(
          tr(
            '将一种未使用颜色的圆片按以下所示放置在游戏图版上。',
            'Place disks from an unused player color on the game board as shown below.',
          ),
          style: CarbonText.body01.copyWith(color: CarbonColors.textSecondary),
        ),
        const SizedBox(height: CarbonSpacing.s6),
        // 重新抽取与部门板块格式相同 — 第一个区块标题右侧图标。
        _diskSectionHeader(
          tr('捐赠图表', 'Donation Chart'),
          tr(
            '${_disks.donations.length}个 · 在如下格中各放1个圆片',
            '${_disks.donations.length} · 1 disk on each space shown',
          ),
          Icons.volunteer_activism_outlined,
          trailing: _rerollIconButton(
            () => setState(() => _disks = drawDisks(_result.playerCount)),
          ),
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          rows: [
            for (final code in ([..._disks.donations]..sort()))
              (
                code,
                tr(
                  '${donationRowName(code[0])} · 第${code.substring(1)}格',
                  '${donationRowName(code[0])} · space ${code.substring(1)}',
                ),
                1,
              ),
          ],
          showCount: false,
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('城市建造格', 'City Construction Spaces'),
          tr(
            '${_disks.cityTotal}个 · 在每个城市靠左的空建设格上各放1个圆片',
            '${_disks.cityTotal} · leftmost unoccupied construction space of each city first',
          ),
          Icons.location_city,
        ),
        for (final region in cityRegions.keys)
          if (cityRegions[region]!.any(_disks.cityDisks.containsKey)) ...[
            const SizedBox(height: CarbonSpacing.s4),
            _DiskListCard(
              title: regionName(region),
              titleColor: regionColors[region],
              rows: [
                for (final city in cityRegions[region]!)
                  if (_disks.cityDisks.containsKey(city))
                    (null, cityName(city), _disks.cityDisks[city]!),
              ],
              showCount: true,
            ),
          ],
        const SizedBox(height: CarbonSpacing.s8),
      ],
    );
  }

  Widget _soloAidTab() {
    return ListView(
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      children: [
        Text(tr('单人助手', 'Solo Aid'), style: CarbonText.heading05),
        const SizedBox(height: CarbonSpacing.s3),
        Text(
          tr(
            '与安德鲁•卡内基对战的回合流程摘要。',
            'A round-by-round summary for playing against Andrew Carnegie.',
          ),
          style: CarbonText.body01.copyWith(color: CarbonColors.textSecondary),
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('回合流程', 'Round Sequence'),
          tr('5个步骤', '5 steps'),
          Icons.loop,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          showCount: false,
          rows: [
            (
              '1',
              tr(
                '新行动卡 — 拿取安德鲁行动卡堆的顶牌。不要翻看正面，正面朝下放在0分卡的下面',
                "New Action Card — draw Andrew's top action card and, without looking at it, place it face-down below the 0 VP card",
              ),
              0,
            ),
            (
              '2',
              tr(
                '选择行动 — 火车头在左边：玩家选择 · 火车头在右边：将本轮行动卡翻为正面朝上；安德鲁选择',
                'Choice of Action — locomotive to the left: you choose · to the right: flip the action card face-up; Andrew chooses',
              ),
              0,
            ),
            (
              '3',
              tr(
                '安德鲁的回合 — 结算活动，然后结算安德鲁的行动',
                "Andrew's Turn — resolve the event, then resolve Andrew's action on the card",
              ),
              0,
            ),
            (
              '4',
              tr(
                '玩家的回合 — 正常结算活动（收入/捐赠），使用本轮时间轴所对应类型的任意部门',
                "Player's Turn — resolve events (Take Income / Make a Donation), then use your Departments of that type",
              ),
              0,
            ),
            (
              '5',
              tr(
                '一轮结束 — 激活员工 → 行动标记向右移动一格 → 行动卡翻为正面朝下放在到达的胜利分卡下 → 火车头移动到另一侧',
                "End of Round — activate employees → move the action marker 1 space right → place Andrew's card face-down under the VP card it has reached → move the locomotive to the other side",
              ),
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('结算安德鲁的行动', "Resolve Andrew's Action"),
          tr(
            '每有1项无法执行，本轮的行动卡就向右平移一格',
            'Slide the card 1 space right for each one that cannot be done',
          ),
          Icons.smart_toy_outlined,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          showCount: false,
          rows: [
            (
              null,
              tr(
                '人力资源 — 按指示将本轮的行动卡向右平移相应的格数',
                'Human Resources — slide the action card to the right by the number of spaces indicated',
              ),
              0,
            ),
            (
              null,
              tr(
                '管理 — 按显示的部门类型，拿取1-3个对应类型的部门板块（从最小数字开始）',
                'Management — take 1-3 Department tiles of the type shown (always the lowest number available)',
              ),
              0,
            ),
            (
              null,
              tr(
                '建设 — 按显示的城市名称，在每个城市最左边的格上放1个圆片',
                'Construction — place a disk on the leftmost space of each city named on the card',
              ),
              0,
            ),
            (
              null,
              tr(
                '研发 — 按显示的区域，移动安德鲁的运输圆片向右1-3格',
                'R&D — move the transport disk in the region shown 1-3 spaces to the right',
              ),
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('活动（安德鲁）', 'Events (Andrew)'),
          '',
          Icons.event_note_outlined,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          showCount: false,
          rows: [
            (
              null,
              tr(
                '任务区图标 — 安德鲁什么都不做',
                'Mission area space — nothing happens for Andrew',
              ),
              0,
            ),
            (
              null,
              tr(
                '捐赠图标 — 按照本轮行动卡顶端的指示，在捐赠表的对应格放1个圆片；如果指示的格已经被占据（或是安德鲁已经没有圆片），他就不放圆片。沿着胜利分卡把安德鲁的行动卡向右平移一格。',
                'Donation symbol — place a disk on the donation space shown at the top of the card; if it is occupied (or Andrew is out of disks), place none and slide the card 1 space right',
              ),
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('安德鲁计分', "Andrew's Scoring"),
          tr('当游戏结束时', 'At the end of the game'),
          Icons.emoji_events_outlined,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          showCount: false,
          rows: [
            (
              null,
              tr(
                '行动卡 — 根据其所在位置的胜利分卡来决定',
                'Action cards — the VP of the VP card each one is under',
              ),
              0,
            ),
            (null, tr('每个部门板块价值2分', '2 VP per Department tile'), 0),
            (
              null,
              tr(
                '每个到达运输轨道的最后一格的运输圆片获得6分',
                '6 VP per transport disk that reached the last box of a transportation track',
              ),
              0,
            ),
            (
              null,
              tr(
                '建设圆片 — 每个0-3分，显示在游戏图版上',
                'Construction disks — 0-3 VP each, as shown for each city',
              ),
              0,
            ),
            (
              null,
              tr(
                '捐赠圆片 — 根据玩家在游戏中建造了什么来计分',
                'Donation disks — scored according to what you built',
              ),
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s8),
      ],
    );
  }

  Widget _diskSectionHeader(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarbonSpacing.s4,
        vertical: CarbonSpacing.s3,
      ),
      // 白色卡片标题（颜色条 + 浅色边框）— 用户确认。
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
          Expanded(
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
          ),
          if (trailing != null) ...[
            const SizedBox(width: CarbonSpacing.s3),
            trailing,
          ],
        ],
      ),
    );
  }

  void _showDetail(Department d) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CarbonColors.background,
      shape: const RoundedRectangleBorder(),
      constraints: const BoxConstraints(maxWidth: 672),
      isScrollControlled: true,
      builder: (context) => _DeptDetailSheet(
        dept: d,
        removedCount: _result.removedOf(d),
        copiesPerDept: _result.copiesPerDept,
        boxed: _result.stateOf(d) == TileState.boxedKind,
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.result});

  final DrawResult result;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, int value, Color color, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          // 用白色卡片提亮 — 只保留顶部颜色条（用户要求：消除暗淡）。
          decoration: BoxDecoration(
            color: CarbonColors.background,
            border: Border(
              top: BorderSide(color: color, width: 4),
              left: const BorderSide(color: Color(0xFFE4E6E7)),
              right: const BorderSide(color: Color(0xFFE4E6E7)),
              bottom: const BorderSide(color: Color(0xFFE4E6E7)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: CarbonColors.textSecondary),
                  const SizedBox(width: CarbonSpacing.s2),
                  Expanded(
                    child: WordSafeText(label, style: CarbonText.label01),
                  ),
                ],
              ),
              const SizedBox(height: CarbonSpacing.s2),
              Text(
                '$value',
                style: CarbonText.heading04.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 扩展（方案 B）：与摘要两阶段顺序相同 — ① 使用的种类 ② 移除的板块。
    if (result.isOpenSetup) {
      return Row(
        children: [
          stat(
            tr('使用部门', 'Departments Used'),
            result.selectedKinds!.length,
            CarbonColors.supportSuccess,
            Icons.grid_view,
          ),
          const SizedBox(width: CarbonSpacing.s3),
          stat(
            tr('移除部门', 'Kinds to Remove'),
            result.totalRemoved,
            CarbonColors.supportError,
            Icons.archive_outlined,
          ),
        ],
      );
    }
    if (result.isExpansion) {
      return Row(
        children: [
          stat(
            tr('使用部门', 'Departments Used'),
            result.selectedKinds!.length,
            CarbonColors.supportSuccess,
            Icons.grid_view,
          ),
          const SizedBox(width: CarbonSpacing.s3),
          stat(
            tr('移除板块', 'Tiles to Remove'),
            result.totalRemoved,
            CarbonColors.supportError,
            Icons.archive_outlined,
          ),
        ],
      );
    }
    return Row(
      children: [
        stat(
          tr('放回游戏盒子中', 'Return to Box'),
          result.totalRemoved,
          CarbonColors.supportError,
          Icons.archive_outlined,
        ),
        const SizedBox(width: CarbonSpacing.s3),
        stat(
          tr('放在桌上', 'Place on Table'),
          result.totalKept,
          CarbonColors.supportSuccess,
          Icons.table_bar_outlined,
        ),
      ],
    );
  }
}

/// 扩展摘要第 1 阶段：按类型列出本局使用的种类，用编号芯片表示。
class _KindCleanupCard extends StatelessWidget {
  const _KindCleanupCard({required this.result, required this.onTapDept});

  final DrawResult result;
  final void Function(Department) onTapDept;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, type) in DeptType.values.indexed) ...[
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
                  SizedBox(
                    width: isEn ? 104 : 64,
                    child: WordSafeText(
                      type.label,
                      style: CarbonText.heading01.copyWith(
                        color: deptTypeColorOf(type),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: CarbonSpacing.s3,
                      runSpacing: CarbonSpacing.s3,
                      children: [
                        for (final d in allDepartments.where(
                          (d) =>
                              d.type == type &&
                              result.selectedKinds!.contains(d.number),
                        ))
                          InkWell(
                            onTap: () => onTapDept(d),
                            child: DeptNumberPlate(dept: d, size: 32),
                          ),
                      ],
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
}

class _DeptCard extends StatelessWidget {
  const _DeptCard({
    required this.dept,
    required this.state,
    required this.onTap,
  });

  final Department dept;
  final TileState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (tagIcon, tagCount, tagBg, tagFg) = switch (state) {
      TileState.removeBoth => (
        Icons.delete,
        '×2',
        const Color(0x99DA1E28),
        CarbonColors.textOnColor,
      ),
      TileState.removeOne => (
        Icons.delete,
        '×1',
        const Color(0x99F1C21B),
        CarbonColors.textOnColor,
      ),
      TileState.keepBoth => (
        Icons.check,
        null,
        const Color(0x9924A148),
        CarbonColors.textOnColor,
      ),
      // 扩展模式：未进入按类型选择，整类放回盒中的种类。
      TileState.boxedKind => (
        Icons.inventory_2_outlined,
        null,
        const Color(0x99A2999E),
        CarbonColors.textOnColor,
      ),
    };

    // 板块本身就是网格单元格。状态徽章仅叠加在徽章区域右下角。
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned.fill(child: DeptTile(dept: dept)),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, hoverColor: const Color(0x14353B3C)),
            ),
          ),
          // 按效果栏高度（基准 72px × 网格放大 1.3）比例放在其上方。
          Positioned(
            bottom: constraints.maxWidth * 72 * 1.3 / 400 + CarbonSpacing.s3,
            right: CarbonSpacing.s3,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tagIcon, size: 14, color: tagFg),
                    if (tagCount != null) ...[
                      const SizedBox(width: 2),
                      Text(
                        tagCount,
                        style: CarbonText.label01.copyWith(
                          color: tagFg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTag extends StatelessWidget {
  const _TypeTag({required this.type});

  final DeptType type;

  @override
  Widget build(BuildContext context) {
    return CarbonTag(
      text: type.label,
      bg: CarbonColors.tagGrayBg,
      fg: CarbonColors.tagGrayText,
    );
  }
}

class _DeptDetailSheet extends StatelessWidget {
  const _DeptDetailSheet({
    required this.dept,
    required this.removedCount,
    required this.copiesPerDept,
    this.boxed = false,
  });

  final Department dept;
  final int removedCount;
  final int copiesPerDept;

  /// 扩展模式中未进入按类型选择、本局不使用的种类。
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final kept = copiesPerDept - removedCount;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CarbonSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeptNumberPlate(dept: dept),
                const SizedBox(width: CarbonSpacing.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dept.name, style: CarbonText.heading03),
                      const SizedBox(height: 2),
                      Text(dept.altName, style: CarbonText.helperText01),
                    ],
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
            DeptDoubleRule(dept: dept),
            const SizedBox(height: CarbonSpacing.s6),
            Center(child: DeptEmblem(dept: dept)),
            const SizedBox(height: CarbonSpacing.s6),
            DeptEffectBar(dept: dept),
            const SizedBox(height: CarbonSpacing.s5),
            Wrap(
              spacing: CarbonSpacing.s2,
              runSpacing: CarbonSpacing.s2,
              children: [
                _TypeTag(type: dept.type),
                if (dept.expansion)
                  CarbonTag(
                    text: tr('扩展', 'Expansion'),
                    bg: CarbonColors.tagGrayBg,
                    fg: CarbonColors.tagGrayText,
                  ),
                if (dept.ongoing)
                  CarbonTag(
                    text: tr('持续', 'Ongoing'),
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                if (dept.endgame)
                  CarbonTag(
                    text: tr('游戏结束', 'Final Scoring'),
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                if (boxed)
                  CarbonTag(
                    text: tr('本局未使用', 'Not in this game'),
                    bg: CarbonColors.tagGrayBg,
                    fg: CarbonColors.tagGrayText,
                  )
                else ...[
                  if (removedCount > 0)
                    CarbonTag(
                      text: tr('移除$removedCount个', 'Remove $removedCount'),
                      bg: CarbonColors.tagRedBg,
                      fg: CarbonColors.tagRedText,
                    ),
                  if (kept > 0)
                    CarbonTag(
                      text: tr('使用$kept个', '$kept in play'),
                      bg: CarbonColors.tagGreenBg,
                      fg: CarbonColors.tagGreenText,
                    ),
                ],
              ],
            ),
            const SizedBox(height: CarbonSpacing.s5),
            Text(tr('规则', 'Rules'), style: CarbonText.label01),
            const SizedBox(height: CarbonSpacing.s2),
            Text(dept.ruleText, style: CarbonText.body02),
          ],
        ),
      ),
    );
  }
}

/// Carbon line tab.
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: CarbonColors.layerHover01,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CarbonSpacing.s5,
          vertical: CarbonSpacing.s4,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? CarbonColors.interactive : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? CarbonColors.textPrimary
                    : CarbonColors.textHelper,
              ),
              const SizedBox(width: CarbonSpacing.s2),
            ],
            Text(
              label,
              style: CarbonText.body01.copyWith(
                color: selected
                    ? CarbonColors.textPrimary
                    : CarbonColors.textHelper,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White card listing disk placements: optional leading code badge,
/// label, optional trailing count tag.
class _DiskListCard extends StatelessWidget {
  const _DiskListCard({
    required this.rows,
    required this.showCount,
    this.title,
    this.titleColor,
  });

  /// (badge code or null, label, count)
  final List<(String?, String, int)> rows;
  final bool showCount;

  /// Optional header row (e.g., map region name).
  final String? title;

  /// Header banner color (rulebook region color).
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CarbonSpacing.s5,
                vertical: CarbonSpacing.s3,
              ),
              color: titleColor ?? CarbonColors.layer01,
              child: Text(
                title!,
                style: CarbonText.heading01.copyWith(
                  color: titleColor != null
                      ? CarbonColors.textOnColor
                      : CarbonColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
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
                  if (row.$1 != null) ...[
                    Container(
                      width: 40,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: CarbonColors.interactiveTint,
                        border: Border.all(color: CarbonColors.interactive),
                      ),
                      child: Text(
                        row.$1!,
                        style: CarbonText.label01.copyWith(
                          color: CarbonColors.interactive,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: CarbonSpacing.s4),
                  ],
                  Expanded(child: Text(row.$2, style: CarbonText.body01)),
                  if (showCount)
                    CarbonTag(
                      text: tr(
                        '${row.$3}个',
                        row.$3 == 1 ? '1 disk' : '${row.$3} disks',
                      ),
                      bg: CarbonColors.tagGrayBg,
                      fg: CarbonColors.tagGrayText,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
