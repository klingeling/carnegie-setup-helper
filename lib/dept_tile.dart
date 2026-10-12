import 'package:flutter/material.dart';

import 'carbon.dart';
import 'departments.dart';
import 'l10n.dart';

// ---------------------------------------------------------------------------
// 부서 타일 재창작 — 원본 아트워크 없이 부서 정보만으로 컴포넌트와 아이콘을
// 조합해 그린 자체 디자인. 넘버 플레이트·이중 괘선·엠블럼·효과 바를 재사용
// 컴포넌트로 분리해서, 그리드 타일뿐 아니라 상세 시트·도감도 같은 부품을
// 화면 레이아웃에 직접 녹여 쓴다 (미니 타일을 이미지처럼 박지 않는다).
// ---------------------------------------------------------------------------

/// 유형별 식별 컬러 — 앱 팔레트(로즈토프)와 같은 채도·명도 대역의 4색.
const _typeColors = <DeptType, Color>{
  DeptType.hr: CarbonColors.interactive, // 로즈토프 #846A6A
  DeptType.management: Color(0xFF8A7A4F), // 황동
  DeptType.construction: Color(0xFF6D7D62), // 세이지
  DeptType.rnd: Color(0xFF7D6880), // 플럼
};

/// 유형 표식 아이콘.
const _typeIcons = <DeptType, IconData>{
  DeptType.hr: Icons.people_outline,
  DeptType.management: Icons.work_outline,
  DeptType.construction: Icons.domain,
  DeptType.rnd: Icons.science_outlined,
};

/// 부서별 엠블럼 (주 메달, 보조 링) 아이콘 매칭.
const _emblems = <int, (IconData, IconData)>{
  1: (Icons.school_outlined, Icons.people_alt_outlined), // 훈련 + 파트너십
  2: (Icons.person_add_alt_1, Icons.badge_outlined), // 새 직원 + 명찰
  3: (Icons.health_and_safety_outlined, Icons.workspace_premium_outlined),
  4: (Icons.meeting_room_outlined, Icons.weekend_outlined), // 문 + 소파
  5: (Icons.shopping_cart_outlined, Icons.inventory_2_outlined),
  6: (Icons.storefront_outlined, Icons.paid_outlined), // 상점 + 달러
  7: (Icons.local_shipping_outlined, Icons.inventory_2_outlined),
  8: (Icons.apartment_outlined, Icons.vpn_key_outlined), // 건물 + 열쇠
  9: (Icons.engineering_outlined, Icons.construction_outlined),
  10: (Icons.construction_outlined, Icons.map_outlined), // 공구 + 지도
  11: (Icons.link, Icons.inventory_2_outlined), // 사슬 + 큐브
  12: (Icons.campaign_outlined, Icons.volunteer_activism_outlined),
  13: (Icons.science_outlined, Icons.trending_up), // 플라스크 + 상승
  14: (Icons.architecture, Icons.edit_outlined), // 컴퍼스 + 펜
  15: (Icons.volunteer_activism_outlined, Icons.favorite_outline),
  16: (Icons.cell_tower, Icons.bolt), // 송신탑 + 번개
  17: (Icons.badge_outlined, Icons.swap_horiz), // 명찰 + 재배치
  18: (Icons.handshake_outlined, Icons.map_outlined), // 파트너 + 지역
  19: (Icons.forum_outlined, Icons.north_east), // 대화 + 대각 이동
  20: (Icons.park_outlined, Icons.grid_view), // 녹지 + 빈칸
  21: (Icons.calculate_outlined, Icons.paid_outlined), // 회계 + 달러
  22: (Icons.sell_outlined, Icons.map_outlined), // 브랜드 + 지역
  23: (Icons.request_quote_outlined, Icons.star_outline), // 급여 + 승점
  24: (Icons.campaign_outlined, Icons.map_outlined), // 홍보 + 지역
  25: (Icons.precision_manufacturing_outlined, Icons.inventory_2_outlined),
  26: (Icons.home_repair_service_outlined, Icons.map_outlined),
  27: (Icons.account_balance_outlined, Icons.location_city), // 로비 + 건설
  28: (Icons.local_post_office_outlined, Icons.link), // 우체국 + 연결
  29: (Icons.hub_outlined, Icons.science_outlined), // 조정 + 연구
  30: (Icons.share_outlined, Icons.map_outlined), // 공유 + 지역
  31: (Icons.inventory_outlined, Icons.train), // 기록 + 운송
  32: (Icons.local_library_outlined, Icons.public), // 도서관 + 네트워크
};

