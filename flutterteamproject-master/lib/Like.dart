import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterteamproject/Home/bottomNavi.dart';
import 'package:flutterteamproject/Home/ProfileDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterteamproject/LogIn/LogInMain.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'loginMain': (context) => LogInMain(), // LogInMain.dart 파일의 화면
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DatingHomePage(),
    );
  }
}

class DatingHomePage extends StatefulWidget {
  @override
  _DatingHomePageState createState() => _DatingHomePageState();
}

class _DatingHomePageState extends State<DatingHomePage> {
  int currentIndex = 0;
  List<Map<String, dynamic>> todayPicks = [];
  List<Map<String, dynamic>> likePicks = [];
  List<Map<String, dynamic>> followingPicks = [];
  bool isLoading = true;
  bool isLoadingLikes = true;
  bool isLoadingFollowing = true;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    loadCurrentUserEmail();
  }

  Future<void> loadCurrentUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('email');
    });
    getRandomUserEmails();
    getFollowers();
    getFollowing();
  }

  Future<void> getFollowers() async {
    try {
      if (currentUserEmail == null) return;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('USER')
          .doc(currentUserEmail)
          .collection('Follower')
          .get();

      List<String> followerEmails = querySnapshot.docs.map((doc) => doc.id).toList();
      await getUsersByEmails(followerEmails, isLike: true);
    } catch (e) {
      print("Error getting followers: $e");
      setState(() {
        isLoadingLikes = false;
      });
    }
  }

  Future<void> getFollowing() async {
    try {
      if (currentUserEmail == null) return;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('USER')
          .doc(currentUserEmail)
          .collection('Following')
          .get();

      List<String> followingEmails = querySnapshot.docs.map((doc) => doc.id).toList();
      await getUsersByEmails(followingEmails, isFollowing: true);
    } catch (e) {
      print("Error getting following: $e");
      setState(() {
        isLoadingFollowing = false;
      });
    }
  }

  void changeIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> getRandomUserEmails() async {
    try {
      if (currentUserEmail == null) return;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('USER').get();
      List<String> allEmails = querySnapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('EMAIL') && data['EMAIL'] != currentUserEmail) {
          return data['EMAIL'] as String;
        } else {
          return null;
        }
      })
          .where((email) => email != null)
          .cast<String>()
          .toList();
      allEmails.shuffle();

      // 상위 6개의 이메일만 사용
      List<String> limitedEmails = allEmails.take(6).toList();
      await getUsersByEmails(limitedEmails);
    } catch (e) {
      print("Error getting documents: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getUsersByEmails(List<String> emails, {bool isLike = false, bool isFollowing = false}) async {
    try {
      List<Map<String, dynamic>> users = [];
      for (String email in emails) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('USER').where('EMAIL', isEqualTo: email).get();
        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first;
          if (userData != null && userData['IMAGES'] != null && userData['IMAGES'].isNotEmpty) {
            users.add(userData.data() as Map<String, dynamic>);
          }
        }
      }

      setState(() {
        if (isLike) {
          likePicks = users;
          isLoadingLikes = false;
        } else if (isFollowing) {
          followingPicks = users;
          isLoadingFollowing = false;
        } else {
          todayPicks = users;
          isLoading = false;
        }
      });
    } catch (e) {
      print("Error getting user documents: $e");
      setState(() {
        if (isLike) {
          isLoadingLikes = false;
        } else if (isFollowing) {
          isLoadingFollowing = false;
        } else {
          isLoading = false;
        }
      });
    }
  }

  Widget buildTabView(String title) {
    return Center(
      child: Text(title, style: TextStyle(color: Colors.black)),
    );
  }

  Widget buildLikeView() {
    if (isLoadingLikes) {
      return Center(child: CircularProgressIndicator());
    }
    if (likePicks.isEmpty) {
      return Center(child: Text("No followers found", style: TextStyle(color: Colors.black)));
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: likePicks.length,
      itemBuilder: (BuildContext context, int index) {
        var user = likePicks[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileDetailPage(
                  profiles: likePicks,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(5),
            child: Stack(
              children: [
                Container(
                  height: 310,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(user['IMAGES'][0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      user['NAME'] ?? 'Unknown',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildFollowingView() {
    if (isLoadingFollowing) {
      return Center(child: CircularProgressIndicator());
    }
    if (followingPicks.isEmpty) {
      return Center(child: Text("No followings found", style: TextStyle(color: Colors.black)));
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: followingPicks.length,
      itemBuilder: (BuildContext context, int index) {
        var user = followingPicks[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileDetailPage(
                  profiles: followingPicks,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(5),
            child: Stack(
              children: [
                Container(
                  height: 310,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(user['IMAGES'][0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      user['NAME'] ?? 'Unknown',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTodayPickView() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: todayPicks.length,
      itemBuilder: (BuildContext context, int index) {
        var user = todayPicks[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileDetailPage(
                  profiles: todayPicks,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(5),
            child: Stack(
              children: [
                Container(
                  height: 310,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(user['IMAGES'][0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      user['NAME'] ?? 'Unknown',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        centerTitle: true, // 제목을 가운데로 정렬
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => changeIndex(0),
                    child: CustomPaint(
                      painter: BoxBorderPainter(
                        showRightBorder: true,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center, // 텍스트를 가운데로 정렬
                        child: Text(
                          'LIKE',
                          style: TextStyle(
                            color: currentIndex == 0 ? Colors.black : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => changeIndex(1),
                    child: CustomPaint(
                      painter: BoxBorderPainter(
                        showRightBorder: true,
                        showLeftBorder: true,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center, // 텍스트를 가운데로 정렬
                        child: Text(
                          '내가 보낸 LIKE',
                          style: TextStyle(
                            color: currentIndex == 1 ? Colors.black : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => changeIndex(2),
                    child: CustomPaint(
                      painter: BoxBorderPainter(
                        showLeftBorder: true,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center, // 텍스트를 가운데로 정렬
                        child: Text(
                          '오늘의 PICK',
                          style: TextStyle(
                            color: currentIndex == 2 ? Colors.black : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: [
                  buildLikeView(),
                  buildFollowingView(),
                  buildTodayPickView(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class BoxBorderPainter extends CustomPainter {
  final bool showLeftBorder;
  final bool showRightBorder;

  BoxBorderPainter({
    this.showLeftBorder = false,
    this.showRightBorder = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    if (showLeftBorder) {
      canvas.drawLine(Offset(0, size.height * 0.2), Offset(0, size.height * 0.8), paint);
    }

    if (showRightBorder) {
      canvas.drawLine(Offset(size.width, size.height * 0.2), Offset(size.width, size.height * 0.8), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
