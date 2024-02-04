import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Variables for automation driver settings
  String selectedBrowserType = 'Chrome';
  String selectedBrowserVersion = '';
  String browserPath = '';
  bool isWebDriverReloaded = false;
  String webDriverPath = '';

  // Variables for file storage settings
  String bookDownloadPath = '';
  String tempFilePath = '';
  String dataFilePath = '';

  // Variables for reader preferences
  String themeType = 'systemTheme';

  // Variables for reader preferences
  // TODO: Add reader preference variables

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 60,
      child: Stack(
        children: [
          ListView(
            // itemExtent: 60,
            padding: const EdgeInsets.all(16.0),
            children: [
              // 外观
              const Text('外观',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                      value: "lightTheme",
                      label: Text('浅色主题'),
                      icon: Icon(Icons.light_mode_rounded)),
                  ButtonSegment<String>(
                      value: "darkTheme",
                      label: Text('深色主题'),
                      icon: Icon(Icons.dark_mode_rounded)),
                  ButtonSegment<String>(
                      value: "systemTheme",
                      label: Text('跟随系统'),
                      icon: Icon(Icons.auto_mode_rounded)),
                ],
                selected: <String>{themeType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    themeType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 外观
              const Text('阅读器外观',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Pass
              const SizedBox(height: 16),

              // 抓取
              Row(
                children: [
                  const Text('网络抓取及数据解析',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  // const SizedBox(width: 12),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.help_outline_rounded))
                ],
              ),
              const SizedBox(height: 12),
              // Pass
              const SizedBox(height: 16),

              // Automation driver settings
              Row(
                children: [
                  const Text('网络自动化驱动',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  // const SizedBox(width: 12),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.help_outline_rounded))
                ],
              ),
              const SizedBox(height: 12),
              // const SizedBox(height: 26.0),
              DropdownMenu<String>(
                label: const Text('浏览器类型'),
                initialSelection: 'Chrome',
                onSelected: (String? value) {
                  setState(() {
                    selectedBrowserType = value!;
                  });
                },
                dropdownMenuEntries: ['Chrome', 'Edge', 'Firefox']
                    .map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),

              TextField(
                decoration: const InputDecoration(labelText: '浏览器版本'),
                onChanged: (value) {
                  setState(() {
                    selectedBrowserVersion = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: '浏览器路径'),
                onChanged: (value) {
                  setState(() {
                    browserPath = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'WebDriver 路径'),
                onChanged: (value) {
                  setState(() {
                    webDriverPath = value;
                  });
                },
              ),
              // const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: FilledButton.tonal(
                    onPressed: () {
                      // Reload WebDriver logic
                      setState(() {
                        isWebDriverReloaded = true;
                      });
                    },
                    child: const Text('重新加载 WebDriver'),
                  ),
                ),
              ),

              // File storage settings
              const Text('文件存储',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              TextField(
                decoration: const InputDecoration(labelText: '图书下载路径'),
                onChanged: (value) {
                  setState(() {
                    bookDownloadPath = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: '临时文件路径'),
                onChanged: (value) {
                  setState(() {
                    tempFilePath = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: '数据文件路径'),
                onChanged: (value) {
                  setState(() {
                    dataFilePath = value;
                  });
                },
              ),

              // 关于
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('LocalReader  ',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const Text('v0.1.0'),
                  const SizedBox(width: 16),
                  TextButton(onPressed: () {}, child: const Text('Github')),
                  TextButton(onPressed: () {}, child: const Text('Gitee')),
                  TextButton(onPressed: () {}, child: const Text('服务条款')),
                  TextButton(onPressed: () {}, child: const Text('隐私政策')),
                ],
              ),
            ],
          ),

          // 保存按钮
          Positioned(
            bottom: 26.0,
            right: 26.0,
            child: FloatingActionButton(
              child: const Icon(Icons.save_rounded),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('设置已保存'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
