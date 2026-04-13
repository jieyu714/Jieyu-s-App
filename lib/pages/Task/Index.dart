import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/api/TaskApi.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/DateTimePicker.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';
import 'package:jieyu_app/viewmodels/Task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  final TaskApi _api = TaskApi();

  final List<String> _navigationItems = ["待辦", "過期/無期限", "已完成"];
  final List<IconData> _navigationIcons = [CupertinoIcons.list_bullet, CupertinoIcons.hourglass, CupertinoIcons.check_mark_circled];
  int _currentIndex = 0;
  late PageController _pageController;

  List<TaskItem> _todayTask = [];
  List<TaskItem> _weekTask = [];
  List<TaskItem> _startedTask = [];
  List<TaskItem> _expiredTask = [];
  List<TaskItem> _noLimitTimeTask = [];
  List<TaskItem> _otherTask = [];
  List<TaskItem> _completedTask = [];

  void _showTaskDialog({TaskItem? task}) {
    TextEditingController titleController = TextEditingController(text: task?.title ?? "");
    TextEditingController detailController = TextEditingController(text: task?.detail ?? "");
    TextEditingController startTimeController = TextEditingController(
      text: task?.startTime != null ? task!.startTime!.toLocal().toString().substring(0, 16) : ""
    );
    TextEditingController deadTimeController = TextEditingController(
      text: task?.deadTime != null ? task!.deadTime!.toLocal().toString().substring(0, 16) : ""
    );
    TextEditingController completedTimeController = TextEditingController(
      text: task?.completedAt != null ? task!.completedAt!.toLocal().toString().substring(0, 16) : ""
    );

    DateTime? selectedStartTime = task?.startTime;
    DateTime? selectedDeadTime = task?.deadTime;
    DateTime? selectedCompletedTime = task?.completedAt;

    FocusNode detailFocus = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Center(
            child: Text(
              task == null ? "新增任務" : "修改任務",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                labelText: "標題",
                controller: titleController,
                isRequird: true,
                textInputAction: TextInputAction.next,
                onSubmitted: () => FocusScope.of(context).requestFocus(detailFocus),
              ),
              SizedBox(height: 10),
              CustomTextField(
                labelText: "說明",
                controller: detailController,
                focus: detailFocus,
                textInputAction: TextInputAction.newline,
                maxLines: null,
              ),
              SizedBox(height: 10),
              CustomTextField(
                labelText: "開始時間",
                controller: startTimeController,
                readOnly: true,
                onTap: () async {
                  final result = await DateTimePicker().selectDateTime(context, initialDate: selectedStartTime);
                  if (result != null) {
                    selectedStartTime = result;
                    startTimeController.text = result.toString().substring(0, 16);
                  }
                },
              ),
              SizedBox(height: 10),
              CustomTextField(
                labelText: "截止時間",
                controller: deadTimeController,
                readOnly: true,
                onTap: () async {
                  final result = await DateTimePicker().selectDateTime(context, initialDate: selectedDeadTime);
                  if (result != null) {
                    selectedDeadTime = result;
                    deadTimeController.text = result.toString().substring(0, 16);
                  }
                },
              ),
              if (task != null) ...[
                SizedBox(height: 10),
                CustomTextField(
                  labelText: "完成時間",
                  controller: completedTimeController,
                  readOnly: true,
                  onTap: () async {
                    final result = await DateTimePicker().selectDateTime(context, initialDate: selectedCompletedTime);
                    if (result != null) {
                      selectedCompletedTime = result;
                      completedTimeController.text = result.toString().substring(0, 16);
                    }
                  },
                )
                ]
            ],
          ),
          actions: [
            if (task != null) ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTask(task.id);
              },
              child: Text(
                "刪除",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red
              )
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "取消",
                style: TextStyle(
                  color: Colors.grey
                ),
              )
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  Fluttertoast.showToast(
                    msg: "請輸入任務標題",
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                Navigator.pop(context);
                if (task == null) {
                  _addTaskItemCheck(
                    titleController.text,
                    detail: detailController.text,
                    startTime: selectedStartTime,
                    deadTime: selectedDeadTime
                  );
                } else {
                  _editTaskItemCheck(
                    task.id,
                    titleController.text,
                    detail: detailController.text,
                    startTime: selectedStartTime,
                    deadTime: selectedDeadTime,
                    completedAt: selectedCompletedTime
                  );
                }
              },
              child: Text(
                "確認",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor
              )
            )
          ],
        );
      }
    );
  }

  void _addTaskItemCheck (
    String title,
    {
      String detail = "",
      DateTime? startTime,
      DateTime? deadTime,
    }
  ) async {
    try {
      ProgressDialog().showLoading(context, title: "新增任務中...", minDuration: 2);
      await _api.addTask(
        username: "Jieyu",
        title: title,
        detail: detail,
        startTime: startTime,
        deadTime: deadTime
      );

      if (!mounted) return;
      ProgressDialog().showResult(context, message: "新增任務成功", isSuccess: true,
        onClose: () {
          _fetchTask();
        }
      );
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "新增任務失敗，請稍後再試", isError: true);
    }
  }

  void _editTaskItemCheck (
    int id,
    String title,
    {
      String detail = "",
      DateTime? startTime,
      DateTime? deadTime,
      DateTime? completedAt
    }
  ) async {
    try {
      ProgressDialog().showLoading(context, title: "修改任務中...", minDuration: 2);
      await _api.updateTask(
        username: "Jieyu",
        id: id,
        title: title,
        detail: detail,
        startTime: startTime,
        deadTime: deadTime,
        completedAt: completedAt
      );

      if (!mounted) return;
      ProgressDialog().showResult(context, message: "修改任務成功", isSuccess: true,
        onClose: () {
          _fetchTask();
        }
      );
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "修改任務失敗，請稍後再試", isError: true);
    }
  }

  void _deleteTask (
    int id
  ) async {
    try {
      ProgressDialog().showLoading(context, title: "刪除任務中...", minDuration: 2);
      await _api.deleteTask(
        username: "Jieyu",
        id: id
      );

      if (!mounted) return;
      ProgressDialog().showResult(context, message: "刪除任務成功", isSuccess: true,
        onClose: () {
          _fetchTask();
        }
      );
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "刪除任務失敗，請稍後再試", isError: true);
    }
  }

  Widget _buildTaskCard(TaskItem item) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          _showTaskDialog(task: item);
        },
        child: Padding(
          padding: EdgeInsets.all(4),
          child: ListTile(
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2D2D2D),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  item.detail.replaceAll('\n', ' ').trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.blueGrey.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        (item.startTime?.toLocal().toString().substring(2, 16) .replaceAll("-", "/")?? "No Start Time")
                        + " ~ "
                        + (item.deadTime?.toLocal().toString().substring(2, 16) .replaceAll("-", "/")?? "No Dead Time"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blueGrey.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color?.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(String title, List<TaskItem> tasks) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Color.lerp(Theme.of(context).primaryColor, Colors.white, 0.2),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                title
              ),
            ),
          ),
          SizedBox(
            height: 15
          ),
          tasks.isEmpty
          ? Center(
              child: Text(
                "尚無任務",
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
            )
          : Column(
            children: List.generate(tasks.length, (index) {
              return _buildTaskCard(tasks[index]);
            }),
          )
        ],
      )
    );
    
    // return 
  }

  Future<void> _splitTask(List<TaskItem>? allTask) async {
    if (allTask == null || allTask.isEmpty) {
      setState(() {
        _todayTask = [];
        _weekTask = [];
        _startedTask = [];
        _expiredTask = [];
        _noLimitTimeTask = [];
        _otherTask = [];
        _completedTask = [];
      });
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime endOfToday = DateTime(now.year, now.month, now.day + 1);
    final DateTime endOfWeek = endOfToday.add(Duration(days: 7));

    setState(() {
      _todayTask = [];
      _weekTask = [];
      _startedTask = [];
      _expiredTask = [];
      _noLimitTimeTask = [];
      _otherTask = [];
      _completedTask = [];

      for (var task in allTask) {
        if (task.isCompleted) {
          task.icon = CupertinoIcons.check_mark_circled;
          task.color = Colors.lightGreen;
          _completedTask.add(task);
        } else if (task.deadTime == null) {
          task.icon = CupertinoIcons.hourglass;
          task.color = Colors.grey;
          _noLimitTimeTask.add(task);
        } else if (task.deadTime!.isBefore(now)) {
          task.icon = CupertinoIcons.exclamationmark_circle;
          task.color = Colors.redAccent;
          _expiredTask.add(task);
        } else if (task.deadTime!.isBefore(endOfToday)) {
          task.icon = CupertinoIcons.clock;
          task.color = Colors.redAccent;
          _todayTask.add(task);
        } else if (task.deadTime!.isBefore(endOfWeek)) {
          task.icon = CupertinoIcons.clock;
          task.color = Colors.orangeAccent;
          _weekTask.add(task);
        } else if (task.startTime != null &&task.startTime!.isBefore(now)) {
          task.icon = CupertinoIcons.clock;
          task.color = Colors.blueAccent;
          _startedTask.add(task);
        } else {
          task.icon = CupertinoIcons.clock;
          task.color = Colors.grey;
          _otherTask.add(task);
        }
      }
    });
  }

  Future<void> _fetchTask() async {
    try {
      final response = await _api.getTask(username: "Jieyu");
      
      if (response.isSuccess) {
        _splitTask(response.data);
      } else {
        if (!mounted) return;
        ProgressDialog().showResult(context, message: response.message, isError: true);
      }
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "無法載入任務", isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _fetchTask();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildList(int index) {
    if (index == 0) {
      return [
        _buildTaskList("今日", _todayTask),
        _buildTaskList("一周內", _weekTask),
        _buildTaskList("已開始", _startedTask),
        _buildTaskList("未開始", _otherTask),
      ];
    } else if (index == 1) {
      return [
        _buildTaskList("過期", _expiredTask),
        _buildTaskList("無期限", _noLimitTimeTask),
      ];
    } else if (index == 2) {
      return [
        _buildTaskList("已完成", _completedTask),
      ];
    }
    return [];
  }

  Widget _buildPage(int idx) {
    return Stack(
      children: [
        ListView(
          children: _buildList(idx),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () {
              _showTaskDialog();
            },
            child: Text(
              "+",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            shape: CircleBorder(),
            backgroundColor: (Color.lerp(Theme.of(context).primaryColor.withAlpha(150), Colors.white, 0.2)),
          ),
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("任務清單"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: List.generate(_navigationItems.length, (index) => _buildPage(index)),
          onPageChanged: (value) => {
            setState(() {
              _currentIndex = value;
            })
          },
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: List.generate(_navigationIcons.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_navigationIcons[index]),
            label: _navigationItems[index],
          );
        }),
      )
    );
  }
}