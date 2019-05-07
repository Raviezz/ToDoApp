import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
class TestTodo extends StatefulWidget {
  @override
  _TestTodoState createState() => _TestTodoState();
}

class _TestTodoState extends State<TestTodo> {
  final TextEditingController _listData = TextEditingController();
  List<String> result;
  getAsyncData() async {
    result = await getData("todo");
    return result;
  }
  void _showAllStoredData(){
    var future_builder = new FutureBuilder(
        future:getAsyncData(),
        builder: (BuildContext context,AsyncSnapshot asyncsnapshot) {
          return asyncsnapshot.hasData ?
          create_card_widget(context,asyncsnapshot): new Container();
        }
    );
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context){
          return new Scaffold(
            appBar: AppBar(
              title: Text("My todo list"),
              backgroundColor: Colors.blue,
            ),
            body: future_builder,
          );
        },
        maintainState: true
        ),
    );
  }
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: AppBar(
          title: new Center(child:Text("TODO APP")),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.list),
              onPressed: _showAllStoredData,
            )
          ],
        ),
        body: new Center(
          child: new Container(
            height: 200.0,
            width: 400.0,
            color: Colors.white,
            child: new Column(
              children: <Widget>[
                new TextField(
                  controller: _listData,
                  decoration: new InputDecoration(
                      hintText: "Ex: EndGame",
                      icon: new Icon(Icons.text_fields)
                  ),
                ),
                new Padding(padding: new EdgeInsets.all(10.5)),
                new Center(
                    child: new Container(
                      child: new RaisedButton(onPressed:() async{_saveToShared();},
                          color: Colors.pinkAccent,
                          child: new Text("save",style: new TextStyle(color: Colors.white))),
                    )
                )
              ],

            ),

          ),
        )
    );
  }
  Future<bool> setData(String key,List<String> val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(key, val);
  }

  Future<List<String>> getData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }
  Widget create_card_widget(BuildContext context,AsyncSnapshot asyncsnapshot) {
    List<String> values = asyncsnapshot.data;
    print(values.length);
    return new ListView.builder(
        itemCount: values.length,
        itemBuilder: (BuildContext context , int index) {
          print("hello"+values[index]);
          return new Container(
            child: new Center(
              child: new Column(
                children: <Widget>[
                  Card(
                    child:new Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.data_usage),
                            title: Text(values[index]),
                          ),
                          ButtonTheme.bar( // make buttons use the appropriate styles for cards
                            child: ButtonBar(
                              children: <Widget>[
                                FlatButton(
                                  child: const Text('EDIT'),
                                  onPressed: () { /* ... */ },
                                ),
                                FlatButton(
                                  child: const Text('DELETE'),
                                  onPressed: () async{ delete_a_item(index); },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }
  void _saveToShared() async{
    List<String> temp = List<String>();
    if(await getData("todo") == null){
      temp.add(_listData.text);
      setData("todo",temp);
    }else{
      temp = await getData("todo");
      print("data existing data "+temp.toString());
      temp.add(_listData.text);
      setData("todo", temp);
      _listData.clear();
    }
  }

  Future<bool> delete_a_item(int index) async {
    List<String> temp = await getData("todo");
    temp.removeAt(index);
    setData("todo", temp);
    Navigator.pop(context);
    _showAllStoredData();
  }




}