/// 그리드 타일의 가로:세로 비율. 헤더 확대(+15%), 이미지 확대(+15%),
/// 효과 바 확대(1.3배)를 여백 축소 없이 담기 위해 원본(497:426)보다
/// 세로를 늘렸다.
const deptTileAspect = 400 / 399;

Color deptTypeColorOf(DeptType type) => _typeColors[type]!;
Color deptTypeColor(Department d) => deptTypeColorOf(d.type);
IconData deptTypeIcon(Department d) => _typeIcons[d.type]!;

/// 유형 컬러 넘버 플레이트.
class DeptNumberPlate extends StatelessWidget {
  const DeptNumberPlate({super.key, required this.dept, this.size = 44});

  final Department dept;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: deptTypeColor(dept),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33353B3C),
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '${dept.number}',
        style: TextStyle(
          fontFamily: 'SUIT',
          fontSize: size * 0.5,
          fontWeight: FontWeight.w800,
          color: CarbonColors.textOnColor,
        ),
      ),
    );
  }
}

/// 증서풍 이중 괘선 (유형 컬러 + 흐린 선).
class DeptDoubleRule extends StatelessWidget {
  const DeptDoubleRule({super.key, required this.dept, this.scale = 1});

  final Department dept;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1.5 * scale, color: deptTypeColor(dept)),
        SizedBox(height: 2 * scale),
        Container(height: 1 * scale, color: CarbonColors.borderSubtle),
      ],
    );
  }
}

/// 부서 상징 엠블럼: 주 개념은 솔리드 메달, 보조 개념은 겹친 링으로 표현.
class DeptEmblem extends StatelessWidget {
  const DeptEmblem({super.key, required this.dept, this.scale = 1});

  final Department dept;
  final double scale;

