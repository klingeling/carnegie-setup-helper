import 'dart:math';

import 'l10n.dart';

/// The four Carnegie action types a department belongs to.
enum DeptType {
  hr('人力资源', 'Human Resources'),
  management('管理', 'Management'),
  construction('建设', 'Construction'),
  rnd('研发', 'R&D');

  const DeptType(this.zh, this.en);
  final String zh;
  final String en;

  /// 현재 언어의 유형 이름과, 보조 표기로 쓰는 다른 언어 이름.
  String get label => tr(zh, en);
  String get altLabel => tr(en, zh);
}

/// 游戏设置模式。
enum GameMode {
  base, // 基础游戏
  baseExpansion, // 基础+扩展
  expansionOnly, // 仅扩展
  openSetup, // 开放式设置
}

class Department {
  const Department({
    required this.number,
    required this.zh,
    required this.en,
    required this.type,
    required this.rule,
    required this.ruleEn,
    this.ongoing = false,
    this.expansion = false,
    this.endgame = false,
  });

  final int number;
  final String zh;
  final String en;
  final DeptType type;
  final String rule;

  /// 영문 규칙 설명 (영문 규칙서 16–17쪽, 확장 룰북 2–3쪽).
  final String ruleEn;

  /// 현재 언어의 부서 이름·규칙과, 보조 표기로 쓰는 다른 언어 이름.
  String get name => tr(zh, en);
  String get altName => tr(en, zh);
  String get ruleText => tr(rule, ruleEn);

  /// Tiles 4, 8, 12, 16 have a different color and provide ongoing effects.
  /// 확장 세트 3(19, 23, 27, 31)도 지속 효과를 제공합니다.
  final bool ongoing;

  /// 확장 #1 부서(17~32).
  final bool expansion;

  /// 확장 세트 4(20, 24, 28, 32): 게임 종료 시 이 부서에 활성화된 직원이
  /// 있으면 최종 득점에 영향을 주는 부서.
  final bool endgame;

  /// 규칙서 16–17쪽(1~16), 확장 룰북 2–3쪽(17~32)에서 추출한 원본 타일 이미지.
  String get image =>
      'assets/departments/dept_${number.toString().padLeft(2, '0')}.webp';
}

