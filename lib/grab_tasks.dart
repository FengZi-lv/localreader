import 'package:flutter/foundation.dart' show ChangeNotifier;
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
  Future<void> addCatalogueTask(Map bookInfo) async {
    final taskId = Uuid().v1();
    await FileUtil.createDir(bookInfo['bookName']);
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
    final grabHelper = GrabHelper(
      desktopBrowserName: desktopBrowserName,
      desktopBrowserPath: desktopBrowserPath,
    );
    tasks[taskId] = {
      'status': 'working',
      'success': 0,
      'fail': 0,
      'total': 0,
      'bookInfo': bookInfo
    };
    notifyListeners();

    await grabHelper.init();
    Map result = await grabHelper.grabCatalogue(bookInfo['bookMainURL']);
    grabHelper.dispose();

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

  Future<void> addChapterTask(String taskId) async {}
}
