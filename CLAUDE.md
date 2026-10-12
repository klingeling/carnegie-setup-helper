# CLAUDE.md

卡内基（Carnegie）桌游设置助手 Flutter 应用。支持 Android / iOS / 网页。

## 基本方针（适用于所有工作的最高优先级）

0. **只有在明确指示时才进行提交·推送。** 尤其是推送到 main 会自动触发
   Cloudflare 公开部署（`.github/workflows/deploy-web.yml`），因此绝对
   不可擅自执行。供用户确认时使用本地网页服务
   （`build/web`，固定端口 7777）展示。
0-1. **应用 UI 中不得出现"规则书"这一表述或页码引用。** 依据引用（规则书第 n 页）
   只保留在本文档和代码注释中。
0-2. **不得擅自删除分支。** 即使 PR 合并后，分支也要在本地和远程都保留
   （禁止 `gh pr merge --delete-branch`、`git branch -d`、
   `git push origin --delete`）。只有在明确指示时才删除。

1. **不得对规则·事实擅自下断言。** 陈述游戏规则等事实时，必须引用规则书
   原文并附上依据。误读案例：单人游戏也要布置设置 9 的 18 个中立圆片
   ——安德鲁跳过的只是设置 10。
2. **只修改明确指示的内容。** "确认一下"仅止于确认·报告。
   即使是看起来明显正确的修改，也要先报告并等待批准。
   禁止修改未指示的布局重构·元素添加。
3. **未经检查不得发布。** 在安装·部署前，直接确认结果物（画面、图像、动作），
   只发布通过检查的内容。

## 构建（重要：Windows 中文路径问题）

如果项目位于中文路径（`바탕 화면`）下，Flutter 着色器编译器
（impellerc）会崩溃。**必须在 ASCII 映射驱动器上构建：**

```bat
subst X: "C:\Users\wow32\OneDrive\바탕 화면\canegie-department"
```

标准验证·部署流程（bash，`X:` = `/x`）：

```sh
cd /x/carnegie_departments
dart format lib && flutter analyze && flutter test
flutter build web && flutter build apk --release
"C:\Users\wow32\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r build/app/outputs/flutter-apk/app-release.apk
```

- 供用户确认的安装始终使用 **发布版 APK**（调试版滚动会卡顿）。
- **Mac 构建**：Android Studio 捆绑的 JDK（Java 25）与 Gradle 8.14 不兼容——
  仅在构建时指定 JDK 17（禁止更改全局设置）：
  `J=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home;
  JAVA_HOME=$J GRADLE_OPTS="-Dorg.gradle.java.home=$J" flutter build apk --release`。
  每台 PC 的调试签名密钥不同，Windows↔Mac 构建交替安装会出现
  `INSTALL_FAILED_UPDATE_INCOMPATIBLE`——删除现有应用后再安装（用户确认）。
- 网页确认：**用 `flutter build web --pwa-strategy=none` 构建**（移除 Service
  Worker），并将 `build/web` **只用固定端口 7777** 提供服务
  （`python -m http.server 7777`）。如果服务器已启动则复用——
  不要每次都更换端口（用户指示，2026-09-06）。过去的"每次换新端口"
  规则是因为 Service Worker 缓存，pwa-strategy=none 已消除该原因。
  服务前用 PowerShell 终止残留的 python http.server 监听器进行清理。
- UI 方案稿（HTML 原型）也**只用固定端口 7778** 提供服务（用户指示）。
  方案文件集中在一个文件夹中并复用同一服务器，确认用标签页要
  保持打开以便用户查看。
- 更改板块设计时重新生成黄金测试：
  `flutter test --update-goldens test/dept_tile_golden_test.dart`。
  在 widget 测试中字体加载必须在 setUpAll 中进行（testWidgets 正文是
  FakeAsync 区，实际文件 I/O 无法完成会导致死锁）。同理，
  黄金测试中资源图像会显示为空（用于布局验证）。

## 代码结构

- `lib/main.dart` — 应用/主题、游戏准备画面、结果画面（标签：部门板块 / 中立
  圆片 / 单人助手）、摘要栏、详情表、圆片列表卡。结果网格中
  板块本身就是单元格（无卡片外壳，仅叠加状态徽章）