  double _s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    // 시험 버전: 아이콘 메달 조합 대신 규칙서 원본 타일 이미지를 표시한다.
    // 아이콘 엠블럼으로 되돌리려면 아래 return을 지우면 된다.
    return SizedBox(
      width: _s(230),
      height: _s(160),
      child: Image.asset(dept.image, fit: BoxFit.contain),
    );
    // ignore: dead_code
    final (mainIcon, subIcon) = _emblems[dept.number]!;
    final color = deptTypeColor(dept);
    return SizedBox(
      width: _s(230),
      height: _s(160),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 뒤판: 옅은 대형 원.
          Container(
            width: _s(150),
            height: _s(150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.08),
            ),
          ),
          // 주 메달: 솔리드 컬러 + 흰 아이콘.
          Positioned(
            left: _s(32),
            child: Container(
              width: _s(104),
              height: _s(104),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: CarbonColors.background,
                  width: _s(3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40353B3C),
                    offset: Offset(0, _s(3)),
                    blurRadius: _s(6),
                  ),
                ],
              ),
              child: Icon(
                mainIcon,
                size: _s(48),
                color: CarbonColors.textOnColor,
              ),
            ),
          ),
          // 보조 메달: 흰 바탕 링 + 컬러 아이콘, 주 메달에 겹침.
          Positioned(
            right: _s(34),
            bottom: _s(18),
            child: Container(
              width: _s(78),
              height: _s(78),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CarbonColors.background,
                border: Border.all(color: color, width: _s(2.5)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33353B3C),
                    offset: Offset(0, _s(2)),
                    blurRadius: _s(4),
                  ),
                ],
              ),
              child: Icon(subIcon, size: _s(34), color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// 효과 요약 바: 비용 → 보상. 모서리 리벳(철강 모티프), 지속 효과 배지.
class DeptEffectBar extends StatelessWidget {
  const DeptEffectBar({super.key, required this.dept, this.scale = 1});

  final Department dept;
  final double scale;

  double _s(double v) => v * scale;

  /// 부서별 효과 요약 행 (규칙서 16–17쪽 각 부서 효과의 압축 표기).
  List<Widget> _items() {
    return switch (dept.number) {
      1 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$8', tr('获得', 'Gain')),
        _divider(null),
        _item(Icons.directions_walk, '×8', tr('移动', 'Moves')),
      ],
      2 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.add),
        _item(Icons.person_add_alt_1, '×1', tr('大厅', 'Lobby')),
        _divider(null),
        _item(Icons.directions_walk, '×4', tr('移动', 'Moves')),
      ],
      3 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.star, '+1', tr('每2个', 'Per 2')),
      ],
      4 => [
        _item(Icons.inventory_2_outlined, '×2', tr('额外', 'Extra')),
        _divider(Icons.arrow_forward),
        _item(
          Icons.meeting_room_outlined,
          tr('之一', 'Either'),
          tr('大厅', 'Lobby'),
        ),
      ],
      5 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$8', tr('获得', 'Gain')),
        _divider(null),
        _item(Icons.inventory_2_outlined, '×3', tr('货物方块', 'Cubes')),
      ],
      6 => [
        _item(Icons.inventory_2_outlined, '×1~3', tr('支付', 'Pay')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$6', tr('每个', 'Each')),
      ],
      7 => [
        _item(Icons.inventory_2_outlined, '×1~3', tr('支付', 'Pay')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$3', tr('每个', 'Each')),
        _divider(Icons.add),
        _item(Icons.star, '+1', tr('每个', 'Each')),
      ],
      8 => [
        _item(Icons.grid_view, '+1', tr('新部门', 'New Dept.')),
        _divider(Icons.arrow_forward),
        _item(Icons.person, '×1', tr('移动', 'Moves')),
      ],
      9 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.inventory_2_outlined, '×1~2', tr('支付', 'Pay')),
        _divider(Icons.arrow_forward),
        _item(Icons.location_city, '×1', tr('建造', 'Build')),
      ],
      10 => [
        _item(Icons.paid_outlined, '\$3', tr('支付', 'Pay')),
        _divider(Icons.add),
        _item(Icons.inventory_2_outlined, '×1~2', tr('支付', 'Pay')),
        _divider(Icons.arrow_forward),
        _item(Icons.location_city, '×1', tr('建造', 'Build')),
      ],
      11 => [
        _item(Icons.paid_outlined, '\$1', tr('每个', 'Each')),
        _divider(Icons.arrow_forward),
        _item(Icons.inventory_2_outlined, '×1~3', tr('购买', 'Buy')),
      ],
      12 => [
        _item(Icons.person, '×1', tr('激活', 'Active')),
        _divider(Icons.arrow_forward),
        _item(
          Icons.volunteer_activism_outlined,
          '\$3',
          tr('捐赠', 'Donation'),
        ),
      ],
      13 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.science_outlined, '+7', tr('研究点', 'Study')),
      ],
      14 => [
        _item(Icons.person, '×1', tr('每个激活', 'Per active')),
        _divider(Icons.arrow_forward),
        _item(Icons.science_outlined, '+4', tr('研究点', 'Study')),
      ],
      15 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.add),
        _item(Icons.paid_outlined, tr('花费', 'Cost'), tr('支付', 'Pay')),
        _divider(Icons.arrow_forward),
        _item(Icons.favorite, '×1', tr('捐赠', 'Donate')),
      ],
      16 => [
        _item(Icons.person, '×1', tr('激活', 'Active')),
        _divider(Icons.arrow_forward),
        _item(Icons.train, '-1', tr('运输', 'Transport')),
      ],
      // 확장 룰북 2–3쪽 신규 부서 17~32.
      17 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.directions_walk, '×1', tr('每个人力资源', 'Per HR')),
      ],
      18 => [
        _item(Icons.map_outlined, tr('×1', '×1'), tr('区域', 'Region')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$2', tr('每个', 'Each')),
        _divider(null),
        _item(Icons.directions_walk, '×2', tr('每个', 'Each')),
      ],
      19 => [
        _item(Icons.person, '×1', tr('激活', 'Active')),
        _divider(Icons.arrow_forward),
        _item(Icons.north_east, tr('对角线', 'Diag.'), tr('移动', 'Moves')),
      ],
      20 => [
        _item(Icons.grid_view, '×1', tr('每格', 'Per space')),
        _divider(Icons.arrow_forward),
        _item(Icons.star, '+2', tr('分数', 'VP')),
      ],
      21 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$3', tr('每个管理', 'Per Mgmt.')),
      ],
      22 => [
        _item(Icons.map_outlined, tr('×1', '×1'), tr('区域', 'Region')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$2', tr('每个', 'Each')),
        _divider(null),
        _item(Icons.inventory_2_outlined, '×1', tr('每个', 'Each')),
      ],
      23 => [
        _item(Icons.paid_outlined, '+\$2', tr('+1分', '+1 VP')),
        _divider(null),
        _item(Icons.paid_outlined, '\$1', tr('-1分', '-1 VP')),
      ],
      24 => [
        _item(Icons.map_outlined, tr('x1', '×1'), tr('区域', 'Region')),
        _divider(Icons.arrow_forward),
        _item(Icons.star, '+2', tr('每个', 'Each')),
      ],
      25 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.inventory_2_outlined, '×1', tr('每个建设', 'Per Constr.')),
      ],
      26 => [
        _item(Icons.map_outlined, tr('×1', '×1'), tr('区域', 'Region')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$2', tr('每个', 'Each')),
        _divider(null),
        _item(Icons.star, '+1', tr('每个', 'Each')),
      ],
      27 => [
        _item(Icons.location_city, tr('任何', 'Any'), tr('建造', 'Build')),
        _divider(Icons.add),
        _item(Icons.star, '+1', tr('如果匹配', 'If match')),
      ],
      28 => [
        _item(Icons.link, '+1', tr('连接点数', 'Connection')),
        _divider(Icons.arrow_forward),
        _item(Icons.star, '+9', tr('6连接点数', 'At 6 pts')),
      ],
      29 => [
        _item(Icons.person, '×1', tr('任务', 'Mission')),
        _divider(Icons.arrow_forward),
        _item(Icons.science_outlined, '+2', tr('每个研发', 'Per R&D')),
      ],
      30 => [
        _item(Icons.map_outlined, tr('×1', '×1'), tr('区域', 'Region')),
        _divider(Icons.arrow_forward),
        _item(Icons.paid_outlined, '\$2', tr('每个', 'Each')),
        _divider(null),
        _item(Icons.science_outlined, '+2', tr('每个', 'Each')),
      ],
      31 => [
        _item(Icons.train, tr('低等级', 'Lower'), tr('收入', 'Income')),
        _divider(null),
        _item(Icons.flag_outlined, tr('进入', 'Enter'), tr('最后一格', 'Final box')),
      ],
      32 => [
        _item(Icons.map_outlined, tr('最少', 'Fewest'), tr('区域', 'Region')),
        _divider(Icons.arrow_forward),
        _item(Icons.star, '+4', tr('每个', 'Each')),
      ],
      _ => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();
    if (items.isEmpty) return const SizedBox.shrink();
    final rivetGap = _s(7);
    return Container(
      height: _s(72),
      decoration: const BoxDecoration(
        color: CarbonColors.shell,
        border: Border(top: BorderSide(color: Color(0x66FFFFFF), width: 0.5)),
      ),
      child: Stack(
        children: [
          Positioned(left: rivetGap, top: rivetGap, child: _rivet()),
          Positioned(right: rivetGap, top: rivetGap, child: _rivet()),
          Positioned(left: rivetGap, bottom: rivetGap, child: _rivet()),
          Positioned(right: rivetGap, bottom: rivetGap, child: _rivet()),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _s(24)),
                child: Row(
                  children: [
                    if (dept.ongoing) ...[
                      _ongoingBadge(),
                      SizedBox(width: _s(12)),
                    ],
                    if (dept.endgame) ...[
                      _endgameBadge(),
                      SizedBox(width: _s(12)),
                    ],
                    ...items,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 지속 효과 부서(4, 8, 12, 16) 표식.
  Widget _ongoingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _s(6), vertical: _s(3)),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x66FFFFFF)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.all_inclusive,
            size: _s(13),
            color: const Color(0xB3FFFFFF),
          ),
          SizedBox(width: _s(3)),
          Text(
            tr('持续', 'Ongoing'),
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: _s(10),
              fontWeight: FontWeight.w700,
              color: const Color(0xB3FFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  /// 게임 종료 득점 부서(확장 20, 24, 28, 32) 표식.
  Widget _endgameBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _s(6), vertical: _s(3)),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x66FFFFFF)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            size: _s(13),
            color: const Color(0xB3FFFFFF),
          ),
          SizedBox(width: _s(3)),
          Text(
            tr('结束', 'End'),
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: _s(10),
              fontWeight: FontWeight.w700,
              color: const Color(0xB3FFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: _s(20), color: CarbonColors.textOnColor),
            SizedBox(width: _s(4)),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'SUIT',
                fontSize: _s(21),
                fontWeight: FontWeight.w800,
                color: CarbonColors.textOnColor,
              ),
            ),
          ],
        ),
        SizedBox(height: _s(1)),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SUIT',
            fontSize: _s(11),
            fontWeight: FontWeight.w700,
            color: const Color(0xB3FFFFFF),
          ),
        ),
      ],
    );
  }

  /// 아이콘이 있으면 진행(→)·병기(+) 기호, 없으면 '또는' 구분자.
  Widget _divider(IconData? icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _s(12)),
      child: icon != null
          ? Icon(icon, size: _s(18), color: const Color(0x8AFFFFFF))
          : Text(
              tr('或', 'or'),
              style: TextStyle(
                fontFamily: 'SUIT',
                fontSize: _s(11),
                fontWeight: FontWeight.w700,
                color: const Color(0x8AFFFFFF),
              ),
            ),
    );
  }

  /// 효과 바 모서리의 리벳 점.
  Widget _rivet() {
    return Container(
      width: _s(5),
      height: _s(5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x4DFFFFFF),
      ),
    );
  }
}

