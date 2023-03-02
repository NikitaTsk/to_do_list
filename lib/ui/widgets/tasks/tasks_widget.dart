import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/ui/widgets/tasks/tasks_widget_model.dart';

class TasksWidgetCongiguration {
  final int groupKey;
  final String title;

  TasksWidgetCongiguration(this.groupKey, this.title);
}

class TasksWidget extends StatefulWidget {
  TasksWidgetCongiguration congiguration;

  TasksWidget({
    super.key,
    required this.congiguration,
  });

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  late final TasksWidgetModel _model;

  @override
  void initState() {
    super.initState();
    _model = TasksWidgetModel(
      congiguration: widget.congiguration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          TasksWidgetModel(congiguration: _model.congiguration),
      child: const TasksWidgetBody(),
    );
  }
}

class TasksWidgetBody extends StatelessWidget {
  const TasksWidgetBody({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TasksWidgetModel>();
    final title = model.congiguration.title;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: const [
          _TaskAddWidget(),
          _TaskListWidget(),
        ],
      ),
    );
  }
}

class _TaskAddWidget extends StatelessWidget {
  const _TaskAddWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TasksWidgetModel>();
    TextEditingController controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          suffixIcon: TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                model.saveTask(context);
                controller.clear();
              }
            },
            child: const Text(
              'Добавить',
              style: TextStyle(fontSize: 17),
            ),
          ),
          border: const OutlineInputBorder(),
          hintText: "Имя задачи",
          errorText: model.errorText,
        ),
        onChanged: (value) => model.taskText = value,
        onEditingComplete: () {
          model.saveTask(context);
          controller.clear();
        },
      ),
    );
  }
}

class _TaskListWidget extends StatelessWidget {
  const _TaskListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksCount = context.watch<TasksWidgetModel>().tasks.length;
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: ListView.separated(
        itemCount: tasksCount,
        itemBuilder: (BuildContext context, int index) {
          return _TaskListRowWidget(indexInList: index);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 1);
        },
      ),
    );
  }
}

class _TaskListRowWidget extends StatelessWidget {
  final int indexInList;
  const _TaskListRowWidget({
    super.key,
    required this.indexInList,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.read<TasksWidgetModel>();
    final task = model.tasks[indexInList];

    final icon = task.isDone ? Icons.done : null;
    final style = task.isDone
        ? const TextStyle(
            decoration: TextDecoration.lineThrough,
          )
        : null;

    return Dismissible(
      key: ObjectKey(task),
      onDismissed: (direction) {
        model.deleteTask(indexInList);
        String taskName = task.text;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$taskName dismissed'),
          duration: const Duration(milliseconds: 1),
        ));
      },
      background: Container(color: Colors.red),
      child: ListTile(
        title: Text(
          task.text,
          style: style,
        ),
        trailing: Icon(icon),
        onTap: () => model.doneToggle(indexInList),
      ),
    );
  }
}
