import 'package:server/server.dart';

class ValidatorUtil {
  /// 校验必填字段
  static void required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      throw BusinessException.badRequest('$fieldName 不能为空');
    }
  }

  /// 校验字符串长度
  static void length(String? value, String fieldName, {int? min, int? max}) {
    if (value == null) return;

    if (min != null && value.length < min) {
      throw BusinessException.badRequest('$fieldName 长度不能少于 $min 个字符');
    }

    if (max != null && value.length > max) {
      throw BusinessException.badRequest('$fieldName 长度不能超过 $max 个字符');
    }
  }

  /// 校验邮箱格式
  static void email(String? value, String fieldName) {
    if (value == null || value.isEmpty) return;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      throw BusinessException.badRequest('$fieldName 格式不正确');
    }
  }

  /// 校验手机号格式
  static void phone(String? value, String fieldName) {
    if (value == null || value.isEmpty) return;

    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      throw BusinessException.badRequest('$fieldName 格式不正确');
    }
  }

  /// 校验数字范围
  static void range(num? value, String fieldName, {num? min, num? max}) {
    if (value == null) return;

    if (min != null && value < min) {
      throw BusinessException.badRequest('$fieldName 不能小于 $min');
    }

    if (max != null && value > max) {
      throw BusinessException.badRequest('$fieldName 不能大于 $max');
    }
  }

  /// 批量校验
  static void validateAll(List<Function> validators) {
    for (final validator in validators) {
      validator();
    }
  }
}
