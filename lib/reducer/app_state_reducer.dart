import '../model/model.dart';
import 'create_task_reducer.dart';
import 'package_info_reducer.dart';
import 'task_reducer.dart';
import 'tasks_filter_reducer.dart';
import 'tasks_sort_by_reducer.dart';

AppState appStateReducer(AppState state, dynamic action) {
  return new AppState(
    tasks: tasksReducer(state.tasks, action),
    tasksFilter: tasksFilterReducer(state.tasksFilter, action),
    tasksSortBy: tasksSortByReducer(state.tasksSortBy, action),
    createTask: createTaskReducer(state.createTask, action),
    packageInfo: packageInfoReducer(state.packageInfo, action),
  );
}
