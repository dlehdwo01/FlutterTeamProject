import 'package:flutter/material.dart';
import 'package:flutterteamproject/CommunityMain.dart';
import '../Profile.dart' as editProfile;
import 'package:flutterteamproject/ChattingList.dart';
import 'package:flutterteamproject/Like.dart' as likePage;
import 'Home.dart' as home;
import 'package:shared_preferences/shared_preferences.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  Future<String?> sessionCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    return email;
  }

  @override
  Widget build(BuildContext context) {
    const int itemCount = 5; // BottomNavigationBar items 개수
    final int validIndex = (currentIndex >= 0 && currentIndex < itemCount) ? currentIndex : 0;

    return Container(
      child: BottomNavigationBar(
        currentIndex: validIndex,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        elevation: 0, // 그림자 제거
        onTap: (index) {
          onTap(index);
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => home.MyDatingApp(loggedInEmail: 'asdfrg')),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => likePage.DatingHomePage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChattingList()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => editProfile.Profile()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/home.png', width: 24, height: 24, color: Colors.grey,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/Community.png', width: 24, height: 24, color: Colors.grey,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/moon.png', width: 24, height: 24, color: Colors.grey,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/Talk.png', width: 24, height: 24, color: Colors.grey,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/Profile.png', width: 24, height: 24, color: Colors.grey,),
            label: '',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        iconSize: 32,
        selectedIconTheme: IconThemeData(size: 32),
        unselectedIconTheme: IconThemeData(size: 32),
        // 아이템 간의 간격 조절
        selectedLabelStyle: TextStyle(height: 0),
        unselectedLabelStyle: TextStyle(height: 0),
      ),
    );
  }
}