const departments = <Department>[
  Department(
    number: 1,
    zh: '培训与合作伙伴',
    en: 'Training and Partnerships',
    type: DeptType.hr,
    rule:
        '玩家必须从这个部门派出1名激活的员工执行任务。然后，玩家选择获得\$8'
        '或8步员工移动。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. Then, the player may choose to receive '
        'either \$8 OR 8 employee moves.',
  ),
  Department(
    number: 2,
    zh: '招聘',
    en: 'Recruiting',
    type: DeptType.hr,
    rule:
        '玩家可以选择一项：从这个部门派出1名激活的员工执行任务。然后，'
        '该玩家拿1名新员工放到公司的大厅中；或者获得4步员工移动。',
    ruleEn:
        'For each use of this Department, the player may either: send an '
        'active employee from this Department on a Mission, then immediately '
        'place a new employee from their supply into their Company\'s Lobby, '
        'OR receive 4 employee moves.',
  ),
  Department(
    number: 3,
    zh: '品质与安全',
    en: 'Safety and Quality',
    type: DeptType.hr,
    rule:
        '玩家必须从这个部门派出1名激活的员工执行任务。然后，玩家公司中每有2名激活的员工，'
        '该玩家就获得1分，向上取整。执行任务的员工不视为是激活的员工。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. Then, the player receives 1 VP for '
        'every two active employees in their Company, rounded up. Employees '
        'on Missions are not considered to be active.',
  ),
  Department(
    number: 4,
    zh: '新大厅',
    en: 'New Lobby',
    type: DeptType.hr,
    ongoing: true,
    rule:
        '为了建造这个部门，玩家必须额外支付2个货物方块。一旦建造了这个部门，'
        '新招聘和收回的员工可以放在这里，这些员工可以根据玩家意愿自由分配到2个大厅中。'
        '这个部门是持续效果；也是唯一不需要激活的员工的部门。',
    ruleEn:
        'To build this Department, the player must pay 2 goods cubes in '
        'addition to the normal building cost. Once built, it can hold new '
        'recruits and returning employees, which can be allocated between the '
        'two Lobbies as desired. It is the only Department that does not '
        'require an active employee to function.',
  ),
  Department(
    number: 5,
    zh: '采购',
    en: 'Purchasing',
    type: DeptType.management,
    rule:
        '家必须从这个部门派出1名激活的员工执行任务。然后，'
        '玩家可以从公共供应堆中拿取3个货物方块或获得\$8。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission; they may then either receive \$8 OR '
        'take 3 goods cubes from the supply.',
  ),
  Department(
    number: 6,
    zh: '销售',
    en: 'Sales',
    type: DeptType.management,
    rule: '每次玩家可以支付1-3个货物方块到公共供应堆。每个支付的方块可以让玩家获得\$6。',
    ruleEn:
        'Each time a player uses this Department, they may pay 1 to 3 goods '
        'cubes to the supply. For each cube paid in this way, they receive '
        '\$6.',
  ),
  Department(
    number: 7,
    zh: '后勤',
    en: 'Logistics',
    type: DeptType.management,
    rule:
        '每次玩家可以支付1-3个货物方块到公共供应堆。'
        '每个支付的方块可以让玩家获得得\$3和1分。',
    ruleEn:
        'Each time a player uses this Department, they may pay 1 to 3 goods '
        'cubes to the supply. For each cube paid in this way, they receive '
        '\$3 and 1 VP.',
  ),
  Department(
    number: 8,
    zh: '资产管理',
    en: 'Property Management',
    type: DeptType.management,
    ongoing: true,
    rule:
        '持续效果：每当玩家为自己公司增加了1个新部门时，玩家可以立刻从自己任一部门中移动1名员工'
        '（激活或未激活的）到新的部门中，成为未激活状态。',
    ruleEn:
        'Ongoing effect: whenever a player adds a new Department to their '
        'Company, they may immediately move one of their employees (active or '
        'inactive) to the new Department, in an inactive state.',
  ),
  Department(
    number: 9,
    zh: '工程',
    en: 'Engineering',
    type: DeptType.construction,
    rule:
        '玩家必须从这个部门派出1名激活的员工执行任务。然后，该玩家支付1或2个货物方块，'
        '在执行任务的同一区域建造1个新项目。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. That player then pays 1 or 2 goods '
        'cubes to build a new project in the same region.',
  ),
  Department(
    number: 10,
    zh: '建设外包',
    en: 'Construction Outsourcing',
    type: DeptType.construction,
    rule:
        '玩家支付\$3以及1个或2个货物方块，在图版上的任意位置建造1个新项目，'
        '而且不需要派出员工执行任务。',
    ruleEn:
        'Whenever this Department is used, the player may pay \$3 and 1-2 '
        'goods cubes to build a new project anywhere on the game board, '
        'without sending an employee on a Mission.',
  ),
  Department(
    number: 11,
    zh: '供应链',
    en: 'Supply Chain',
    type: DeptType.construction,
    rule: '可以用\$1购买1个货物方块，最多3次。',
    ruleEn:
        'Whenever a player uses this Department, they may purchase up to 3 '
        'goods cubes at a cost of \$1 each.',
  ),
  Department(
    number: 12,
    zh: '沟通',
    en: 'Communications',
    type: DeptType.construction,
    ongoing: true,
    rule:
        '持续效果：玩家的新捐赠费用将基于每次\$3计算，'
        '而不是原本的\$5。',
    ruleEn:
        'Ongoing effect: as long as this Department contains an active '
        'employee, the costs of the player\'s new donations are calculated on '
        'the basis of \$3 per donation, rather than \$5.',
  ),
  Department(
    number: 13,
    zh: '高级研究',
    en: 'Advanced Research',
    type: DeptType.rnd,
    rule: '玩家必须从这个部门派出1名激活的员工执行任务。然后，玩家获得7个研究点。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission; the player then gains 7 study points.',
  ),
  Department(
    number: 14,
    zh: '高级设计',
    en: 'Advanced Design',
    type: DeptType.rnd,
    rule: '该部门中每有1名激活的员工，玩家就可以获得4个研究点。',
    ruleEn:
        'Whenever this Department is used, its owner gains 4 study points for '
        'each active employee in the Department.',
  ),
  Department(
    number: 15,
    zh: '慈善捐助',
    en: 'Charitable Giving',
    type: DeptType.rnd,
    rule:
        '玩家必须从这个部门派出1名激活的员工执行任务。在支付了适当的捐赠费用后，'
        '玩家必须把自己的1个圆片放在另1位玩家的捐赠圆片之上，'
        '而不能是1个未被占据的格上，玩家不能对同一捐赠项捐赠2次。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. After paying the donation cost, the '
        'player places one of their disks on top of another player\'s donation '
        'disk. A player may not make the same donation twice.',
  ),
  Department(
    number: 16,
    zh: '报务员',
    en: 'Telegraph Operators',
    type: DeptType.rnd,
    ongoing: true,
    rule:
        '持续效果：玩家开发运输轨道所需的研究点'
        '费用减1（至少1点，不能减到0点）。',
    ruleEn:
        'Ongoing effect: as long as this Department contains an active '
        'employee, the player\'s study point costs to progress along '
        'transportation tracks are reduced by 1 (to a minimum of 1).',
  ),
];