- `lib/dept_tile.dart` — 部门板块组件。可复用部件：
  `DeptNumberPlate`（类型色彩板）· `DeptDoubleRule`（双规线）·
  `DeptEmblem`（中央图像/徽章）· `DeptEffectBar`（效果摘要栏）·
  `deptTypeColor/Of`、`deptTypeIcon`。`DeptTile` 将这些部件按基准宽度 400px
  方案稿的**比例值**组装（禁止 FittedBox 缩放——用户已确认）。
  详情表·图鉴也用相同部件按画面宽度直接布置（禁止迷你板块）。
  类型四色：人事 #846A6A / 经营 #8A7A4F / 建设 #6D7D62 / 研发 #7D6880——
  区块标题左侧竖条也遵循这些颜色。
  当前 `DeptEmblem` 显示原始板块图像（混合方式）——图标奖章
  组合代码保留为紧接其下的 dead_code，转为商店用时可恢复。
- `lib/carbon.dart` — 设计令牌（CarbonColors/Text/Spacing）和公共组件
  （CarbonButton、CarbonTag、CarbonContentSwitcher、TopBar、TopIconButton）
- `lib/departments.dart` — 部门 32 种数据（基础 1~16 + 扩展 17~32，
  `expansion`/`endgame` 字段）、按人数的排除数
  （`removalByPlayerCount`：1人=16，2人=16，3人=8，4人=4）、`draw()`、
  `drawExpansion()`（每类型 8 种中取 4 种 → 配对 32 张 → 基础排除规则，
  扩展规则书第 2 页）
- `lib/new_beginning.dart` — 扩展"新的开始"竞标表计算器
  （表格数值已按扩展规则书第 1 页验证：立方体 2~6=$6/9/12/15/18，
  大厅员工 3免费~7=$32，胜利点 -6=+$12~+6=$12，移动 4~10=$5/8/10/15/20，
  总和≤$50）
- `lib/setup9.dart` — 设置 9（中立圆片）卡片 20 张数据、按地区的城市
  （`cityRegions`）、`drawDisks()`（1人/4人 = 0 个）
- `lib/reference.dart` — 部门图鉴、图标参考表画面
- `lib/l10n.dart` — 中/英显示语言。用 `tr(zh, en)` 选择文案，数据用
  `zh`/`en` 对（`Department.ruleEn`、`cityNamesEn` 等）。起始语言 =
  保存的开关值（`shared_preferences`，网页为 localStorage）→ 若无则按设备·
  浏览器语言（中文则 ZH，其他 EN）。Android 的 locale 在 main() 之后
  延迟到达，因此若无保存值则跟随设备语言直到按下开关。
  英文文案遵循 `rulebook/` 中的英文规则书（基础·扩展，git 未包含）术语。

## 设计规则（用户已确认事项——须遵守）

- 调色板：`#EEF0F2`（背景）`#DADCDB`（层）`#C6C7C4`（边框）`#A2999E`（助手）
  `#846A6A`（交互）`#353B3C`（文本）。**绝对禁止蓝色按钮。**
- 色调降低用 **alpha 值而非更改颜色**（例如 `0x99DA1E28`）。
- 画面切换：`CupertinoPageTransitionsBuilder`（禁止自定义动画）。
- 滚动：全局应用 `BouncingScrollPhysics`。竖屏固定。
- 无顶部栏——返回/操作图标固定在画面角落（TopBar）。
- 文本左对齐，**仅板块图像居中对齐**。
- 只修改指示的元素。不得擅自重构布局。

## 资源管线

资源是从上层文件夹的 PDF 中用 PyMuPDF 提取的（`../카네기_규칙서.pdf`）。

- `assets/departments/dept_01~16.webp` — 规则书第 16–17 页按 300dpi 剪辑渲染
  后用边框泛洪填充将背景透明化。（禁止使用内嵌栅格，因其标签被裁切）
  当前显示在 `DeptTile` 的中央徽章槽位（网格中放大 20% +
  上下留白）。因版权原因不可用于商店发布——若上架商店则转为图标徽章
  并将此文件夹从打包中排除。
- `assets/departments/dept_17~32.webp` — 扩展规则书第 2–3 页。**禁止内嵌栅格
  （矩形圆片）**——页面会用矢量重绘模切边框，因此必须
  300dpi 剪辑渲染 + 泛洪填充透明化（`../extract_expansion_tiles.py`）。
