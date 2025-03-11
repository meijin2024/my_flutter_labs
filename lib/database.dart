import 'package:floor/floor.dart';
import 'dart:async';
import 'todo_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'to_item.dart';
part 'database.g.dart';

@Database(version: 1, entities: [TodoItem])
abstract class AppDatabase extends FloorDatabase{
  TodoDao get todoDao;
}