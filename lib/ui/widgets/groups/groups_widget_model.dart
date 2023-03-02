import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/domain/data_provider/box_manager.dart';
import 'package:to_do_list/domain/entity/groups.dart';
import 'package:to_do_list/ui/navigation/main_navigation.dart';
import 'package:to_do_list/ui/widgets/tasks/tasks_widget.dart';

class GroupsWidgetModel extends ChangeNotifier {
  late final Future<Box<Groups>> _box;
  ValueListenable<Object>? _listenableBox;
  var _groupName = '';
  String? errorText;

  var _groups = <Groups>[];

  List<Groups> get groups => _groups.toList();

  GroupsWidgetModel() {
    _setup();
  }

  set groupName(String value) {
    if (errorText != null && value.trim().isNotEmpty) {
      errorText = null;
      notifyListeners();
    }
    _groupName = value;
  }

  Future<void> saveGroup(BuildContext context) async {
    final groupName = _groupName.trim();
    if (groupName.isEmpty) {
      errorText = "Введите название группы";
      notifyListeners();
      return;
    }

    final box = await BoxManager.instance.openGroupBox();
    final group = Groups(name: groupName);
    await (box.add(group));
    await BoxManager.instance.closeBox(box);
  }

  Future<void> showTasks(BuildContext context, int groupIndex) async {
    final group = (await _box).getAt(groupIndex);
    if (group != 0) {
      final congiguration = TasksWidgetCongiguration(
        group?.key as int,
        group!.name,
      );
      Navigator.of(context).pushNamed(
        MainNavigationRouteNames.tasks,
        arguments: congiguration,
      );
    }
  }

  Future<void> deleteGroup(int groupIndex) async {
    final box = await _box;
    final groupKey = (await _box).keyAt(groupIndex) as int;
    final taskBoxName = BoxManager.instance.makeTaskBoxName(groupKey);
    await Hive.deleteBoxFromDisk(taskBoxName);
    await box.deleteAt(groupIndex);
  }

  Future<void> _readGroupsFromHive() async {
    _groups = (await _box).values.toList();
    notifyListeners();
  }

  Future<void> _setup() async {
    _box = BoxManager.instance.openGroupBox();
    await _readGroupsFromHive();
    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readGroupsFromHive);
  }

  @override
  Future<void> dispose() async {
    _listenableBox?.removeListener(_readGroupsFromHive);
    await BoxManager.instance.closeBox((await _box));
    super.dispose();
  }
}
