import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Shelf 处理器，用于提供 Flutter Asset 中的静态文件
class AssetStaticHandler {
  final String assetPath;
  final String urlPrefix;
  final Map<String, String> mimeTypes;

  AssetStaticHandler({
    this.assetPath = 'assets/web',
    this.urlPrefix = '/static',
    Map<String, String>? mimeTypes,
  }) : mimeTypes = mimeTypes ?? _defaultMimeTypes;

  static final Map<String, String> _defaultMimeTypes = {
    '.html': 'text/html',
    '.htm': 'text/html',
    '.css': 'text/css',
    '.js': 'application/javascript',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.ttf': 'font/ttf',
    '.otf': 'font/otf',
    '.txt': 'text/plain',
    '.xml': 'application/xml',
    '.pdf': 'application/pdf',
  };

  /// 创建 Shelf 处理器
  Handler createHandler() {
    return (Request request) async {
      if (!request.url.path.startsWith(urlPrefix.substring(1))) {
        return Response.notFound('Not found');
      }

      final relativePath = request.url.path.substring(urlPrefix.length - 1);
      if (relativePath.isEmpty || relativePath == '/') {
        return _serveFile('index.html');
      }

      // 移除前导斜杠
      final cleanPath = relativePath.startsWith('/')
          ? relativePath.substring(1)
          : relativePath;

      return _serveFile(cleanPath);
    };
  }

  /// 从 Flutter Asset 中读取文件
  Future<Response> _serveFile(String filePath) async {
    try {
      final fullPath = '$assetPath/$filePath';

      // 使用 rootBundle 读取 Asset 文件
      final ByteData data = await rootBundle.load(fullPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // 获取文件扩展名
      final extension = _getFileExtension(filePath);
      final mimeType = mimeTypes[extension] ?? 'application/octet-stream';

      // 设置缓存头
      final headers = {
        'Content-Type': mimeType,
        'Cache-Control': 'public, max-age=3600',
        'ETag': '"${_calculateETag(bytes)}"',
      };

      return Response.ok(bytes, headers: headers);
    } catch (e) {
      if (e.toString().contains('Unable to load asset')) {
        return Response.notFound('File not found: $filePath');
      }
      return Response.internalServerError(
        body: 'Error serving file: ${e.toString()}',
      );
    }
  }

  /// 获取文件扩展名
  String _getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot).toLowerCase();
  }

  /// 计算 ETag（简单的哈希）
  String _calculateETag(Uint8List bytes) {
    return bytes.length.toRadixString(16);
  }

  /// 创建静态文件处理器（工厂方法）
  static AssetStaticHandler create({
    String assetPath = 'assets/web',
    String urlPrefix = '/static',
    Map<String, String>? mimeTypes,
  }) {
    return AssetStaticHandler(
      assetPath: assetPath,
      urlPrefix: urlPrefix,
      mimeTypes: mimeTypes,
    );
  }
}

/// 快捷创建处理器的方法
Handler createAssetStaticHandler({
  String assetPath = 'assets/web',
  String urlPrefix = '/static',
  Map<String, String>? mimeTypes,
}) {
  return AssetStaticHandler.create(
    assetPath: assetPath,
    urlPrefix: urlPrefix,
    mimeTypes: mimeTypes,
  ).createHandler();
}