/// 그리드용 부서 타일. 모든 치수는 기준 폭 400px 시안에 대한 비례값으로,
/// 어느 크기에서든 시안과 같은 비율로 보인다.
class DeptTile extends StatelessWidget {
  const DeptTile({super.key, required this.dept});

  final Department dept;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: deptTileAspect,
      child: LayoutBuilder(
        builder: (context, constraints) =>
            _TileBody(dept: dept, scale: constraints.maxWidth / 400),
      ),
    );
  }
}

class _TileBody extends StatelessWidget {
  const _TileBody({required this.dept, required this.scale});

  final Department dept;
  final double scale;

  double _s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 흐린 보더 하나 + 은은한 그림자로 타일 경계를 잡는다.
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: const Color(0x26353B3C),
            offset: Offset(0, _s(3)),
            blurRadius: _s(8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _s(12)),
            child: DeptDoubleRule(dept: dept, scale: scale),
          ),
          Expanded(
            // 타일 세로 비율을 늘려 확보한 공간만큼 이미지를 크게 보여준다.
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: _s(10)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: DeptEmblem(dept: dept, scale: scale * 1.31),
              ),
            ),
          ),
          // 그리드에서는 효과 바를 30% 키워 가독성을 높인다.
          DeptEffectBar(dept: dept, scale: scale * 1.3),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(_s(12), _s(12), _s(12), _s(8)),
      child: Row(
        children: [
          DeptNumberPlate(dept: dept, size: _s(44)),
          SizedBox(width: _s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 영문 이름은 한글보다 길어 말줄임 대신 폭에 맞게 축소한다.
                if (isEn)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _name(),
                  )
                else
                  _name(),
                SizedBox(height: _s(2)),
                // 보조 이름(다른 언어)은 폭에 맞게 자동 축소해 말줄임 없이 표시한다.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dept.altName.toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'SUIT',
                      fontSize: _s(11),
                      letterSpacing: _s(1.6),
                      fontWeight: FontWeight.w700,
                      color: CarbonColors.textHelper,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: _s(8)),
          // 유형 아이콘: 기준 26, 폰 그리드에서도 최소 16을 보장한다.
          Icon(
            deptTypeIcon(dept),
            size: _s(26) < 16 ? 16 : _s(26),
            color: deptTypeColor(dept),
          ),
        ],
      ),
    );
  }

  Widget _name() {
    return Text(
      dept.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'SUIT',
        // 하단 효과 바 아이콘 크기(20×1.3=26)와 동일하게 맞춘다.
        fontSize: _s(26),
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: CarbonColors.textPrimary,
      ),
    );
  }
}
