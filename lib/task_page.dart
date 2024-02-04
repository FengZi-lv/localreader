import 'package:flutter/material.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 60,
      child: ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          final task = taskList[index];
          return ListTile(
            title: Text(task.bookName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: task.downloadProgress,
                ),
                Text(
                    '已下载: ${task.successfulChapterCount} 章\t     下载失败: ${task.failedChapterCount} 章'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {
                    // Handle pause button press
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Handle delete button press
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Task {
  final String bookName;
  final double downloadProgress;
  final int successfulChapterCount;
  final int failedChapterCount;

  Task({
    required this.bookName,
    required this.downloadProgress,
    required this.successfulChapterCount,
    required this.failedChapterCount,
  });
}

final List<Task> taskList = [
  Task(
    bookName: 'Book 1',
    downloadProgress: 0.5,
    successfulChapterCount: 10,
    failedChapterCount: 2,
  ),
  Task(
    bookName: 'Book 2',
    downloadProgress: 0.8,
    successfulChapterCount: 15,
    failedChapterCount: 0,
  ),
  Task(
    bookName: 'Book 3',
    downloadProgress: 0.2,
    successfulChapterCount: 5,
    failedChapterCount: 5,
  ),
];
