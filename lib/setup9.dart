import 'dart:math';

import 'l10n.dart';

/// 规则书第 4 页设置 9 —— 在 2/3 人游戏中将中立色圆盘布置到游戏板上。
/// 数据来源：CARNEGIE_SETUP_RANDOMIZER__V1.xlsx（单人游戏卡片 20 张）。
///
/// 流程：将卡片按随机顺序一张一张翻开，每张卡片
/// ① 在捐赠图表的标示格中放置 1 个圆盘 →
/// ② 按顺序在卡片的每个城市各放置 1 个圆盘（该城市最左侧的空建筑用地）
/// 放置。当圆盘预算（2 人 18 个，3 人 9 个）耗尽时立即停止
/// （可能在卡片中途中断）。4 人游戏省略此过程。

class SetupCard {
  const SetupCard(this.donation, this.cities);

  /// 捐赠图表格代码（例如：'B3' —— 第 B 行，第 3 格）。
  final String donation;
  final List<String> cities;
}

const setupCards = <SetupCard>[
  SetupCard('D4', ['旧金山', '丹佛']),
  SetupCard('D1', ['匹兹堡', '波士顿', '奥尔巴尼']),
  SetupCard('B5', ['芝加哥', '奥马哈']),
  SetupCard('B4', ['波士顿', '纽约']),
  SetupCard('B3', ['新奥尔良', '亚特兰大']),
  SetupCard('D3', ['新奥尔良', '亚特兰大', '休斯顿', '查尔斯顿']),
  SetupCard('B2', ['奥尔巴尼', '纽约', '华盛顿 D.C.', '匹兹堡']),
  SetupCard('B1', ['辛辛那提', '德卢斯', '圣路易斯', '堪萨斯城']),
  SetupCard('C5', ['纽约', '芝加哥', '新奥尔良', '旧金山']),
  SetupCard('C4', ['波特兰', '博伊西', '丹佛', '洛杉矶']),
  SetupCard('D5', ['堪萨斯城', '芝加哥']),
  SetupCard('C3', ['圣安东尼奥', '孟菲斯', '达拉斯']),
  SetupCard('C2', ['匹兹堡', '纽约']),
  SetupCard('C1', ['法戈', '圣保罗']),
  SetupCard('A5', ['旧金山', '洛杉矶']),
  SetupCard('D2', ['旧金山', '圣菲']),
  SetupCard('A4', ['新奥尔良', '休斯顿']),
  SetupCard('A3', ['波士顿', '华盛顿 D.C.']),
  SetupCard('A2', ['圣路易斯', '芝加哥']),
  SetupCard('A1', ['盐湖城', '里诺']),
];

/// 捐赠图表行名称（A~D）。
const donationRows = <String, String>{
  'A': '教育 (Education)',
  'B': '人权 (Human Rights)',
  'C': '社会福利 (Welfare)',
  'D': '健康 (Health)',
};

/// 捐赠图表行英文名称（英文规则书第 15 页）。
const donationRowsEn = <String, String>{
  'A': 'Education',
  'B': 'Human Rights',
  'C': 'Welfare',
  'D': 'Health',
};

String donationRowName(String row) =>
    tr(donationRows[row]!, donationRowsEn[row]!);

/// 按人数的中立圆盘个数。4 人为 0（省略）。
const disksByPlayerCount = <int, int>{1: 0, 2: 18, 3: 9, 4: 0};

/// 游戏板地图的按地区城市（依据规则书游戏板）。
const cityRegions = <String, List<String>>{
  '西部': ['波特兰', '博伊西', '雷诺', '盐湖城', '旧金山', '洛杉矶', '丹佛'],
  '中西部': ['法戈', '德卢斯', '圣保罗', '奥马哈', '堪萨斯城', '圣路易斯', '芝加哥', '辛辛那提'],
  '南部': ['圣达菲', '达拉斯', '圣安东尼奥', '休斯顿', '孟菲斯', '新奥尔良', '亚特兰大', '查尔斯顿'],
  '东部': ['匹兹堡', '华盛顿', '奥尔巴尼', '纽约', '波士顿'],
};

/// 地区英文名称（英文规则书第 3 页游戏板说明）。
const regionNamesEn = <String, String>{
  '西部': 'West',
  '中西部': 'Midwest',
  '南部': 'South',
  '东部': 'East',
};

/// 城市英文名称（游戏板标注）。
const cityNamesEn = <String, String>{
  '波特兰': 'Portland',
  '博伊西': 'Boise',
  '雷诺': 'Reno',
  '盐湖城': 'Salt Lake City',
  '旧金山': 'San Francisco',
  '洛杉矶': 'Los Angeles',
  '丹佛': 'Denver',
  '法戈': 'Fargo',
  '德卢斯': 'Duluth',
  '圣保罗': 'St. Paul',
  '奥马哈': 'Omaha',
  '堪萨斯城': 'Kansas City',
  '圣路易斯': 'St. Louis',
  '芝加哥': 'Chicago',
  '辛辛那提': 'Cincinnati',
  '圣达菲': 'Santa Fe',
  '达拉斯': 'Dallas',
  '圣安东尼奥': 'San Antonio',
  '休斯顿': 'Houston',
  '孟菲斯': 'Memphis',
  '新奥尔良': 'New Orleans',
  '亚特兰大': 'Atlanta',
  '查尔斯顿': 'Charleston',
  '匹兹堡': 'Pittsburgh',
  '华盛顿': 'Washington',
  '奥尔巴尼': 'Albany',
  '纽约': 'New York',
  '波士顿': 'Boston',
};

String regionName(String region) => tr(region, regionNamesEn[region]!);
String cityName(String city) => tr(city, cityNamesEn[city]!);

class DiskSetup {
  DiskSetup(this.playerCount, this.donations, this.cityDisks);

  final int playerCount;

  /// 按布置顺序的捐赠图表格代码。
  final List<String> donations;

  /// 城市 → 要放置的圆盘个数（保持布置顺序）。
  final Map<String, int> cityDisks;

  int get totalDisks => disksByPlayerCount[playerCount]!;
  int get cityTotal => cityDisks.values.fold(0, (a, b) => a + b);
}

DiskSetup drawDisks(int playerCount, [Random? random]) {
  final rng = random ?? Random();
  var budget = disksByPlayerCount[playerCount]!;
  final donations = <String>[];
  final cityDisks = <String, int>{};
  if (budget == 0) return DiskSetup(playerCount, donations, cityDisks);

  final deck = [...setupCards]..shuffle(rng);
  for (final card in deck) {
    if (budget <= 0) break;
    donations.add(card.donation);
    budget--;
    for (final city in card.cities) {
      if (budget <= 0) break;
      cityDisks[city] = (cityDisks[city] ?? 0) + 1;
      budget--;
    }
  }
  return DiskSetup(playerCount, donations, cityDisks);
}