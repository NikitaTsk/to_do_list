import 'package:flutter/material.dart';
import 'package:to_do_list/ui/widgets/groups/groups_widget.dart';
import 'package:to_do_list/ui/widgets/tasks/tasks_widget.dart';

abstract class MainNavigationRouteNames {
  static const groups = '/';
  static const tasks = '/tasks';
}

class MainNavigation {
  final initialRoute = MainNavigationRouteNames.groups;
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.groups: (context) => const GroupsWidget(),
  };

  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.tasks:
        final congiguration = settings.arguments as TasksWidgetCongiguration;
        return MaterialPageRoute(
          builder: (context) => TasksWidget(
            congiguration: congiguration,
          ),
        );
      default:
        const widget = Text('Navigation Error!!!');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }
}
