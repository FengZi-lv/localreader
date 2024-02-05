import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:local_reader/task_page.dart';
import 'package:local_reader/setting_page.dart';
import 'package:local_reader/grab_helper.dart';
import 'dart:io';

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
  runApp(const MyApp());
}

bool get isDesktop {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

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
  final TextEditingController _textEditingController = TextEditingController();
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
            leading: FloatingActionButton(
              elevation: 0,
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('添加图书'),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.help_outline_rounded))
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            TextField(
                              controller: _textEditingController,
                              autofocus: true,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '图书链接',
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FilledButton(
                          child: const Text('获取'),
                          onPressed: () {
                            taskCount++;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('任务已添加'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            ),
            // trailing:
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
