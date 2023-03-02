import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/domain/data_provider/box_manager.dart';
import 'package:to_do_list/domain/entity/task.dart';
import 'package:to_do_list/ui/widgets/tasks/tasks_widget.dart';

class TasksWidgetModel extends ChangeNotifier {
  TasksWidgetCongiguration congiguration;
  late final Future<Box<Task>> _box;
  ValueListenable<Object>? _listenableBox;
  var _tasks = <Task>[];

  var _taskText = '';
  String? errorText;

  List<Task> get tasks => _tasks.toList();

  bool get isValid => _taskText.trim().isNotEmpty;

  set taskText(String value) {
    if (errorText != null && value.trim().isNotEmpty) {
      errorText = null;
      notifyListeners();
    }
    _taskText = value;
  }

  TasksWidgetModel({
    required this.congiguration,
  }) {
    _setup();
  }

  Future<void> saveTask(BuildContext context) async {
    final taskText = _taskText.trim();
    if (taskText.isEmpty) {
      errorText = "Введите название задачи";
      notifyListeners();
      return;
    }

    final task = Task(text: taskText, isDone: false);
    final box = await BoxManager.instance.openTaskBox(congiguration.groupKey);
    await box.add(task);
    await BoxManager.instance.closeBox(box);
  }

  Future<void> deleteTask(int taskIndex) async {
    await (await _box).deleteAt(taskIndex);
  }

  Future<void> doneToggle(int taskIndex) async {
    final task = (await _box).getAt(taskIndex);
    task?.isDone = !task.isDone;
    await task?.save();
  }

  Future<void> _readTaskFromHive() async {
    _tasks = (await _box).values.toList();
    notifyListeners();
  }

  Future<void> _setup() async {
    _box = BoxManager.instance.openTaskBox(congiguration.groupKey);
    await _readTaskFromHive();
    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readTaskFromHive);
  }

  @override
  Future<void> dispose() async {
    _listenableBox?.removeListener(_readTaskFromHive);
    await BoxManager.instance.closeBox((await _box));
    super.dispose();
  }
}
