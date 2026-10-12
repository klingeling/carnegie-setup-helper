# 卡内基选择器 (Carnegie Setup Helper)

桌游 **卡内基(Carnegie)** 的游戏准备一次性完成的助手应用。
只需选择人数，就会随机抽取需要排除的部门板块和中立圆片摆放，
并把单人游戏流程、规则摘要、部门图鉴、图标参考表都整合在一个应用里。

使用 Flutter 开发，支持 **Android/iOS/网页**。

🌐 **网页版：** https://carnegie-setup-helper.krindale.workers.dev

## 截图

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/01_setup.jpg" width="200"><br><sub>游戏准备</sub></td>
    <td align="center"><img src="docs/screenshots/02_dept_tiles.jpg" width="200"><br><sub>部门板块排除</sub></td>
    <td align="center"><img src="docs/screenshots/03_neutral_disks.jpg" width="200"><br><sub>中立圆片放置</sub></td>
    <td align="center"><img src="docs/screenshots/04_solo_helper.jpg" width="200"><br><sub>单人助手</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/05_rules_summary.jpg" width="200"><br><sub>游戏规则摘要</sub></td>
    <td align="center"><img src="docs/screenshots/06_setup_checklist.jpg" width="200"><br><sub>初始设置检查清单</sub></td>
    <td align="center"><img src="docs/screenshots/07_dept_catalog.jpg" width="200"><br><sub>部门图鉴</sub></td>
    <td align="center"><img src="docs/screenshots/08_icon_reference.jpg" width="200"><br><sub>图标参考表</sub></td>
  </tr>
</table>

## 功能

| 画面 | 说明 |
|---|---|
| **游戏准备** | 选择 1~2 人/3 人/4 人卡片即可一次性完成设置。基础版/含扩展切换。 |
| **部门板块** | 从 32 张（16 种 × 2）中按人数随机排除 16/8/4 个。摘要（仅排除板块）· 详细（16 种全部，按类型分区）切换，重新抽取。板块由类型颜色牌 · 韩/英名称 · 原始板块图像 · 效果摘要栏组成，并附带 🗑×2/🗑×1/✓ 徽章。 |
| **中立圆片** | 模拟 2 人 18 个/3 人 9 个的设置。捐赠图表和城市建设用地（西部·中西部·南部·东部）用地区颜色横幅显示。1 人、4 人显示无摆放提示。 |
| **单人助手** | 与安德鲁·卡内基对战的回合流程 5 阶段、安德鲁行动结算、事件、计分摘要。 |
| **游戏规则摘要** | 回合流程 4 阶段 · 事件 · 部门使用等核心规则摘要，以及初始设置 10 步检查清单表。 |
| **部门图鉴** | 通过基础版/扩展标签，以板块组件 + 规则说明查看 32 种部门。 |
| **图标参考表** | 从规则书中提取 47 个图标（透明背景），并附说明显示。 |
| **1号扩展包** | 新部门(17~32)：从每个类型8种中抽取4种构成32个，然后应用基础排除规则——“选择种类 → 板块排除”两阶段引导。新开始：竞标表($50上限)计算器。 |

## 设计

- Carbon Design System 结构 + 自定义调色板
  `#EEF0F2` 背景 · `#DADCDB` 图层 · `#C6C7C4` 边框 · `#A2999E` 辅助 · `#846A6A` 交互 · `#353B3C` 文字
- 部门类型 4 色：人事 `#846A6A` · 经营 `#8A7A4F` · 建设 `#6D7D62` · 研发 `#7D6880`
- 字体：SUIT (Light · Regular · Bold · ExtraBold)
- 竖屏固定、弹性滚动、无顶栏，采用边角固定图标

## 数据来源

- 部门板块排除规则：规则书第 4 页（设置 4）
- 中立圆片摆放：规则书第 4 页（设置 9） + `CARNEGIE_SETUP_RANDOMIZER__V1.xlsx`
- 单人游戏规则：规则书第 18–19 页
- 扩展 #1（新部门 · 新开始）：扩展规则书第 1–3 页

## 项目结构


```
lib/
  main.dart # 应用/主题，游戏准备，结果（部门板块·中立圆片·单人助手标签）
  carbon.dart # 设计令牌 + 通用组件
  dept_tile.dart # 部门板块组件（编号牌·双线·徽章·效果栏）
  departments.dart # 部门 32 种数据，基础/扩展抽取逻辑
  new_beginning.dart # 扩展“新开始”竞标表计算器
  setup9.dart # 中立圆片（设置 9）卡片数据·摆放逻辑
  reference.dart # 部门图鉴，图标参考表
  rules.dart # 游戏规则摘要
assets/
  departments/ # 部门板块图像 32 种（WebP，透明背景）
  reficons/ # 图标参考表 47 个（WebP）
  pcount/ # 人数图标（WebP）
  fonts/ # SUIT 字体
web/_headers # COOP/COEP —— 用于 wasm 多线程渲染
wrangler.jsonc # Cloudflare Workers 静态资源部署配置
```

关于构建注意事项、资源管线、设计规则等开发细节，请参考 [CLAUDE.md](CLAUDE.md)。

## 运行/构建

```sh
flutter pub get
flutter run -d chrome          # 网页
flutter run                    # 连接的 Android/iOS 设备
flutter build apk --release    # Android
```

### 网页部署（Cloudflare Workers）

推送到 `main` 分支后，GitHub Actions 会自动构建并部署
(`.github/workflows/deploy-web.yml`)。手动部署:

```sh
flutter build web --wasm --release --base-href /
npx wrangler deploy
```