/// 확장 #1 "새로운 부서" 16종 (확장 룰북 2–3쪽).
/// 세트 1(17, 21, 25, 29) 파견형 · 세트 2(18, 22, 26, 30) 지역 선택형 ·
/// 세트 3(19, 23, 27, 31) 지속 효과 · 세트 4(20, 24, 28, 32) 게임 종료 득점.
const expansionDepartments = <Department>[
  Department(
    number: 17,
    zh: '人力资源管理',
    en: 'Human Resources Administration',
    type: DeptType.hr,
    expansion: true,
    rule:
        '玩家必须从这个部门派出1名激活的员工执行任务。然后，'
        '玩家的公司中每有1个人力资源部门（包括初始部门），'
        '他就可以把公司图版上的1个员工移动到其公司图版上的另1个格。'
        '以此方式移动后的员工变为未激活的员工。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. Then, for each Human Resources '
        'Department in their Company (including the starting Department), '
        'they may move one employee on their Company board to any other '
        'location within their Company. An employee moved this way becomes '
        'inactive.',
  ),
  Department(
    number: 18,
    zh: '本地合伙人',
    en: 'Local Partners',
    type: DeptType.hr,
    expansion: true,
    rule:
        '玩家必须选择游戏图版上的1个区域。然后，玩家在该区域每有1个已建造的项目，'
        '他就获得\$2或2步员工移动。',
    ruleEn:
        'The player chooses a single region of the map. For each project they '
        'have built in that region, they receive either \$2 OR 2 employee '
        'moves.',
  ),
  Department(
    number: 19,
    zh: '企业沟通',
    en: 'Corporate Communication',
    type: DeptType.hr,
    expansion: true,
    ongoing: true,
    rule:
        '持续效果：在这个回合内，'
        '玩家的员工可以横竖或斜着在公司内移动。',
    ruleEn:
        'Ongoing effect: if this Department contains an active employee at '
        'the beginning of the turn, the player\'s employees may move '
        'diagonally or orthogonally within their Company for the duration of '
        'that turn.',
  ),
  Department(
    number: 20,
    zh: '绿化',
    en: 'Green Spaces',
    type: DeptType.hr,
    expansion: true,
    endgame: true,
    rule:
        '只要在游戏结束时包含1名激活的员工，这个部门在终局计分时就有1个持续效果。'
        '玩家公司图版上每有1个不包含部门的格就获得2分。',
    ruleEn:
        'If this Department contains an active employee at the end of the '
        'game, the player scores 2 VP for each space on their Company board '
        'that does not contain a Department.',
  ),
  Department(
    number: 21,
    zh: '会计',
    en: 'Accounting',
    type: DeptType.management,
    expansion: true,
    rule:
        '玩家必须从这个部门派出1名激活的员工执行任务。然后，'
        '玩家的公司中每有1个管理部门（包括初始部门）就获得\$3。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. The player then receives \$3 for each '
        'Management Department in their Company (including starting '
        'Departments).',
  ),
  Department(
    number: 22,
    zh: '品牌推广',
    en: 'Branding',
    type: DeptType.management,
    expansion: true,
    rule:
        '玩家必须选择游戏图版上的1个区域。然后，玩家在该区域每有1个已建造的项目，'
        '他就获得\$2或1个货物方块。',
    ruleEn:
        'The player chooses a single region of the map. For each project they '
        'have built in that region, they receive either \$2 OR 1 goods cube.',
  ),
  Department(
    number: 23,
    zh: '工资管理',
    en: 'Payroll Management',
    type: DeptType.management,
    expansion: true,
    ongoing: true,
    rule:
        '持续效果：然而，这个效果在其上员工被激活的当轮无法生效。'
        '每当玩家在公司中激活1名员工时，他可以正常支付工位下的费用，'
        '或者多支付\$2来获得1分，或者不考虑费用只支付\$1，但要失去1分。'
        '如果玩家只有0分或更少，就不能选择最后1个选项。',
    ruleEn:
        'Ongoing effect while this Department contains an active employee '
        '(not in the round that employee was activated): when activating an '
        'employee anywhere in their Company, the player may pay \$2 more than '
        'the listed price and gain 1 VP, OR pay \$1 regardless of price and '
        'lose 1 VP (not allowed with 0 or fewer VP).',
  ),
  Department(
    number: 24,
    zh: '公共关系',
    en: 'Public Relations',
    type: DeptType.management,
    expansion: true,
    endgame: true,
    rule:
        '只要在游戏结束时包含1名激活的员工，这个部门在终局计分时就有1个持续效果。'
        '玩家选择1个区域，玩家在该区域中每建造了1个项目，就获得2分。',
    ruleEn:
        'If this Department contains an active employee at the end of the '
        'game, the player gains 2 VP for each project they have built in a '
        'single region of their choice.',
  ),
  Department(
    number: 25,
    zh: '生产线',
    en: 'Production Lines',
    type: DeptType.construction,
    expansion: true,
    rule:
        '玩家必须从这个部门派出1名激活的员工执行任务。然后，'
        '玩家的公司中每有1个建设部门（包括初始部门）就获得1个货物方块。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. The player then receives 1 goods cube '
        'for each Construction Department in their Company (including the '
        'starting Department).',
  ),
  Department(
    number: 26,
    zh: '革新',
    en: 'Renovation',
    type: DeptType.construction,
    expansion: true,
    rule:
        '玩家必须选择游戏图版上的1个区域。然后，玩家在该区域每有1个已建造的项目，'
        '他就获得\$2或1分。',
    ruleEn:
        'The player chooses a single region of the map. For each project they '
        'have built in that region, they receive either \$2 OR 1 VP.',
  ),
  Department(
    number: 27,
    zh: '政治游说',
    en: 'Political Lobbying',
    type: DeptType.construction,
    expansion: true,
    ongoing: true,
    rule:
        '持续效果：玩家可以在类型不匹配的建筑位上建造项目。'
        '如果玩家在小城市或1个类型匹配的建筑位上建造项目，'
        '他获得1分。',
    ruleEn:
        'Ongoing effect: as long as this Department contains an active '
        'employee, the player may build on spaces that do not match the '
        'chosen project type. If the player builds in a small town, or on a '
        'space that matches the chosen project type, they gain 1 VP.',
  ),
  Department(
    number: 28,
    zh: '邮局',
    en: 'Post Office',
    type: DeptType.construction,
    expansion: true,
    endgame: true,
    rule:
        '只要在游戏结束时包含1名激活的员工，这个部门在终局计分时就有1个持续效果。'
        '在统计大城市之间的连接时，玩家的总连接点数加1，最大值为6。'
        '如果玩家最终的连接点数为6，他在连接分上额外获得9分。',
    ruleEn:
        'If this Department contains an active employee at the end of the '
        'game, the player may add 1 connection point when counting '
        'connections between major cities (to a maximum of 6). Finishing with '
        '6 connection points gives a bonus of 9 VP.',
  ),
  Department(
    number: 29,
    zh: '研发协调',
    en: 'R&D Coordination',
    type: DeptType.rnd,
    expansion: true,
    rule:
        '玩家必须从这个部门派出1名激活的员工执行任务。然后，'
        '玩家的公司中每有1个研发部门（包括初始部门）就获得2个研究点。',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. The player then receives 2 study '
        'points for each R&D Department in their Company (including the '
        'starting Department).',
  ),
  Department(
    number: 30,
    zh: '知识共享',
    en: 'Knowledge Sharing',
    type: DeptType.rnd,
    expansion: true,
    rule:
        '玩家必须选择游戏图版上的1个区域。然后，玩家在该区域每有1个已建造的项目，'
        '他就获得\$2或2个研究点。',
    ruleEn:
        'The player chooses a single region of the map. For each project they '
        'have built in that region, they receive either \$2 OR 2 study '
        'points.',
  ),
  Department(
    number: 31,
    zh: '档案',
    en: 'Archives',
    type: DeptType.rnd,
    expansion: true,
    ongoing: true,
    rule:
        '2个持续效果：第1个，在获得运输收入时，根据玩家在任务区运输轨'
        '道上圆片的位置，玩家可以选择低等级的收入。第2个，玩家的运输'
        '圆片可以进入每条运输轨道的最后一格并获得终点奖励，即使那些格'
        '已经有其他玩家的圆片了。',
    ruleEn:
        'Ongoing effects while this Department contains an active employee: '
        'when receiving transport income, the player may choose a lower level '
        'of income than their disk\'s position. Also, their transportation '
        'marker may enter the final box of each transportation track and '
        'receive the end-of-track bonus, even if it is occupied by other '
        'players\' markers.',
  ),
  Department(
    number: 32,
    zh: '图书馆网络',
    en: 'Network of Libraries',
    type: DeptType.rnd,
    expansion: true,
    endgame: true,
    rule:
        '只要在游戏结束时包含1名激活的员工，这个部门在终局计分时就有1个持续效果。'
        '玩家在其建造了最少项目的1个区域中，每建造了1个项目，就获得4分。',
    ruleEn:
        'If this Department contains an active employee at the end of the '
        'game, the player gains 4 VP for each project they built in the '
        'region in which they had built the fewest projects.',
  ),
];

