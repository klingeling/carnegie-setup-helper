import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用显示语言（韩语 / 英语）。用第一画面的韩英开关切换。
enum AppLang { ko, en }

/// 当前显示语言。应用启动时由 [loadAppLang] 决定。
final appLang = ValueNotifier<AppLang>(AppLang.ko);

bool get isEn => appLang.value == AppLang.en;

/// 选择与当前语言相符的文案。英文文案遵循英文规则书
/// （rulebook/Carnegie-rules-EN-WEB.pdf, Carnegie_rules_EXPANSION_v5.pdf）的
/// 术语。
String tr(String ko, String en) => isEn ? en : ko;

const _prefsKey = 'app_lang';

/// 起始语言：若有通过韩英开关保存的值则用该值，否则当设备（网页为
/// 浏览器）语言为韩语时用韩语，其他情况用英语。
///
/// Android 的设备 locale 在 main() 执行之后才延迟传入，因此若无保存值，
/// 则一直跟随设备语言变化，直到用户按下开关。
Future<void> loadAppLang() async {
  AppLang? saved;
  try {
    final prefs = await SharedPreferences.getInstance();
    saved = AppLang.values.asNameMap()[prefs.getString(_prefsKey)];
  } catch (_) {
    // 若为无法使用存储的环境（隐私保护模式等），则按设备语言决定。
  }
  if (saved != null) {
    _deviceFollower.stop();
    appLang.value = saved;
  } else {
    _deviceFollower.start();
  }
}

final _deviceFollower = _DeviceLangFollower();

/// 每当设备 locale 传入·变更时匹配显示语言（仅在无保存值时）。
class _DeviceLangFollower with WidgetsBindingObserver {
  bool _active = false;

  void start() {
    if (!_active) {
      _active = true;
      WidgetsBinding.instance.addObserver(this);
    }
    _sync();
  }

  void stop() {
    if (_active) {
      _active = false;
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  void _sync() =>
      appLang.value = langOf(WidgetsBinding.instance.platformDispatcher.locale);

  @override
  void didChangeLocales(List<Locale>? locales) => _sync();
}

/// 与设备 locale 相符的默认语言。
AppLang langOf(Locale locale) =>
    locale.languageCode == 'ko' ? AppLang.ko : AppLang.en;

/// 用韩英开关切换语言，并为下次运行记住该设置。
Future<void> setAppLang(AppLang lang) async {
  _deviceFollower.stop();
  appLang.value = lang;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang.name);
  } catch (_) {
    // 即使保存失败，本次运行的语言切换仍会保持。
  }
}