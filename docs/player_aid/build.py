"""部门玩家助手（A4 横向 1 页）生成器。

直接读取 lib/departments.dart 的部门数据，生成一张自包含的 HTML
（瓷砖图像·字体 base64 内嵌）。运行：python3 docs/player_aid/build.py
"""
import base64
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / 'lib' / 'departments.dart'
OUT = ROOT / 'docs' / 'player_aid' / 'carnegie_dept_player_aid.html'

TYPE_ZH = {'hr': '人力资源', 'management': '管理', 'construction': '建设', 'rnd': '研发'}
TYPE_EN = {'hr': 'Human Resources', 'management': 'Management',
           'construction': 'Construction', 'rnd': 'R&D'}
# lib/dept_tile.dart 的类型四色
TYPE_COLOR = {'hr': '#846A6A', 'management': '#8A7A4F',
              'construction': '#6D7D62', 'rnd': '#7D6880'}
ORDER = ['hr', 'management', 'construction', 'rnd']

# 印刷用缩写效果文本。将 lib/departments.dart 的原文（依据规则书第 16–17 页、
# 扩展规则书第 2–3 页）在不改变含义的前提下缩减。原文变更时这里也要同步。
# '_' = 禁止换行空格（NBSP）：一个语义单位（数值+单位、名词短语）保持在一行，
# 仅在分句边界（→ 前、句号·斜杠·'或' 后）换行。'|' = 强制换行。
SHORT = {
    1: '派出_本部门_1名_激活_员工|→_$8 或 员工_移动_8步',
    2: '二选一: 派出_1名_激活_员工 后 将_1名_新_员工 放到大厅 / 员工_移动_4步',
    3: '派出_1名_激活_员工 →_公司_内_每2名_激活_员工 得_胜利点_1(向上取整)。_派出_员工 不计入',
    4: '组织_时 追加_支付_2个_商品_立方体。此后 将_新_员工·回归_员工 放置到_两个_大厅_中_想要的_一处。 '
       '即使_没有_激活_员工 也_适用的_唯一_部门',
    5: '派出_1名_激活_员工|→_$8 或 3个_商品_立方体',
    6: '支付_1~3个_商品_立方体 →_每个_$6',
    7: '支付_1~3个_商品_立方体 →_每个_$3_+_胜利点_1',
    8: '每当_添加_新_部门_时 可_立即_将_1名_员工(活跃/非活跃) 移动_到_新_部门 (以_非活跃_放置)',
    9: '派出_1名_激活_员工 →_支付_1~2个_商品_立方体，在_派出_地区_建设_1个_项目',
    10: '支付_$3_+_1~2个_商品_立方体 →_无需_派出 在_游戏板_任意处_建设_1个_项目',
    11: '以_每个_$1 购买_1~3个_商品_立方体',
    12: '只要_有_激活_员工 捐赠_费用_基准_$5_→_$3',
    13: '派出_1名_激活_员工 →_研究_分数_7',
    14: '本_部门_每_1名_激活_员工 研究_分数_4',
    15: '派出_1名_激活_员工 + 支付_捐赠_费用 →_在_其他_玩家的_捐赠_圆盘_上 放置_自己的_圆盘。 '
        '同一_捐赠 不可_2次',
    16: '只要_有_激活_员工 运输工具_轨道_前进 研究_分数_费用_−1 (最低_1)',
    17: '派出_本_部门_1名_激活_员工 →_每_1个_公司的_人事_部门 (含_起始_部门) 将_1名_员工 '
        '移动_到_想要的_格 (变为_非活跃_状态)',
    18: '选择_1个_地区|→_该_地区_每_1个_自己的_项目_$2 或 员工_移动_2次',
    19: '回合_开始_时 若_有_激活_员工 则_该_回合_期间 可在_公司_内 沿_对角线_移动_员工',
    20: '游戏_结束_时 若_有_激活_员工 则_公司_板上_每_1个_无_部门_的_空格_胜利点_2',
    21: '派出_本_部门_1名_激活_员工 →_每_1个_公司的_经营_部门 (含_起始_部门) $3',
    22: '选择_1个_地区|→_该_地区_每_1个_自己的_项目_$2 或 1个_商品_立方体',
    23: '只要_有_激活_员工 (已激活_回合_除外) 员工_激活_时_二选一: 支付_明示_费用_+$2 得_胜利点_+1 / '
        '不付_费用 只_支付_$1 得_胜利点_−1 (胜利点_为_0_以下_则_不可)',
    24: '游戏_结束_时 若_有_激活_员工 则_所选_1个_地区_每_1个_自己的_项目_胜利点_2',
    25: '派出_本_部门_1名_激活_员工 →_每_1个_公司的_建设_部门 (含_起始_部门) 1个_商品_立方体',
    26: '选择_1个_地区|→_该_地区_每_1个_自己的_项目_$2 或 胜利点_1',
    27: '只要_有_激活_员工 也可_在_与_项目_种类_不同的_格_建设。若_建在_小城市_或_匹配的_格 得_胜利点_1',
    28: '游戏_结束_时 若_有_激活_员工 则_大城市_连接_分数_+1 (最多_6)。以_连接_6分_结束_时 奖励_胜利点_9',
    29: '派出_本_部门_1名_激活_员工 →_每_1个_公司的_研发_部门 (含_起始_部门) 研究_分数_2',
    30: '选择_1个_地区|→_该_地区_每_1个_自己的_项目_$2 或 研究_分数_2',
    31: '只要_有_激活_员工 可_将_运输_收入_选择_为_低于_自己_位置_的_阶段。 '
        '即使_运输工具_轨道_最后_格_有_车 也_可_进入_并_获得_结束_奖励',
    32: '游戏_结束_时 若_有_激活_员工 则_在_建设_项目_最_少的_地区 每_1个_自己的_项目_胜利点_4',
}