/// 기본판 + 확장 전체 32종.
const allDepartments = <Department>[...departments, ...expansionDepartments];

/// Total copies of each department tile in the box.
const copiesPerDepartment = 2;

/// 규칙서 4쪽: 4/3/2인 게임에서는 부서 타일 4/8/16개를 무작위로 게임 상자에
/// 되돌려 놓습니다. 1인 游戏设置는 2인 게임과 동일합니다(규칙서 18쪽).
const removalByPlayerCount = <int, int>{1: 16, 2: 16, 3: 8, 4: 4};

class DrawResult {
  DrawResult.base(this.playerCount, this.removed)
    : selectedKinds = null,
      mode = GameMode.base;

  DrawResult.expansion(
    this.playerCount,
    this.removed,
    Set<int> this.selectedKinds,
  ) : mode = GameMode.baseExpansion;

  DrawResult.expansionOnly(
    this.playerCount,
    this.removed,
    Set<int> this.selectedKinds,
  ) : mode = GameMode.expansionOnly;

  DrawResult.openSetup(this.playerCount, this.removed)
    : selectedKinds = allDepartments.map((d) => d.number).toSet(),
      mode = GameMode.openSetup;

  final int playerCount;
  final Map<int, int> removed;
  final Set<int>? selectedKinds;
  final GameMode mode;

