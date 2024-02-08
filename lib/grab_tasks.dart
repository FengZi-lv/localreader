import 'package:flutter/foundation.dart' show ChangeNotifier, compute;
import 'package:local_reader/file_util.dart';
import 'package:local_reader/grab_helper.dart';
import 'package:uuid/uuid.dart';

class GrabTasksHelper extends ChangeNotifier {
  final String? desktopBrowserName;
  final String? desktopBrowserPath;

  GrabTasksHelper({this.desktopBrowserName = '', this.desktopBrowserPath = ''});

  /// 任务列表
  /// @example
  /// ```dart
  /// {
  ///  'taskUUID': {
  ///    'status': 'working', // working, done, stop
  ///    'success': 10,
  ///    'fail': 0,
  ///    'total': 10,
  ///    'bookInfo':{
  ///      'bookName': 'bookName',
  ///      'bookAuthor': 'bookAuthor',
  ///      'bookMainURL': 'bookMainURL', n
  ///      'bookCover': 'bookCoverURL',
  ///      'bookDic': 'bookDicPath',
  ///      'bookCatalogue': {
  ///         '1':{
  ///          'name': 'title',
  ///          'url': ['url','url']
  ///          'status': 'downloaded', // downloaded,undownloaded
  ///          'localPath': 'localPath'
  ///           }
  ///         }
  ///    },
  /// }
  /// ```
  Map tasks = {};

  Future<void> initTasks() async {
    tasks = await FileUtil.readJsonFile('tasks.json');
    notifyListeners();
  }

  /// 添加任务
  /// @param bookInfo 书籍信息
  /// @example
  /// ```dart
  /// 'bookInfo':{
  ///      'bookName': 'bookName',
  ///      'boookMainURL': 'bookMainURL',
  ///      'bookAuthor': 'bookAuthor',
  ///      'bookCover': 'bookCoverURL',
  /// }
  /// ```
  Future<void> addCatalogueTask(List args) async {
    final taskId = const Uuid().v1();
    await FileUtil.createDir(args[0]['bookName']);
    /*
    bookInfo['bookCatalogue'] = bookInfo['bookCatalogue'].map((title, url) {
      return {
        'title': title,
        'url': url,
        'bookDic': bookInfo['bookName'],
        'status': 'undownloaded',
        'localPath': ''
      };
    });
    */

    tasks[taskId] = {
      'status': 'working',
      'success': 0,
      'fail': 0,
      'total': 0,
      'bookInfo': args[0]
    };
    notifyListeners();

    await args[1].init();
    Map result = await args[1].grabCatalogue(args[0]['bookMainURL']);
    args[1].dispose();

    tasks[taskId]?['status'] = 'done';
    tasks[taskId]?['total'] = result.length;
    tasks[taskId]?['bookInfo']['bookCatalogue'] =
        result.map((key, value) => MapEntry(key, {
              'name': value['title'],
              'url': value['url'],
              'status': 'undownloaded',
              'localPath': ''
            }));
    print(tasks);
  }

  /// 异步添加目录任务
  Future<void> addCatalogueTaskAsync(Map bookInfo) async {
    final grabHelper = GrabHelper(
      desktopBrowserName: desktopBrowserName,
      desktopBrowserPath: desktopBrowserPath,
    );
    await grabHelper.initScript();
    compute(addCatalogueTask, [bookInfo, grabHelper]);
  }

  Future<void> addChapterTask(String taskId) async {}
}
