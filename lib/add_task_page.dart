import 'package:flutter/material.dart';
import 'package:local_reader/grab_helper.dart';
import 'package:local_reader/grab_tasks.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

const Map<String, String> desktopWebDriverInfo = {
  'desktopBrowserName': 'msedge',
  'desktopBrowserPath':
      r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
};

class AddBookButton extends StatelessWidget {
  const AddBookButton({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      onPressed: () {
        showCupertinoModalBottomSheet(
          isDismissible: false,
          expand: true,
          context: context,
          builder: (context) {
            return Scaffold(
              body: WillPopScope(
                onWillPop: () async {
                  bool shouldClose = true;
                  await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('是否取消添加图书？'),
                            actions: <Widget>[
                              FilledButton.tonal(
                                child: const Text('是'),
                                onPressed: () {
                                  shouldClose = true;
                                  Navigator.of(context).pop();
                                },
                              ),
                              FilledButton(
                                child: const Text('否'),
                                onPressed: () {
                                  shouldClose = false;
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ));
                  return shouldClose;
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('添加图书',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.help_outline_rounded),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const AddBookPage(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final TextEditingController _textEditingController = TextEditingController();

  Map bookInfo = {};
  bool isWorking = false;

  String selectedCover = '';

  @override
  Widget build(BuildContext context) {
    final GrabTasksHelper grabTasksHelper =
        Provider.of<GrabTasksHelper>(context, listen: false);

    Widget askBookURL = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextField(
          controller: _textEditingController,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: '图书链接',
          ),
          keyboardType: TextInputType.url,
          enabled: !isWorking,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
              icon: isWorking
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ))
                  : const Icon(Icons.add),
              onPressed: isWorking
                  ? null
                  : () async {
                      if (_textEditingController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('请输入图书链接'),
                                behavior: SnackBarBehavior.floating));
                        return;
                      }
                      setState(() => isWorking = true);

                      final grabHelper = GrabHelper(
                        desktopBrowserName:
                            desktopWebDriverInfo['desktopBrowserName'],
                        desktopBrowserPath:
                            desktopWebDriverInfo['desktopBrowserPath'],
                      );
                      await grabHelper.init();
                      bookInfo = await grabHelper
                          .grabBookInfo(_textEditingController.text);
                      grabHelper.dispose();
                      print(bookInfo);
                      selectedCover = bookInfo['bookCover']?.last;
                      setState(() {});
                    },
              label: const Text('获取')),
        ),
      ],
    );

    Widget bookInfoPage = Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              selectedCover,
              fit: BoxFit.cover,
              width: 100,
              height: 160,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Icon(Icons.error_outline_rounded);
              },
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bookInfo['bookName'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  bookInfo['bookAuthor'] ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return BookCoverDialog(
                      bookCovers: bookInfo['bookCover'],
                      onSelected: (String coverURL) {
                        setState(() {
                          selectedCover = coverURL;
                        });
                      },
                    );
                  },
                );
              },
              label: const Text('更改图书封面'),
              icon: const Icon(Icons.add_photo_alternate_rounded),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () {
                bookInfo['bookCover'] = selectedCover;
                grabTasksHelper.addCatalogueTask(bookInfo);
                Navigator.of(context).pop();
              },
              child: const Text('添加'),
            ),
          ],
        )
      ],
    );

    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeIn,
        child: bookInfo.isEmpty ? askBookURL : bookInfoPage,
        transitionBuilder: (child, animation) {
          return SlideTransitionX(
            direction: AxisDirection.right,
            position: animation,
            child: child,
          );
        });
  }
}

class BookCoverDialog extends StatefulWidget {
  final List bookCovers;
  final Function(String) onSelected;
  const BookCoverDialog(
      {super.key, required this.bookCovers, required this.onSelected})
      : super();

  @override
  _BookCoverDialogState createState() => _BookCoverDialogState();
}

class _BookCoverDialogState extends State<BookCoverDialog> {
  String? selectedCover;
  @override
  void initState() {
    selectedCover = widget.bookCovers.last;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选取图书封面'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: widget.bookCovers.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.625,
              // mainAxisExtent:,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GridTile(
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    Image.network(
                      widget.bookCovers[index],
                      fit: BoxFit.cover,
                      width: 100,
                      height: 160,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Radio<String>(
                          value: widget.bookCovers[index],
                          groupValue: selectedCover,
                          onChanged: (String? value) {
                            setState(() {
                              selectedCover = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('确定'),
          onPressed: () {
            widget.onSelected(selectedCover!);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class SlideTransitionX extends AnimatedWidget {
  SlideTransitionX({
    super.key,
    required Animation<double> position,
    this.transformHitTests = true,
    this.direction = AxisDirection.down,
    required this.child,
  }) : super(listenable: position) {
    switch (direction) {
      case AxisDirection.up:
        _tween = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
        break;
      case AxisDirection.right:
        _tween = Tween(begin: const Offset(-1, 0), end: const Offset(0, 0));
        break;
      case AxisDirection.down:
        _tween = Tween(begin: const Offset(0, -1), end: const Offset(0, 0));
        break;
      case AxisDirection.left:
        _tween = Tween(begin: const Offset(1, 0), end: const Offset(0, 0));
        break;
    }
  }

  final bool transformHitTests;

  final Widget child;

  final AxisDirection direction;

  late final Tween<Offset> _tween;

  @override
  Widget build(BuildContext context) {
    final position = listenable as Animation<double>;
    Offset offset = _tween.evaluate(position);
    if (position.status == AnimationStatus.reverse) {
      switch (direction) {
        case AxisDirection.up:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.right:
          offset = Offset(-offset.dx, offset.dy);
          break;
        case AxisDirection.down:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.left:
          offset = Offset(-offset.dx, offset.dy);
          break;
      }
    }
    return FractionalTranslation(
      translation: offset,
      transformHitTests: transformHitTests,
      child: child,
    );
  }
}