  bool get isExpansion =>
      mode == GameMode.baseExpansion || mode == GameMode.expansionOnly;

  bool get isBaseExpansion => mode == GameMode.baseExpansion;

  bool get isExpansionOnly => mode == GameMode.expansionOnly;

  bool get isOpenSetup => mode == GameMode.openSetup;

  int get copiesPerDept => copiesPerDepartment;

  /// 이번 게임에 사용하는 부서 종류 목록.
  List<Department> get pool => switch (mode) {
    GameMode.base => departments,
    GameMode.openSetup => allDepartments,
    _ => [
      for (final d in allDepartments)
        if (selectedKinds!.contains(d.number)) d,
    ],
  };

  int removedOf(Department d) => removed[d.number] ?? 0;
  int keptOf(Department d) => copiesPerDept - removedOf(d);

  int get totalRemoved => removalByPlayerCount[playerCount]!;
  int get totalKept => pool.length * copiesPerDept - totalRemoved;
}

DrawResult draw(int playerCount, [Random? random]) {
  final rng = random ?? Random();
  final pool = [
    for (final d in departments)
      for (var i = 0; i < copiesPerDepartment; i++) d.number,
  ]..shuffle(rng);

  final removed = <int, int>{};
  for (final n in pool.take(removalByPlayerCount[playerCount]!)) {
    removed[n] = (removed[n] ?? 0) + 1;
  }
  return DrawResult.base(playerCount, removed);
}

