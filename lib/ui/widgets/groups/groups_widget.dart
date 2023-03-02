import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/ui/widgets/groups/groups_widget_model.dart';

class GroupsWidget extends StatefulWidget {
  const GroupsWidget({super.key});

  @override
  State<GroupsWidget> createState() => _GroupsWidgetState();
}

class _GroupsWidgetState extends State<GroupsWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupsWidgetModel(),
      child: const _GroupsWidgetBody(),
    );
  }
}

class _GroupsWidgetBody extends StatelessWidget {
  const _GroupsWidgetBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы'),
      ),
      body: Stack(
        children: const [
          _GroupsListWidget(),
          _GroupsAddWidget(),
        ],
      ),
    );
  }
}

class _GroupsAddWidget extends StatelessWidget {
  const _GroupsAddWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GroupsWidgetModel>();
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
                model.saveGroup(context);
                controller.clear();
              }
            },
            child: const Text(
              'Добавить',
              style: TextStyle(fontSize: 17),
            ),
          ),
          border: const OutlineInputBorder(),
          hintText: "Имя группы",
          errorText: model.errorText,
        ),
        onChanged: (value) => model.groupName = value,
        onEditingComplete: () {
          model.saveGroup(context);
          controller.clear();
        },
      ),
    );
  }
}

class _GroupsListWidget extends StatelessWidget {
  const _GroupsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final groupsCount = context.watch<GroupsWidgetModel>().groups.length;
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: ListView.separated(
        itemCount: groupsCount,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 1);
        },
        itemBuilder: (BuildContext context, int index) {
          return _GroupListRowWidget(indexInList: index);
        },
      ),
    );
  }
}

class _GroupListRowWidget extends StatelessWidget {
  final int indexInList;
  const _GroupListRowWidget({super.key, required this.indexInList});

  @override
  Widget build(BuildContext context) {
    final model = context.read<GroupsWidgetModel>();
    final group = model.groups[indexInList];

    return Dismissible(
      key: ObjectKey(group),
      onDismissed: (direction) {
        model.deleteGroup(indexInList);
        String groupName = group.name;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$groupName dismissed'),
          duration: const Duration(milliseconds: 500),
        ));
      },
      background: Container(color: Colors.red),
      child: ListTile(
        title: Text(group.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => model.showTasks(context, indexInList),
      ),
    );
  }
}