def parse():
    text = SRC.read_text(encoding='utf-8')
    depts = []
    for block in re.findall(r'Department\((.*?)\n  \),', text, re.S):
        def field(name):
            m = re.search(name + r":\s*'(.*?)',\n", block, re.S)
            return m.group(1) if m else None
        number = int(re.search(r'number:\s*(\d+)', block).group(1))
        zh = field('zh')
        en = field('en')
        typ = re.search(r'type:\s*DeptType\.(\w+)', block).group(1)
        # 合并跨多行拼接的 rule 字符串
        rule_m = re.search(r"rule:\s*((?:'.*?'\s*)+),", block, re.S)
        rule = ''.join(re.findall(r"'(.*?)'", rule_m.group(1), re.S))
        rule = rule.replace('\\$', '$')
        depts.append(dict(
            number=number, zh=zh, en=en, type=typ, rule=rule,
            ongoing='ongoing: true' in block,
            expansion='expansion: true' in block,
            endgame='endgame: true' in block,
        ))
    assert len(depts) == 32, len(depts)
    return depts


def b64(path, mime):
    return f'data:{mime};base64,' + base64.b64encode(path.read_bytes()).decode()


def main():
    depts = parse()
    by_num = {d['number']: d for d in depts}
    font_r = b64(ROOT / 'assets/fonts/SUIT-Regular.otf', 'font/otf')
    font_b = b64(ROOT / 'assets/fonts/SUIT-Bold.otf', 'font/otf')
    font_x = b64(ROOT / 'assets/fonts/SUIT-ExtraBold.otf', 'font/otf')

    # 4列（类型）× 9行（标题 1 + 部门 8）网格。行高按该行中最长的
    # 单元格调整，剩余高度按行均匀分配，使 4 列的分隔线对齐。
    items = []
    for typ in ORDER:
        items.append(f'''
    <h2 style="--c:{TYPE_COLOR[typ]}"><span>{TYPE_ZH[typ]}</span><small>{TYPE_EN[typ]}</small></h2>''')
    for row in range(8):
        for ti, typ in enumerate(ORDER):
            base_num = ti * 4 + row + 1
            d = by_num[base_num if row < 4 else base_num + 12]
            img = b64(ROOT / f"assets/departments/dept_{d['number']:02d}.webp",
                      'image/webp')
            tags = []
            if d['ongoing']:
                tags.append('<span class="tag">∞ 持续</span>')
            if d['endgame']:
                tags.append('<span class="tag">⚑ 结束</span>')
            cls = ['cell']
            if d['expansion']:
                cls.append('exp')
            if row == 4:
                cls.append('exp-first')
            if row == 7:
                cls.append('last')
            rule = (SHORT[d['number']].replace('_', '\u00a0').replace('|', '<br>')
                    .replace('→', '<span class="ar">→</span>'))
            items.append(f'''
    <div class="{' '.join(cls)}" style="--c:{TYPE_COLOR[typ]}">
      <img src="{img}" alt="">
      <div class="txt">
        <div class="name"><span class="num">{d['number']}</span>{d['zh']}{''.join(tags)}</div>
        <p class="rule">{rule}</p>
      </div>
    </div>''')

    html = f'''<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="utf-8">
<title>卡内基部门玩家助手</title>
<style>
@font-face {{ font-family: SUIT; font-weight: 400; src: url({font_r}) format('opentype'); }}
@font-face {{ font-family: SUIT; font-weight: 700; src: url({font_b}) format('opentype'); }}
@font-face {{ font-family: SUIT; font-weight: 800; src: url({font_x}) format('opentype'); }}
@page {{ size: A4 landscape; margin: 0; }}
* {{ box-sizing: border-box; margin: 0; padding: 0; }}
html, body {{ background: #fff; }}
body {{
  font-family: SUIT, 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif;
  color: #353B3C; -webkit-print-color-adjust: exact; print-color-adjust: exact;
}}
.page {{
  width: 297mm; height: 210mm; padding: 5mm 6mm 5mm; overflow: hidden;
  display: flex; flex-direction: column;
}}
header {{
  display: flex; align-items: baseline; gap: 4mm; margin-bottom: 2mm;
  border-bottom: 0.5pt solid #C6C7C4; padding-bottom: 1.4mm;
}}
header h1 {{ font-size: 13pt; font-weight: 800; letter-spacing: -0.2pt; }}
header .sub {{ font-size: 7.5pt; color: #7A7477; font-weight: 700; letter-spacing: 1pt; }}
header .legend {{ margin-left: auto; font-size: 7.5pt; color: #5B5F60; display: flex; gap: 4mm; }}
header .legend b {{ font-weight: 700; color: #353B3C; }}
header .legend .sw {{ display: inline-block; width: 3mm; height: 2.2mm; background: #F2EFEF;
  border: 0.4pt solid #C6C7C4; vertical-align: -0.3mm; margin: 0 0.8mm 0 1.5mm; }}
.grid {{
  flex: 1; min-height: 0; display: grid; grid-template-columns: repeat(4, 1fr);
  grid-template-rows: auto repeat(8, auto); column-gap: 2mm; row-gap: 0;
}}
h2 {{
  background: var(--c); color: #fff; font-size: 9.5pt; font-weight: 800;
  padding: 1mm 2mm 0.9mm; display: flex; align-items: baseline; gap: 1.6mm;
  border-radius: 0.6mm 0.6mm 0 0;
}}
h2 small {{ font-size: 6.8pt; font-weight: 400; opacity: .8; letter-spacing: .3pt; }}
.cell {{
  display: flex; gap: 1.8mm; padding: 1mm 1.6mm 0.9mm 1.3mm; align-items: center;
  background: #fff; border: 0.5pt solid #C6C7C4; border-top: 0.4pt solid #DADCDB; border-bottom: 0;
}}
.cell.exp {{ background: #F2EFEF; }}
.cell.exp-first {{ border-top: 0.9pt solid var(--c); }}
.cell.last {{ border-bottom: 0.5pt solid #C6C7C4; }}
.cell img {{ height: 17mm; width: auto; flex: none; align-self: center; }}
.txt {{ flex: 1; min-width: 0; }}
.name {{ font-size: 9.2pt; font-weight: 800; line-height: 1.2; margin-bottom: 0.5mm; }}
.num {{
  display: inline-block; min-width: 4.4mm; padding: 0 0.8mm; margin-right: 1.3mm;
  background: var(--c); color: #fff; font-size: 7.2pt; text-align: center;
  border-radius: 0.5mm; line-height: 1.55; vertical-align: 0.2pt;
}}
.en {{ font-size: 6.4pt; font-weight: 400; color: #8B8589; margin-left: 1.2mm; }}
.tag {{
  display: inline-block; margin-left: 1.2mm; padding: 0 0.9mm; font-size: 6.2pt; font-weight: 700;
  color: var(--c); border: 0.4pt solid var(--c); border-radius: 0.5mm; line-height: 1.5;
  vertical-align: 0.4pt;
}}
.rule {{ font-size: 8.3pt; line-height: 1.32; word-break: keep-all; overflow-wrap: anywhere; }}
.rule .ar {{ font-family: 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif; padding: 0 0.3mm; }}
@media screen {{
  body {{ background: #DADCDB; padding: 10mm 0; }}
  .page {{ margin: 0 auto; box-shadow: 0 2mm 8mm rgba(0,0,0,.18); }}
}}
</style>
</head>
<body>
<div class="page">
  <header>
    <h1>卡内基部门玩家助手</h1>
    <span class="sub">CARNEGIE · DEPARTMENTS</span>
    <div class="legend">
      <span><b>基础</b> 1–16 · <b>扩展</b> 17–32 <span class="sw"></span>阴影格</span>
      <span><b>∞ 持续</b> 只要_有_激活_员工 就_持续_适用</span>
      <span><b>⚑ 结束</b> 游戏_结束_时_得分</span>
    </div>
  </header>
  <div class="grid">{''.join(items)}</div>
</div>
</body>
</html>'''
    OUT.write_text(html, encoding='utf-8')
    print('wrote', OUT, f'{OUT.stat().st_size/1024:.0f} KB')


if __name__ == '__main__':
    main()