/// 확장 룰북 2쪽 "새로운 부서" 준비: 부서 타일을 유형별로 나눠 유형마다
/// 서로 다른 4종을 무작위로 뽑고(기본판+확장 8종 중), 뽑힌 종류의 페어로
/// 32장을 구성한 뒤 기본 규칙대로 인원수별 제외를 적용합니다.
DrawResult drawExpansion(int playerCount, [Random? random]) {
  final rng = random ?? Random();
  final selected = <int>{};
  for (final type in DeptType.values) {
    final kinds = [
      for (final d in allDepartments)
        if (d.type == type) d.number,
    ]..shuffle(rng);
    selected.addAll(kinds.take(4));
  }

  final pool = [
    for (final n in selected)
      for (var i = 0; i < copiesPerDepartment; i++) n,
  ]..shuffle(rng);

  final removed = <int, int>{};
  for (final n in pool.take(removalByPlayerCount[playerCount]!)) {
    removed[n] = (removed[n] ?? 0) + 1;
  }
  return DrawResult.expansion(playerCount, removed, selected);
}

/// 仅扩展：只从扩展部门中按类型各抽 4 种，共 16 种。
DrawResult drawExpansionOnly(int playerCount, [Random? random]) {
  final rng = random ?? Random();
  final selected = <int>{};
  for (final type in DeptType.values) {
    final kinds = [
      for (final d in expansionDepartments)
        if (d.type == type) d.number,
    ]..shuffle(rng);
    selected.addAll(kinds.take(4));
  }

  final pool = [
    for (final n in selected)
      for (var i = 0; i < copiesPerDepartment; i++) n,
  ]..shuffle(rng);

  final removed = <int, int>{};
  for (final n in pool.take(removalByPlayerCount[playerCount]!)) {
    removed[n] = (removed[n] ?? 0) + 1;
  }
  return DrawResult.expansionOnly(playerCount, removed, selected);
}

/// 开放式设置：基础 + 扩展全部 32 种，每种 1 个。
DrawResult drawOpenSetup(int playerCount, [Random? random]) {
  final rng = random ?? Random();
  final pool = [
    for (final d in allDepartments) d.number, // 每种 1 个
  ]..shuffle(rng);

  final removed = <int, int>{};
  for (final n in pool.take(removalByPlayerCount[playerCount]!)) {
    removed[n] = (removed[n] ?? 0) + 1;
  }
  return DrawResult.openSetup(playerCount, removed);
}
