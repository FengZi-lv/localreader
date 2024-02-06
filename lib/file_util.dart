import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileUtil {
  static Future<Directory> appDocPath = getApplicationDocumentsDirectory();

  /// 创建文件夹
  static Future<void> createDir(String pathSegment) async {
    String fullPath = path.join((await appDocPath).path, pathSegment);
    Directory dir = Directory(fullPath);
    if (await dir.exists()) {
      return;
    }
    await dir.create();
  }

  /// 删除文件夹
  static Future<void> deleteDir(String pathSegment) async {
    String fullPath = path.join((await appDocPath).path, pathSegment);
    Directory dir = Directory(fullPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// 写入文件，如果文件不存在则创建
  static Future<void> writeFile(String pathSegment, String content) async {
    String fullPath = path.join((await appDocPath).path, pathSegment);
    File file = File(fullPath);
    if (!await file.exists()) {
      await file.create();
    }
    await file.writeAsString(content);
  }

  /// 读取文件
  static Future<String> readFile(String pathSegment) async {
    String fullPath = path.join((await appDocPath).path, pathSegment);
    File file = File(fullPath);
    if (!await file.exists()) {
      writeFile(pathSegment, '');
      return '';
    }
    return await file.readAsString();
  }

  /// 读取JSON文件
  static Future<Map<String, dynamic>> readJsonFile(String pathSegment) async {
    return jsonDecode(await readFile(pathSegment));
  }

  /// 写入JSON文件
  static Future<void> writeJsonFile(
      String pathSegment, Map<String, dynamic> content) async {
    await writeFile(pathSegment, jsonEncode(content));
  }

  /// 删除文件
  static Future<void> deleteFile(String pathSegment) async {
    String fullPath = path.join((await appDocPath).path, pathSegment);
    File file = File(fullPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
