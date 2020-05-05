import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttersns/Chat.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void showPostDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          String title = '';
          String description = '';
          return AlertDialog(
            title: Text("トークルームを作成"),
            content: Column(
              children: <Widget>[
                Expanded(
                    child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'ルーム名', hintText: 'タイトルを入力'),
                  onChanged: (value) {
                    title = value;
                  },
                )),
                Expanded(
                    child: new TextField(
                  autofocus: true,
                  decoration:
                      new InputDecoration(labelText: '説明', hintText: '説明を入力'),
                  onChanged: (value) {
                    description = value;
                  },
                )),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  if (title.isNotEmpty) {
                    Firestore.instance
                        .collection("test")
                        .add({"title": title, "content": description});
                    Navigator.pop(context);
                  } else {
                    // TODO 注意メッセージ出す
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: TestList(),
      floatingActionButton: FloatingActionButton(
        onPressed: showPostDialog,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TestList extends StatelessWidget {
  final String userId;

  TestList({Key key, @required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('test').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            {
              return ListView(
                children:
                    snapshot.data.documents.map((DocumentSnapshot document) {
                  return new ListTile(
                    title: new Text(document['title']),
                    subtitle: new Text(document['content']),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<Null>(
                              settings: const RouteSettings(name: "/chatRoom"),
                              builder: (BuildContext context) => Chat(
                                    roomId: document.documentID,
                                    userId: "this",
                                    roomName: document["title"],
                                  )));
                    },
                  );
                }).toList(),
              );
            }
        }
      },
    );
  }
}
