import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:local_reader/task_page.dart';
import 'package:local_reader/setting_page.dart';
import 'package:local_reader/grab_tasks.dart';
import 'package:local_reader/add_task_page.dart';
import 'dart:io';

const Map<String, String> desktopWebDriverInfo = {
  'desktopBrowserName': 'msedge',
  'desktopBrowserPath':
      r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
};

void main() async {
  // 窗口初始化
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    title: "LocalReader",
    size: Size(900, 600),
    minimumSize: Size(800, 600),
    fullScreen: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlignment(Alignment.center);
  });

  Provider.debugCheckInvalidValueType = null;

  runApp(MultiProvider(
    providers: [
      Provider<GrabTasksHelper>(
          create: (_) => GrabTasksHelper(
                desktopBrowserName: desktopWebDriverInfo['desktopBrowserName'],
                desktopBrowserPath: desktopWebDriverInfo['desktopBrowserPath'],
              )),
    ],
    child: const MyApp(),
  ));
}

bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

int taskCount = 0;

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    print('init');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            groupAlignment: -1.0,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: const AddBookButton(),
            destinations: <NavigationRailDestination>[
              const NavigationRailDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book_rounded),
                label: Text('书架'),
              ),
              NavigationRailDestination(
                icon: Badge(
                  label: Text(taskCount.toString()),
                  isLabelVisible: taskCount != 0,
                  child: const Icon(Icons.checklist_rtl),
                ),
                selectedIcon: Badge(
                  label: Text(taskCount.toString()),
                  isLabelVisible: taskCount != 0,
                  child: const Icon(Icons.checklist_rtl_outlined),
                ),
                label: const Text('任务'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: Text('设置'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 0.5, width: 0.5),
          Expanded(
              child: Column(
            children: [
              DragToMoveArea(
                child: AppBar(
                  forceMaterialTransparency: true,
                  title: Text(pages[_selectedIndex]['title']),
                  actions: [
                    if (isDesktop)
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                windowManager.minimize();
                              },
                              icon: const Icon(Icons.expand_more_rounded),
                            ),
                            IconButton(
                              onPressed: () {
                                windowManager.close();
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              pages[_selectedIndex]['child'] as Widget,
            ],
          )),
        ],
      ),
    );
  }
}

const List<Map<String, dynamic>> pages = [
  {
    'title': '书架',
    'child': Center(
      child: Text('书架'),
    )
  },
  {'title': '任务', 'child': TaskPage()},
  {'title': '设置', 'child': SettingPage()}
];
