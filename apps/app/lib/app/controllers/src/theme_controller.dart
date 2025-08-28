import 'package:core/core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeController extends GetxService with AppLogMixin {
  Rx<String> flexScheme = ''.obs;
  Rx<String> themeMode = ''.obs;

  Map<String, FlexScheme> flexSchemeMap = {
    // '绿色M3': FlexScheme.greenM3,
    // '深蓝石': FlexScheme.bigStone,
    // '蓝色M3': FlexScheme.blueM3,
    // '青色M3': FlexScheme.cyanM3,
    // '水鸭M3': FlexScheme.tealM3,
  };

  Map<String, ThemeMode> themeModeMap = {
    '系统': ThemeMode.system,
    '深色': ThemeMode.dark,
    '浅色': ThemeMode.light,
  };

  InputDecorationTheme inputDecorationTheme = const InputDecorationTheme(
    border: OutlineInputBorder(),
  );

  ThemeData getThemeData() {
    return FlexThemeData.light(
      scheme: flexSchemeMap[flexScheme.value],
    ).copyWith(
      textTheme: GoogleFonts.notoSansScTextTheme(),
      inputDecorationTheme: inputDecorationTheme,
    );
  }

  ThemeData getDarkThemeData() {
    var themeData = FlexThemeData.dark(scheme: flexSchemeMap[flexScheme.value]);
    var colorScheme = themeData.colorScheme;
    return themeData.copyWith(
      inputDecorationTheme: inputDecorationTheme,
      textTheme: GoogleFonts.notoSansScTextTheme(
        ThemeData.dark(
          useMaterial3: true,
        ).copyWith(colorScheme: colorScheme).textTheme,
      ),
    );
  }

  ThemeMode getThemeMode() {
    final key = themeModeMap.keys.firstWhere(
      (key) => key == themeMode.value,
      orElse: () => themeModeMap.keys.first.toString(),
    );
    return themeModeMap[key]!;
  }

  Future changeTheme(FlexScheme scheme) async {
    final key = flexSchemeMap.keys.firstWhere(
      (key) => flexSchemeMap[key] == scheme,
      orElse: () => flexScheme.value,
    );
    flexScheme.value = key;
    await Storage().set(StorageKeys.flexScheme, key);
    Get.changeTheme(getThemeData());
  }

  Future changeThemeMode(ThemeMode mode) async {
    final key = themeModeMap.keys.firstWhere(
      (key) => themeModeMap[key] == mode,
      orElse: () => themeMode.value,
    );
    themeMode.value = key;
    await Storage().set(StorageKeys.themeMode, key);
    Get.changeThemeMode(mode);
  }

  void init() {
    //注册主题
    for (var e in FlexScheme.values) {
      flexSchemeMap[e.name] = e;
    }

    var defaultScheme = findKeyByValue(flexSchemeMap, FlexScheme.blueM3)!;
    var defaultThemeMode = findKeyByValue(themeModeMap, ThemeMode.dark)!;

    flexScheme.value = Storage()
        .get(StorageKeys.flexScheme)
        .parseString(defaultValue: defaultScheme);
    themeMode.value = Storage()
        .get(StorageKeys.themeMode)
        .parseString(defaultValue: defaultThemeMode);
    logger.log('加载主题: ${flexScheme.value}, 主题模式 ${themeMode.value}');
  }

  String? findKeyByValue(Map<String, dynamic> map, dynamic value) {
    try {
      return map.keys.firstWhere((key) => map[key] == value);
    } catch (e) {
      return null; // 未找到返回 null
    }
  }
}
