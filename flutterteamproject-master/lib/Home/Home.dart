import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterteamproject/Home/Setting.dart';
import 'package:flutterteamproject/Home/Alarm.dart';
import 'package:flutterteamproject/Home/bottomNavi.dart';
import 'package:flutterteamproject/LogIn/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterteamproject/Home/ProfileDetailPage.dart';
import '../LogIn/LogInMain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');

  Widget initialPage;
  if (email != null) {
    initialPage = MyDatingApp(loggedInEmail: email);
  } else {
    initialPage = Login();
  }

  runApp(MaterialApp(
    title: 'Dating App',
    theme: ThemeData(
      primaryColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: initialPage,
  ));
}

class MyDatingApp extends StatelessWidget {
  final String loggedInEmail;


  MyDatingApp({required this.loggedInEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'loginMain': (context) => LogInMain(), // LogInMain.dart 파일의 화면
      },
      title: 'Dating App',
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(loggedInEmail: loggedInEmail),
    );
  }
}

class HomePage extends StatefulWidget {
  final String loggedInEmail;

  HomePage({required this.loggedInEmail});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _currentUserEmail;
  Future<DocumentSnapshot?>? _currentUserData;
  List<String> _userEmails = [];
  List<String> _followingEmails = [];
  String? loggedInEmail;
  bool _noMoreUsers = false;
  Map<String, dynamic> targetInfo={};
  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    loggedInEmail = prefs.getString('email');
    if (loggedInEmail != null) {
      await _fetchFollowingEmails();
      await _fetchUserEmails();
      _loadRandomUser();
    }
  }

  Future<void> _fetchUserEmails() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('USER').get();
    List<String> emails = snapshot.docs.map((doc) => doc['EMAIL'] as String).toList();
    setState(() {
      _userEmails = emails.where((email) => email != loggedInEmail).toList();
    });
  }

  Future<void> _fetchFollowingEmails() async {
    if (loggedInEmail != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('USER')
          .doc(loggedInEmail)
          .collection('Following')
          .get();
      List<String> followingEmails = snapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _followingEmails = followingEmails;
      });
    }
  }

  void _loadRandomUser(){
    if (_userEmails.isNotEmpty) {
      List<String> availableEmails = _userEmails
          .where((email) => !_followingEmails.contains(email))
          .toList();
      if (availableEmails.isNotEmpty) {
        final randomIndex = Random().nextInt(availableEmails.length);
        _currentUserEmail = availableEmails[randomIndex];
        _currentUserData = _fetchUserData(_currentUserEmail!);

        _noMoreUsers = false; // 유저가 있을 경우 false로 설정
      } else {
        // 팔로잉하지 않은 유저가 없는 경우 처리
        _currentUserEmail = null;
        _currentUserData = null;
        _noMoreUsers = true; // 유저가 없을 경우 true로 설정
      }
    } else {
      _currentUserEmail = null;
      _currentUserData = null;
      _noMoreUsers = true;
    }
  }


  Future<DocumentSnapshot?> _fetchUserData(String email) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('USER')
        .where('EMAIL', isEqualTo: email)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      targetInfo = snapshot.docs.first.data() as Map<String, dynamic>;
      return snapshot.docs.first;
    }
    return null;
  }

  Future<void> _loadNextUser() async {
    await _fetchFollowingEmails(); // 팔로잉 목록을 갱신
    setState(() {
      _loadRandomUser();
    });
  }

  void _loadPreviousUser() {
    setState(() {
      _loadRandomUser();
    });
  }

  void _checkAndFollowUser() async {
    if (loggedInEmail != null && _currentUserEmail != null) {
      // 팔로워 컬렉션에서 로그인된 유저의 하위에 해당 유저가 존재하는지 확인
      DocumentSnapshot followerDoc = await FirebaseFirestore.instance
          .collection('USER')
          .doc(loggedInEmail)
          .collection('Follower')
          .doc(_currentUserEmail)
          .get();

      if (followerDoc.exists) {
        // 매칭 컬렉션에 상대방 정보 추가
        await FirebaseFirestore.instance
            .collection('USER')
            .doc(loggedInEmail)
            .collection('Matching')
            .doc(_currentUserEmail)
            .set({'EMAIL': _currentUserEmail});

        await FirebaseFirestore.instance
            .collection('USER')
            .doc(_currentUserEmail)
            .collection('Matching')
            .doc(loggedInEmail)
            .set({'EMAIL': loggedInEmail});

        await FirebaseFirestore.instance
            .collection('USER')
            .doc(_currentUserEmail)
            .collection('Alram')
            .doc(loggedInEmail)
            .set({'EMAIL': loggedInEmail,'Content' : '님이 매칭되었습니다!', 'sendTime' : Timestamp.now()});

        await FirebaseFirestore.instance
            .collection('USER')
            .doc(loggedInEmail)
            .collection('Alram')
            .doc(_currentUserEmail)
            .set({'EMAIL': _currentUserEmail,'Content' : '님이 매칭되었습니다!', 'sendTime' : Timestamp.now()});

        DocumentReference profileRef =
        FirebaseFirestore.instance.collection('USER').doc(loggedInEmail);
        await profileRef.collection('Following').doc(_currentUserEmail).set({});
        DocumentReference userRef =
        FirebaseFirestore.instance.collection('USER').doc(_currentUserEmail);
        await userRef.collection('Follower').doc(loggedInEmail).set({});

        // Chatting 컬렉션에 문서 추가
        DocumentReference chatDocRef = await FirebaseFirestore.instance.collection('Chatting').add({
          'Users': [loggedInEmail, _currentUserEmail],
          'CreatedAt': Timestamp.now(),
          'LastMessageTime': Timestamp.now(),
          'LastMessage': "매칭이 완료되었어요! 서로 대화를 시작해 보세요!",
        });

        // Add a new document to the subcollection 'Messages' of the newly created document
        await chatDocRef.collection('Messages').add({
          'Content': "매칭이 완료되었어요! 서로 대화를 시작해 보세요!",
          'SendTime': Timestamp.now(),
          'SenderId': 'admin',
        });


        print('매칭이 완료되었습니다.');
      } else {
        // 팔로잉 컬렉션에 추가
        DocumentReference profileRef =
        FirebaseFirestore.instance.collection('USER').doc(loggedInEmail);
        await profileRef.collection('Following').doc(_currentUserEmail).set({});
        DocumentReference userRef =
        FirebaseFirestore.instance.collection('USER').doc(_currentUserEmail);
        await userRef.collection('Follower').doc(loggedInEmail).set({});

        await FirebaseFirestore.instance
            .collection('USER')
            .doc(_currentUserEmail)
            .collection('Alram')
            .doc(loggedInEmail)
            .set({'EMAIL': loggedInEmail,'Content' : '님이 팔로우 하셨습니다!', 'sendTime' : Timestamp.now()});
        print('팔로잉이 완료되었습니다.');
      }

      // 다음 유저 로드
      _loadNextUser();
    }
  }

  void moveDetail() async{
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailPage(
          profiles: [targetInfo], // Map<String, dynamic> 형태로 전달
          initialIndex: 0,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 95,
          child: Image.asset(
            "assets/mainlogo.png",
            width: 75,
            height: 75,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          NotificationIcon(),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => SettingPage()),
          //     );
          //   },
          //   child: Container(
          //     margin: EdgeInsets.only(right: 28),
          //     child: Image.asset(
          //       color: Colors.grey,
          //       'assets/setting.png',
          //       width: 23,
          //       height: 23,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Center(
        child: _noMoreUsers
            ? Text('더이상 보여드릴 프로필이 없어요 😢', style: TextStyle(fontSize: 20, color: Colors.black,))
            : FutureBuilder<DocumentSnapshot?>(
          future: _currentUserData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('오류: ${snapshot.error}', style: TextStyle(color: Colors.white,)),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text('검색중', style: TextStyle(color: Colors.white,)),
              );
            }

            final profile = snapshot.data!;
            return CardStack(
              profile: profile,
              loadNextUser: _loadNextUser,
              loadPreviousUser: _loadPreviousUser,
              checkAndFollowUser: _checkAndFollowUser,
              moveDetail : moveDetail// 추가된 부분
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(right: 30),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            child: Image.asset(
              color: Colors.grey,
              'assets/Alarm.png',
              width: 23,
              height: 23,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class CardStack extends StatefulWidget {
  final DocumentSnapshot profile;
  final VoidCallback loadNextUser;
  final VoidCallback loadPreviousUser;
  final VoidCallback checkAndFollowUser;
  final VoidCallback moveDetail;


  const CardStack({
    Key? key,
    required this.profile,
    required this.loadNextUser,
    required this.loadPreviousUser,
    required this.checkAndFollowUser,
    required this.moveDetail

  }) : super(key: key);

  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profileData = widget.profile.data() as Map<String, dynamic>;
    final List<dynamic>? images = profileData['IMAGES'] as List<dynamic>?;

    if (profileData == null || images == null || images.isEmpty) {
      return Container();
    }

    final String imageUrl = images[currentImageIndex] as String;

    final String? birthDate = profileData['BIRTH'];
    DateTime? dateTime;
    if (birthDate != null && birthDate.length == 8) {
      final year = int.tryParse(birthDate.substring(0, 4));
      final month = int.tryParse(birthDate.substring(4, 6));
      final day = int.tryParse(birthDate.substring(6, 8));
      if (year != null && month != null && day != null) {
        dateTime = DateTime(year, month, day);
      }
    }

    int age = 0;
    if (dateTime != null) {
      final now = DateTime.now();
      age = now.year - dateTime.year;
      if (now.month < dateTime.month ||
          (now.month == dateTime.month && now.day < dateTime.day)) {
        age--;
      }
    }

    return Stack(
      children: [
        _buildBackgroundImage(imageUrl),
        Positioned.fill(
          child: Column(
            children: [
              SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  images.length,
                      (index) => _buildSmallBox(index, images.length),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (currentImageIndex > 0) {
                                currentImageIndex--;
                              }
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (currentImageIndex < images.length - 1) {
                                currentImageIndex++;
                              }
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (profileData.isNotEmpty)
                Container(
                  height: 100,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(padding: const EdgeInsets.only(left: 20)),
                              GestureDetector(
                                onTap: widget.moveDetail,
                                child: Text(
                                  profileData['NAME'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(padding: const EdgeInsets.only(left: 5)),
                              Text(
                                '$age',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 0),
                              //   child: Image.asset(
                              //     'assets/Badge.png',
                              //     width: 30,
                              //     height: 30,
                              //     fit: BoxFit.cover,
                              //   ),
                              // ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Image.asset(
                                  'assets/Location.png',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(padding: const EdgeInsets.only(left: 5)),
                              Text(
                                '100km 거리에 있음',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSmallButton(
                    icon: Icons.undo,
                    color: Colors.yellowAccent,
                    onTap: widget.loadPreviousUser,
                  ),
                  _buildLargeButton(
                    icon: Icons.close,
                    color: Colors.green,
                    onTap: widget.loadNextUser,
                  ),
                  _buildSmallButton(
                    icon: Icons.star,
                    color: Colors.lightBlue,
                    onTap: () {},
                  ),
                  _buildLargeButton(
                    icon: Icons.favorite,
                    color: Colors.red,
                    onTap: widget.checkAndFollowUser, // 수정된 부분
                  ),
                  _buildSmallButton(
                    icon: Icons.dark_mode,
                    color: Colors.deepPurpleAccent,
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildSmallBox(int index, int totalImages) {
    double containerWidth = MediaQuery.of(context).size.width / totalImages - 8;

    return Flexible(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: containerWidth,
        height: 5,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: currentImageIndex == index ? Colors.grey: Colors.grey,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 57,
        height: 57,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            icon,
            color: color,
            size: 41,
          ),
        ),
      ),
    );
  }
}