- `assets/reficons/i01~47.webp` — 规则书第 20 页图标参考表。**保持原始相对
  大小**（通用缩放），画布宽度固定 180px·高度为实际高度（节省行高），
  仅超出 180px 的部分缩放。顺序：i09=活跃员工，i10=非活跃（有交换历史，注意）。
- `assets/pcount/p1~4.webp` — 规则书第 20 页游戏准备参考表的人数图标
  （p1 从 p2 中只裁剪出前面的人）。
- `assets/icon/` — 应用图标（规则书第 9 页人事六边形图标）。
  用 `dart run flutter_launcher_icons` 重新生成。
- 地区颜色（规则书第 15 页横幅）：西部 `#C2B49B` 中西部 `#C0503C` 南部 `#65A76B`
  东部 `#885F88`（main.dart 中的 `regionColors`）。

## UI 模式（用户已确认）

- 区块标题：**白色卡片**（背景 #FFFFFF + 淡边框 #E4E6E7 + 左侧彩色竖条
  4px）。结果画面·规则摘要·图鉴·计算器通用。摘要栏统计卡片也用白色。
- **重新抽取 = 第一个区块标题右侧的方形边框洗牌图标**（36px，
  `_rerollIconButton`）。部门板块·中立圆片通用。无单独按钮行，
  人数变更用返回代替。
- 扩展摘要 = "选择种类（按类型的可用编号芯片，`_KindCleanupCard`）→
  板块排除（类型→编号排序网格）"纵向两阶段。详情中也有种类选择卡片。
- 第一画面：顶部图标与详细页面相同的 `TopBar`（正文列内，左右 16 ·
  上 8）。**中英开关**（`ZH | EN`，`CarbonContentSwitcher(dense: true)`）
  为 **86×29px**（格子固定 42px，`_langSegmentWidth`·`_langSwitchHeight`——
  与 69px 和 104px 比较后取中间值确定）。放在上标线行高上，右端线
  对齐图标参考表图标字形。图标与开关间距 15px
  （`_homeHeaderTop`）。仅在窄宽度（约 310px 以下）时缩小上标线文字以
  与开关保持 8px 间距。
- 英文模式下以"英文标题 + 中文副标题"反转中文版布局显示。
- 部门图鉴基础版/扩展说明用 `IndexedStack` 固定高度（切换时禁止抖动）。
- 部门图鉴标题行始终一行：英文为 `Departments` + `Base | Expansion`，
  若原尺寸放不下则将标题改为 `Depts.`（用户已确认）。
- 英文模式布局原则：禁止单词中间换行。窄格中的长英文单词用
  `WordSafeText`（carbon.dart）仅缩小到该单词能放入的程度，可能溢出的
  单行元素（结果标签行、第一画面基础版/扩展开关）仅在溢出时用 `FittedBox`
  缩小。`test/layout_scan_test.dart` 在手机宽度 320·360·390 × 字体 1·1.3 倍 ×
  韩/英全画面下检查横向溢出和英文单词中间换行。
- 摘要↔详情切换时共同元素（标题·摘要栏·第一个标题）的位置不得抖动
  （模式间保持底部留白相同）。

## 游戏规则依据

- 部门板块：32 个（16 种×2）中 4/3/2 人 = 随机排除 4/8/16 个（规则书第 4 页设置 4）
- 中立圆片：2/3 人 = 18/9 个。每张卡捐赠 1 个 + 每城市 1 个，预算耗尽时
  即使卡片中途也立即停止（设置 9，数据：`../CARNEGIE_SETUP_RANDOMIZER__V1.xlsx`）
- 单人：准备与 2 人相同，但**不布置中立圆片**（规则书第 18 页）。
  单人助手标签内容为规则书第 18–19 页摘要。
- 扩展"新部门"：每类型从 8 种中抽取互不相同的 4 种构成配对 32 张后
  应用基础排除规则（扩展规则书第 2 页）。套组3（19·23·27·31）=持续，
  套组4（20·24·28·32）=游戏结束得分（`endgame`）。原始 PDF：
  `../Carnegie-rules-EXPANSION-EN-WEB.pdf`