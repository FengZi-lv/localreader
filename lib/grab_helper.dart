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
class GrabHelper extends ChangeNotifier {
  late WebDriver desktopDriver;
  // WebViewController mobileController = WebViewController();

  String desktopBrowserName;
  String desktopBrowserPath;
  String desktopWebDriverPath;

  late String bookInfoScript;
  late String catalogueScript;
  late String articleScript;

  GrabHelper(
      {this.desktopBrowserName = '',
      this.desktopBrowserPath = '',
      this.desktopWebDriverPath = ''});

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

  // 此调用告诉正在侦听此模型的小部件进行重建。
  // notifyListeners();

  /// 获取目录
  Future<Map> grabCatalogue(url) async => runScript(url, catalogueScript);

  /// 获取书籍信息
  Future<Map> grabBookInfo(url) async => runScript(url, bookInfoScript);

  /// 获取一篇文章
  Future<Map> grabArticle(url) async => runScript(url, articleScript);

  /// 根据目录获取目录内所有文章
  Stream<Map> grabArticleByCatalogue(Map catalogue) async* {
    // catalogue: Map<String,List<String>>
    for (var item in catalogue.keys) {
      for (var url in catalogue[item]) {
        Map result = {};
        try {
          result = runScript(url, articleScript);
        } catch (e) {
          print(e);
          continue;
        }
        yield {'chapter': item, 'result': result['article']};
        break;
      }
    }
  }
}
