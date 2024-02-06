import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webdriver/sync_io.dart';
import 'package:flutter/services.dart';

bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

class MobileWebDriver extends StatelessWidget {
  final WebViewController controller;

  const MobileWebDriver({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return const SizedBox.shrink();
    }
    return WebViewWidget(
      controller: controller,
    );
  }
}

/// @example
/// ```dart
/// GrabHelper grabHelper = GrabHelper(
///      desktopBrowserName: 'msedge',
///      desktopBrowserPath:
///          r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
///      desktopWebDriverPath:
///          r"C:\Program Files\Microsoft\Edge\Application\msedgedriver.exe");
///
///  await grabHelper.init();
///  Map bookInfo = await grabHelper.grabBookInfo(
///      'https://cn.ttkan.co/novel/chapters/chixinxuntian-qingheyishen');
///  Map catalogue = await grabHelper.grabCatalogue(
///      'https://cn.ttkan.co/novel/chapters/chixinxuntian-qingheyishen');
///  grabHelper.grabArticleByCatalogue(catalogue).forEach((element) {///
///    print(element);
///  });
/// ```
class GrabHelper {
  late WebDriver desktopDriver;
  // WebViewController mobileController = WebViewController();

  String? desktopBrowserName;
  String? desktopBrowserPath;

  late String bookInfoScript;
  late String catalogueScript;
  late String articleScript;

  GrabHelper({this.desktopBrowserName = '', this.desktopBrowserPath = ''});

  Future<void> init() async {
    if (isDesktop) {
      desktopDriver = createDriver(
          uri: Uri.parse('http://localhost:4444/wd/hub/'),
          desired: {
            'browserName': desktopBrowserName,
            'ms:edgeOptions': {
              'binary': desktopBrowserPath,
            }
          },
          spec: WebDriverSpec.Auto);
    }
    bookInfoScript =
        await rootBundle.loadString('lib/scripts/book_info_analyst.js');
    catalogueScript =
        await rootBundle.loadString('lib/scripts/catalogue_analyst.js');
    articleScript =
        await rootBundle.loadString('lib/scripts/article_analyst.js');
  }

  Map runScript(url, String script) {
    script = '''
      try{
        $script
      }catch(e){
        return {
          "error": e.toString()
        }
      }''';
    Map result = {};
    String currentUrl = '';

    desktopDriver.get(url);

    // 如果页面刷新，则重新执行脚本
    while (true) {
      if (isDesktop) {
        // 桌面端
        currentUrl = desktopDriver.currentUrl;
        // 防止脚本执行超时
        desktopDriver.timeouts.setScriptTimeout(const Duration(days: 7));
        result = desktopDriver.execute(script, []);
        if (desktopDriver.currentUrl == currentUrl) {
          break;
        }
        currentUrl = desktopDriver.currentUrl;
      } else {
        // TODO：移动端待实现
      }
    }
    if (result.containsKey('error')) {
      throw result['error'];
    }
    return result;
  }

  /// 获取目录
  Future<Map> grabCatalogue(url) async => runScript(url, catalogueScript);

  /// 获取书籍信息
  Future<Map> grabBookInfo(url) async => runScript(url, bookInfoScript);

  /// 获取一篇文章
  Future<Map> grabArticle(url) async => runScript(url, articleScript);

  /// 根据目录获取目录内所有文章
  Stream<Map> grabArticleByCatalogue(Map catalogue) async* {
    List failedTask = [];

    for (var item in catalogue.keys) {
      Map result = {};
      int successCount = 0;
      for (var url in catalogue[item]) {
        try {
          result = runScript(url, articleScript);
          if (result.isNotEmpty) break;
        } catch (e) {
          print(e);
          continue;
        }
      }
      if (result.isEmpty) {
        failedTask.add({'$item': catalogue[item]});
        yield {
          'success': false,
          'chapter': item,
          'successCount': successCount,
          'failedTask': failedTask,
        };
      } else {
        yield {
          'success': true,
          'chapter': item,
          'result': result['article'],
          'successCount': ++successCount,
          'failedTask': failedTask,
        };
      }
    }
  }

  /// 销毁
  Future<void> dispose() async {
    if (isDesktop) {
      desktopDriver.quit();
    }
  }
}
