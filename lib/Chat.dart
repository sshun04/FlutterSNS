import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  final String roomId;
  final String userId;
  final String roomName;

  Chat(
      {Key key,
      @required this.roomId,
      @required this.userId,
      @required this.roomName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            roomName,
            style: TextStyle(color: Colors.blue),
          ),
        ),
        body: ChatScreen(roomId: roomId, userId: userId));
  }
}

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String userId;

  ChatScreen({Key key, @required this.roomId, @required this.userId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      ChatScreenState(roomId: roomId, userId: userId);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.roomId, @required this.userId});

  final String roomId;
  final String userId;
  var listMessages;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['userId'] == userId) {
      // Right my message
      return Row(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(
                    document['message'],
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 5.0,
                      right: 10.0),
                )
              ],
            ),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left peers message
      return Row(children: <Widget>[
        Container(
            child: Text(
              document['message'],
              style: TextStyle(color: Colors.black87),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 238, 238, 238),
                borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(
                bottom: isLastMessageLeft(index) ? 20.0 : 5.0, left: 10.0))
      ], crossAxisAlignment: CrossAxisAlignment.start);
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1]['userId'] == userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1]['userId'] != userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    var userRef = Firestore.instance
        .collection('test')
        .document(roomId)
        .collection('users')
        .document(userId);
    var updateUsers = userRef.delete();
    Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[buildListMessage(), buildInput()],
          )
        ],
      ),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.black54, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.black26),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text),
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: Colors.black26, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
        child: StreamBuilder(
      stream: Firestore.instance
          .collection("test")
          .document(roomId)
          .collection("messages")
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          listMessages = snapshot.data.documents;
          return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, listMessages[index]),
              itemCount: listMessages.length,
              reverse: true,
              controller: listScrollController);
        } else {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
        }
      },
    ));
  }

  onSendMessage(String text) {
    if (text.isNotEmpty) {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection("test")
          .document(roomId)
          .collection("messages")
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'userId': userId,
            'message': text,
            'timeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );
      });

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {}
  }
}
