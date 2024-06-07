import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'Home/bottomNavi.dart' as bottom;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterteamproject/LogIn/LogInMain.dart';
import 'Chatting.dart';
import 'package:flutterteamproject/Profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChattingList());
}

class ChattingList extends StatefulWidget {
  ChattingList();

  @override
  State<ChattingList> createState() => _ChattingListState();
}

class _ChattingListState extends State<ChattingList> {
  String currentUserId = ''; // 현재 사용자 ID
  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('email') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    getSession();
  }

  // Firebase 초기화
  Future<void> initializeApp() async {
    await Firebase.initializeApp();
    await initializeDateFormatting('ko_KR', null);
  }

  // 타임스탬프를 "오전 01시 01분" 형식으로 포맷하는 함수
  String formatTimestamp(Timestamp timestamp) {
    if (timestamp == '') {
      return '';
    }
    DateTime now = DateTime.now();
    DateTime dateTime = timestamp.toDate();

    // 어제 날짜 계산
    DateTime yesterday = now.subtract(Duration(days: 1));

    // 날짜 비교
    bool isYesterday = dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;

    // 시간 형식 설정
    String formattedTime = DateFormat('a hh시 mm분', 'ko_KR').format(dateTime);
    formattedTime = formattedTime.replaceAll('AM', '오전').replaceAll('PM', '오후');

    // 날짜 형식 설정 (오래된 날짜용)
    String formattedDate = DateFormat('M월 d일', 'ko_KR').format(dateTime);

    // 어제인지 확인하고 반환
    if (isYesterday) {
      return '어제';
    } else if (dateTime.isBefore(yesterday)) {
      // 어제보다 오래된 날짜인 경우
      return formattedDate;
    } else {
      // 오늘 날짜인 경우
      return formattedTime;
    }
  }

  // EMAIL을 이용하여 사용자 정보 불러오기
  Future<Map<String, dynamic>?> fetchUserInfo(String targetId) async {
    QuerySnapshot fs = await FirebaseFirestore.instance
        .collection('USER')
        .where('EMAIL', isEqualTo: targetId)
        .get();
    List<DocumentSnapshot> qs = fs.docs;
    var targetInfo;
    if (qs.isNotEmpty) {
      targetInfo = qs.first.data();
      return targetInfo;
    } else {
      print('해당 사용자를 찾을 수 없습니다.');
      return null;
    }
  }

  // 읽지 않은 메시지 개수 불러오기
  Stream<int> nonReadMessage(String chattingId, String userId) {
    CollectionReference fs = FirebaseFirestore.instance
        .collection('Chatting')
        .doc(chattingId)
        .collection('Messages');

    return fs
        .where('SenderId', isNotEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<DocumentSnapshot> list = snapshot.docs.where((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data != null &&
            data.containsKey('CheckYn') &&
            data['CheckYn'] == false;
      }).toList();
      return list.length;
    });
  }

  // 채팅방 목록 Widget
  Widget ChattingTile(BuildContext context) {
    return FutureBuilder(
      future: initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Chatting')
                .orderBy('LastMessageTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              // 채팅방 목록
              var chatRooms = snapshot.data!.docs.where((doc) {
                return doc['Users'].contains(currentUserId);
              }).toList();

              if (chatRooms.length == 0) {
                return Center(
                  child: Text('현재 대화중인 상대가 없습니다😅'),
                );
              }

              return ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  var chatRoom = chatRooms[index]; //채팅정보
                  var targetId; //대화상대 정보
                  for (int i = 0; i < chatRoom['Users'].length; i++) {
                    if (chatRoom['Users'][i] != currentUserId) {
                      targetId = chatRoom['Users'][i];
                    }
                  }
                  return FutureBuilder<Map<String, dynamic>?>(
                    future: fetchUserInfo(targetId),
                    builder: (context, snapShot) {
                      Map<String, dynamic>? targetInfo =
                          snapShot.data; //대화상대 정보
                      if (targetInfo == null) {
                        return Container();
                      }

                      String lastMessageTime = formatTimestamp(
                          chatRoom['LastMessageTime'] ??
                              ''); // 한국식 시간 포맷
                      return StreamBuilder<int>(
                        stream: nonReadMessage(chatRoom.id, currentUserId),
                        builder: (context, snapshot) {
                          bool nonReadFlg = false;
                          String readCnt = '';

                          if (snapshot.hasData) {
                            if (int.parse(snapshot.data.toString()) > 0) {
                              nonReadFlg = true;
                              if (int.parse(snapshot.data.toString()) > 300) {
                                readCnt = '300+';
                              } else {
                                readCnt = snapshot.data.toString();
                              }
                            }
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chatting(
                                          chatRoomId: chatRoom.id,
                                          targetId: targetId,
                                          targetNickName: targetInfo['NAME'])));
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                '${targetInfo['IMAGES'][0]}'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Flexible(
                                      flex: 7,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        '${targetInfo['NAME']}',
                                                        style: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 20,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                    // Icon(
                                                    //   Icons.check_circle,
                                                    //   color: Colors.green,
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                '$lastMessageTime',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${chatRoom['LastMessage'] ?? ''}',
                                                  style: TextStyle(
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              if (nonReadFlg)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    color: Colors.red,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5, 2, 5, 2),
                                                    child: Text(
                                                      '$readCnt',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 3;
    return MaterialApp(
      routes: {
        'loginMain': (context) => LogInMain(), // LogInMain.dart 파일의 화면
      },
      title: 'ChattingList',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: SizedBox(
            width: 95,
            child: Image.asset(
              "assets/mainlogo.png",
              width: 75,
              height: 75,
            ),
          ),
          actions: [
            // IconButton(
            //   icon: Icon(Icons.settings, color: Colors.grey),
            //   onPressed: () {
            //     // 설정 버튼 클릭 시 동작 추가
            //   },
            // ),
            // IconButton(
            //   icon: Icon(Icons.notifications, color: Colors.grey),
            //   onPressed: () {
            //     // 알림 버튼 클릭 시 동작 추가
            //   },
            // ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '메시지',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 4,
                      color: Colors.black),
                ),
                Expanded(
                  child: ChattingTile(context),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: bottom.CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
