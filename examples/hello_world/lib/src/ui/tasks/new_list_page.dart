import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/index.dart';

class NewListPage extends StatefulWidget {
  @override
  _NewListPageState createState() => _NewListPageState();
}

class _NewListPageState extends State<NewListPage> {
  final String _scaffoldTitle = "Create New list";
  final String _listTitleInputHint = "Enter list title";
  final String _snackInvalidTitleMsg = "Enter a valid list title first";
  final String _appBarDoneAction = "Done";
  final key = GlobalKey<ScaffoldState>();
  String newListTitle = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            _scaffoldTitle,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
            ),
          ),
          actions: <Widget>[
            Consumer<TaskState>(
              builder: (context, tasks, child) => FlatButton(
                  onPressed: () async {
                    if (newListTitle != null && newListTitle != "") {
                      print('Saving list title');
                      tasks.addList(newListTitle);
                      Navigator.pop(context);
                    } else {
                      key.currentState.showSnackBar(
                          SnackBar(content: Text(_snackInvalidTitleMsg)));
                    }
                  },
                  child: Text(
                    _appBarDoneAction,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Divider(
              height: 1.0,
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
              color: Colors.white,
              child: Wrap(
                children: <Widget>[
                  TextField(
                    onChanged: (listTitle) {
                      newListTitle = listTitle;
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _listTitleInputHint),
                    enabled: true,
                  )
                ],
              ),
            ),
          ],
        ));
  }
}