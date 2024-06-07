import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> alarmList = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // 알림 목록을 Firebase에서 가져오고 저장하는 메서드
  Future<void> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Firebase에서 알림 데이터 가져오기
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('USER')
        .doc(prefs.getString('email'))
        .collection('Alram')
        .get();

    // querySnapshot의 문서 데이터를 리스트로 변환
    setState(() {
      alarmList = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 알림 상대 정보 가져오기
  Future<Map<String, dynamic>> fetchTargetInfo(String email) async {
    FirebaseFirestore fs = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await fs.collection('USER').doc(email).get();
    return snapshot.data() as Map<String, dynamic>;
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: alarmList.length,
          itemBuilder: (context, index) {
            final alarm = alarmList[index];
            return FutureBuilder<Map<String, dynamic>>(
                future: fetchTargetInfo(alarm['EMAIL']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('No Data'));
                  } else {
                    final targetInfo = snapshot.data!;
                    return ListTile(
                      leading: targetInfo['IMAGES'] != null && targetInfo['IMAGES'].isNotEmpty
                          ? ClipOval(
                        child: Image.network(
                          targetInfo['IMAGES'][0],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(Icons.person),
                      title: Text('${targetInfo['NAME']} ${alarm['Content']}'),
                      subtitle: Text(formatTimestamp(alarm['sendTime'])),
                    );
                  }
                }
            );
          },
        ),
      ),
    );
  }
}
