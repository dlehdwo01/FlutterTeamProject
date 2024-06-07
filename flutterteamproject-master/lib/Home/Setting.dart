import 'package:flutter/material.dart';
import 'package:flutterteamproject/Home/bottomNavi.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _bottomNavigationBarIndex = 4; // 기본적으로 설정 페이지는 네비게이션 바에서 마지막 탭 (프로필)로 설정
  double _distance = 10.0; // 초기 거리 설정 (예: 5km)
  String _selectedGender = ''; // 선택된 성별을 저장할 변수 추가
  RangeValues _ageRange = RangeValues(18, 100); // 최소 및 최대 나이를 설정할 변수 추가

  void _onNavBarTap(int index) {
    setState(() {
      _bottomNavigationBarIndex = index;
    });
    // 각 탭에 대한 동작 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/Back.png',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: <Widget>[
          ListTile(
            tileColor: Colors.black,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '상대방과의 거리',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${_distance.toStringAsFixed(1)} km',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Slider(
              value: _distance,
              min: 0.0,
              max: 600.0,
              onChanged: (newValue) {
                setState(() {
                  _distance = newValue;
                });
              },
              activeColor: Colors.grey,
              inactiveColor: Colors.white,
            ),
          ),
          Divider(color: Colors.grey), // 경계선 추가
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '상대의 성별: $_selectedGender', // 선택된 성별을 보여줄 텍스트 추가
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            '성별 선택',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedGender = '남성'; // 남성 선택 시 상태 갱신
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15.0),
                                    child: Text(
                                      '남성',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedGender = '여성'; // 여성 선택 시 상태 갱신
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15.0),
                                    child: Text(
                                      '여성',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey), // 경계선 추가
          ListTile(
            tileColor: Colors.black,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '상대의 나이',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${_ageRange.start.round()} - ${_ageRange.end.round()} 세',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: RangeSlider(
              values: _ageRange,
              min: 18,
              max: 100,
              onChanged: (newRange) {
                setState(() {
                  _ageRange = newRange;
                });
              },
              activeColor: Colors.grey,
              inactiveColor: Colors.white,
              divisions: 82, // 100 - 18
              labels: RangeLabels(
                _ageRange.start.round().toString(),
                _ageRange.end.round().toString(),
              ),
            ),
          ),
          Divider(color: Colors.grey), // 경계선 추가
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _bottomNavigationBarIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}