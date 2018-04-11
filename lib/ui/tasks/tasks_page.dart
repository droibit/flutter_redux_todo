import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../action/task_action.dart';
import '../../i10n/app_localizations.dart';
import '../../model/model.dart';
import '../app_drawer.dart';
import 'new_task_page.dart';

class _TasksViewModel {
  final List<Task> tasks;

  final TasksFilter filter;

  final ValueChanged<TasksFilter> onFilterChanged;

  factory _TasksViewModel.from(Store<AppState> store) {
    return new _TasksViewModel._internal(
        tasks: store.state.tasks,
        filter: store.state.tasksFilter,
        onFilterChanged: (newFilter) {
          debugPrint("#onFilterChanged($newFilter)");
//          store.dispatch(action)
        },
    );
  }

  _TasksViewModel._internal({
    @required List<Task> tasks,
    @required this.filter,
    @required this.onFilterChanged,
  })
      : this.tasks = _filterTask(tasks, filter);

  static List<Task> _filterTask(List<Task> src, TasksFilter filter) {
    return src.where((task) {
      switch (filter) {
        case TasksFilter.all:
          return true;
        case TasksFilter.active:
          return task.isActive;
        case TasksFilter.completed:
          return task.completed;
      }
    }).toList(growable: false);
  }
}

class TasksPage extends StatelessWidget {
  TasksPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return new StoreConnector<AppState, _TasksViewModel>(
      distinct: true,
      onInit: (store) => store.dispatch(new GetTasksAction()),
      converter: (store) =>
      new _TasksViewModel.from(store),
      builder: (context, viewModel) {
        return new Scaffold(
          drawer: new AppDrawer(
            selectedNavigation: NavigationId.tasks,
          ),
          appBar: new AppBar(
            title: new Text(localizations.title),
            elevation: 0.0,
            actions: <Widget>[
              new TasksFilterPopupMenu(viewModel.onFilterChanged)
            ],
          ),
          body: new _TaskListContents(viewModel),
          floatingActionButton: new Builder(builder: (innerContext) {
            return new FloatingActionButton(
              child: new Icon(Icons.add),
              onPressed: () => _navigateToNewTaskPage(innerContext),
            );
          }),
        );
      },
    );
  }

  void _navigateToNewTaskPage(BuildContext context) {
    Navigator
        .push<bool>(
      context,
      new MaterialPageRoute(
        builder: (context) => new NewTaskPage(),
      ),
    )
        .then((successful) {
      if (successful != null && successful) {
        _showSnackbar(
            context, AppLocalizations
            .of(context)
            .newTaskSuccessfulToCreate);
      }
    });
  }

  void _showSnackbar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }
}

class TasksFilterPopupMenu extends StatelessWidget {

  final ValueChanged<TasksFilter> _onChanged;

  TasksFilterPopupMenu(this._onChanged);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final itemTitles = <TasksFilter, String>{
      TasksFilter.all: localizations.todoListFilterAll,
      TasksFilter.active: localizations.todoListFilterActive,
      TasksFilter.completed: localizations.todoListFilterCompleted,
    };
    return new PopupMenuButton<TasksFilter>(
      icon: new Icon(
        Icons.filter_list,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        return TasksFilter.values.map((filter) {
          return new PopupMenuItem(
              value: filter,
              child: new Text(itemTitles[filter]),
          );
        }).toList();
      },
      onSelected: _onChanged,
    );
  }
}

class _TaskListContents extends StatelessWidget {
  final _TasksViewModel _viewModel;

  _TaskListContents(this._viewModel, {
    Key key,
  })
      : assert(_viewModel != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_viewModel.tasks.isEmpty) {
      return new _EmptyView();
    } else {
      return new _TaskListView(_viewModel);
    }
  }
}

class _TaskListView extends StatelessWidget {
  final _TasksViewModel _viewModel;

  _TaskListView(this._viewModel, {
    Key key,
  })
      : assert(_viewModel != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        children: <Widget>[
          _buildHeader(context),
          _buildTasksList(context),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    final tiles = _viewModel.tasks.map((task) {
      return new ListTile(
        leading: new Checkbox(
          value: task.completed,
          onChanged: (newValue) {},
        ),
        title: new Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList(growable: false);

    final dividedTiles = ListTile
        .divideTiles(
      context: context,
      tiles: tiles,
    )
        .toList(growable: false);
    return new Expanded(
      child: new ListView(
        children: dividedTiles,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return new Material(
      color: theme.primaryColor,
      elevation: 4.0,
      child: new Column(
        children: <Widget>[
          new Divider(
            height: 2.0,
            color: Colors.white24,
          ),
          new Container(
            constraints: new BoxConstraints(minHeight: 48.0, maxHeight: 48.0),
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  resolveTitle(context, _viewModel.filter),
                  style: new TextStyle(
                    color: Colors.white70,
                    fontSize: theme.textTheme.subhead.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                new Material(
                  type: MaterialType.card,
                  color: Theme
                      .of(context)
                      .primaryColor,
                  child: new InkWell(
                    child: new Row(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: new Text(
                            'Title',
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: theme.textTheme.subhead.fontSize,
                            ),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: new Icon(
                            Icons.arrow_upward,
                            size: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String resolveTitle(BuildContext context, TasksFilter filter) {
    final localizations = AppLocalizations.of(context);
    switch (filter) {
      case TasksFilter.all:
        return localizations.todoListHeaderAll;
      case TasksFilter.active:
        return localizations.todoListHeaderActive;
      case TasksFilter.completed:
        return localizations.todoListHeaderCompleted;
      default:
        throw new AssertionError("Invalid filter: $filter");
    }
  }
}

class _EmptyView extends StatelessWidget {
  _EmptyView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(
            Icons.assignment_turned_in,
            size: 36.0,
            color: Theme
                .of(context)
                .primaryColor,
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: new Text(AppLocalizations
                .of(context)
                .noTasks),
          )
        ],
      ),
    );
  }
}
