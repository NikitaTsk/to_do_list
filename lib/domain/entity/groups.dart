import 'package:hive/hive.dart';

part 'groups.g.dart';

@HiveType(typeId: 1)
class Groups extends HiveObject {
  //last used HiveField key 1
  @HiveField(0)
  String name;

  Groups({
    required this.name,
  });
}
