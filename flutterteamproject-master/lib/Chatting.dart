import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home/ProfileDetailPage.dart';

class Chatting extends StatefulWidget {
  String chatRoomId;
  String? targetId;
  String? targetNickName;

  Chatting({required this.chatRoomId, this.targetId, this.targetNickName});

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  String? currentUserId; // 현재 사용자 ID
  Map<String, dynamic> targetInfo = {}; // 상대 사용자 정보
  final TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool todayFlg = false; // 구현 X

  // 오늘 메시지 없으면 날짜 출력 (대기 / 구현X)
  void todayFirstMessage() async {
    var qs = await FirebaseFirestore.instance
        .collection('Chatting')
        .doc(widget.chatRoomId)
        .collection('Messages')
        .orderBy('SendTime', descending: true)
        .get();
  }

  // 메시지 읽음 상태로 변환
  void checkMessage() async {
    var qs = await FirebaseFirestore.instance
        .collection('Chatting')
        .doc(widget.chatRoomId)
        .collection('Messages')
        .where('CheckYn', isEqualTo: false)
        .where('SenderId', isEqualTo: widget.targetId)
        .get();
    for (var doc in qs.docs) {
      await FirebaseFirestore.instance
          .collection('Chatting')
          .doc(widget.chatRoomId)
          .collection('Messages')
          .doc(doc.id)
          .update({'CheckYn': true});
    }
  }

  // 상대 유저 정보를 가져오기
  void getTarget() async {
    // 내 정보 가져오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('email') ?? '';
    });

    FirebaseFirestore fs = FirebaseFirestore.instance;

    QuerySnapshot snapshot =
    await fs.collection('USER').where('EMAIL', isEqualTo: widget.targetId).get();
    setState(() {
      targetInfo = snapshot.docs.first.data() as Map<String, dynamic>;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTarget();
  }

  // 날짜 변환 포맷
  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('HH:mm').format(timestamp.toDate());
  }

  // 메시지 전송
  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    var messageContent = _controller.text;
    var timestamp = FieldValue.serverTimestamp();
    FirebaseFirestore.instance.runTransaction((transaction) async {
      var chatRoomRef =
      FirebaseFirestore.instance.collection('Chatting').doc(widget.chatRoomId); // 채팅방 id
      var messagesRef =
      chatRoomRef.collection('Messages').doc(); // 해당 doc 내 Messages 컬렉션 접근

      // 메시지 데이터 추가
      transaction.set(messagesRef, {
        'SenderId': currentUserId,
        'Content': messageContent,
        'SendTime': timestamp,
        'CheckYn': false
      });

      // 가장 마지막 메시지, 시간 입력 (채팅방 리스트에서 출력될 데이터)
      transaction.update(chatRoomRef, {
        'LastMessage': messageContent,
        'LastMessageTime': timestamp,
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (targetInfo['IMAGES'] == null) {
      return CircularProgressIndicator();
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBar(
          toolbarHeight: 75,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(Icons.videocam, size: 30),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(Icons.more_horiz),
            ),
          ],
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 35,
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileDetailPage(
                              profiles: [targetInfo], // Map<String, dynamic> 형태로 전달
                              initialIndex: 0,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // 원형으로 설정
                          image: DecorationImage(
                            image: NetworkImage('${targetInfo['IMAGES'][0]}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.targetNickName}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        // Icon(
                        //   Icons.check_circle,
                        //   color: Colors.green,
                        //   size: 17,
                        // )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              height: 1.0,
              color: Colors.grey, // 원하는 색상으로 변경 가능
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  controller: _scrollController,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Chatting')
                        .doc(widget.chatRoomId)
                        .collection('Messages')
                        .orderBy('SendTime')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                      if (chatSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (chatSnapshot.data == null) {
                        return Center(
                          child: Text("No data available"),
                        );
                      }
                      final chatDocs = chatSnapshot.data!.docs;
                      return Column(
                        children: chatDocs.map((item) {
                          var message = item.data() as Map;
                          String sendTime = _formatTimestamp(message['SendTime']);
                          if (message['SenderId'] == 'admin') {
                            return Text('${message['Content']}');
                          }
                          if (message['SenderId'] == currentUserId) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Container(),
                                        flex: 1,
                                      ),
                                      // Text(
                                      //   '$sendTime',
                                      //   style: TextStyle(fontSize: 10),
                                      // ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(7),
                                                  bottomRight: Radius.circular(2),
                                                  topLeft: Radius.circular(7),
                                                  topRight: Radius.circular(7))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${message['Content']}',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        flex: 7,
                                      ),
                                    ]),
                              ),
                            );
                          }
                          checkMessage();
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle, // 원형으로 설정
                                        image: DecorationImage(
                                          image: NetworkImage('${targetInfo['IMAGES'][0]}'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(2),
                                                bottomRight: Radius.circular(7),
                                                topLeft: Radius.circular(7),
                                                topRight: Radius.circular(7))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '${message['Content']}',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      flex: 7,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    // Text(
                                    //   '$sendTime',
                                    //   style: TextStyle(fontSize: 10),
                                    // ),
                                    Flexible(
                                      child: Container(),
                                      flex: 1,
                                    ),
                                  ]),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(hintText: 'Send a message...'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
