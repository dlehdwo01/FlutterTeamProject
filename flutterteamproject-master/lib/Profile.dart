import 'package:flutter/material.dart';
import 'package:flutterteamproject/CommunityMain.dart';
import 'package:provider/provider.dart';
import 'EditProfile.dart';
import 'Home/bottomNavi.dart' as bottom;
import 'Setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseFirestore fs=FirebaseFirestore.instance;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 4;

  // field
  String? nickName;
  int? age;
  List? images;
  int? followersCount;
  int? followingCount;
  List<String> userImages = [];
  List<String> followersList = [];  // 팔로워 리스트
  List<String> followingList = [];  // 팔로잉 리스트
  List<String> userImageIds = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  // 만 나이 변환 함수
  int calculateAge(String birthDateString) {
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // 데이터 불러오기
  void fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String docId = prefs.getString('email') ?? '';
    DocumentSnapshot snapShot=await fs.collection('USER').doc(docId).get();
    Map<String,dynamic> userData=snapShot.data() as Map<String, dynamic>;

    String birth=userData['BIRTH'] ?? '';
    QuerySnapshot followersSnapshot = await fs.collection('USER').doc(docId).collection('Follower').get();
    QuerySnapshot followingSnapshot = await fs.collection('USER').doc(docId).collection('Following').get();
    QuerySnapshot communitySnapshot = await fs.collection('Community').where('userId', isEqualTo: docId).get();
    setState(() {
      nickName =userData['NAME'] ?? '';
      age = calculateAge(birth);
      images = userData['IMAGES'];
      followersCount = followersSnapshot.docs.length;
      followingCount = followingSnapshot.docs.length;
      followersList = followersSnapshot.docs.map((doc) => doc.id).toList();
      followingList = followingSnapshot.docs.map((doc) => doc.id).toList();
      userImages = communitySnapshot.docs.map((doc) => doc['imgLink'] as String).toList();
    });
  }

  void showListDialog(List<String> list, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(list[index]),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // 설정 버튼 클릭 시 동작 추가
              Navigator.push(context, MaterialPageRoute(builder: (context) => Setting(),));

            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(),));
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                      radius: 100,
                      child: ClipOval(
                        child: images!=null ? Image.network(images?[0],
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ) : CircularProgressIndicator(),
                      )
                  ),
                  Positioned(
                    right: -10,
                    top: 10,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(),));
                      },
                      child: Container(
                        child: Icon(Icons.edit,color: Colors.grey,size: 20,),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(50))
                        ),
                        width: 50,
                        height: 50,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                nickName!=null&&age!=null ? Text('$nickName, $age',style: TextStyle(
                    fontSize: 20
                ),) : CircularProgressIndicator(),
                SizedBox(width: 10,),
                // Icon(Icons.check_circle,color: Colors.green,size: 25,)
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => showListDialog(followersList, '팔로워'),
                  child: Container(
                    child: followersCount != null && followingCount != null
                        ? Text('팔로워: $followersCount', style: TextStyle(fontSize: 16))
                        : CircularProgressIndicator(),
                  ),
                ),
                GestureDetector(
                  onTap: () => showListDialog(followingList, '팔로잉'),
                  child: Container(
                    child: followingCount != null
                        ? Text(' | 팔로잉: $followingCount', style: TextStyle(fontSize: 16))
                        : CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: userImages.length,
                  itemBuilder: (context, index) {
                    return userImages.length != null
                        ? Image.network(userImages[index], fit: BoxFit.cover)
                        : Text('등록된 게시글이 없습니다.', style: TextStyle(fontSize: 25));
                  },
                ),
              ),
            ),
          ],
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
    );
  }
}