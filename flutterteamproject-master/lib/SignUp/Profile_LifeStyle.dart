import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterteamproject/CustomWidget/CustomButton.dart';
import 'package:flutterteamproject/CustomWidget/CustomButtonColor.dart';
import 'package:flutterteamproject/EditProfileProvider.dart';
import 'package:flutterteamproject/SignUp/Profile_OtherInfo.dart';
import 'package:provider/provider.dart';

class LifeStyleInfo extends StatefulWidget {
  final String email;
  const LifeStyleInfo({super.key, required this.email});

  @override
  State<LifeStyleInfo> createState() => _LifeStyleInfoState();
}

class _LifeStyleInfoState extends State<LifeStyleInfo> {

  Map<String, String> select = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  final List<String> pets = [
    '강아지', '고양이', '파충류', '양서류',
    '새', '물고기', '거북이', '햄스터',
    '토끼', '기타', '동물 알러지 있음', '키우고 싶음', '없음'
  ];

  final List<String> alcohol = [
    '아예 안 마심', '가끔 마심', '자주 마심', '매일 마심',
    '혼술할 정도로 좋아하는 편', '친구들 만날 때만 마시는 편', '현재 금주 중'
  ];

  final List<String> smoking = [
    '다른 흡연자가 있을 때만', '술 마실 때만', '흡연', '비흡연', '금연 중'
  ];

  final List<String> excercise = [
    '매일', '자주', '가끔', '안함'
  ];

  // 구분선 출력
  Widget divider (){
    return
      Padding(
        padding: const EdgeInsets.fromLTRB(20,0,20,20),
        child: Container(
          height: 1,
          color: Colors.grey,
        ),
      );
  }

  // 안내 문구 출력
  Widget guideMessage(String message, Icon icon){
    return Row(
      children: [
        SizedBox(width: 20,),
        icon,
        SizedBox(width: 10,),
        Text(message,style: TextStyle(fontWeight: FontWeight.w600),)
      ],
    );
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void saveLifestyleData() async {
    try {
      await _firestore.collection('USER').doc(widget.email).set({
        'LIFESTYLE': select
      }, SetOptions(merge: true));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyInfo(email: widget.email)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터 저장에 실패했습니다: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {

    // 클릭 박스 출력
    Widget printItem (List<String> list, String listName) {
      return
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 10.0,
              runSpacing: 10.0,
              children: list.map((item) {
                bool isSelected = select[listName] == item;
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      if (isSelected) {
                        select[listName] = '';  // 선택 해제
                      } else {
                        select[listName] = item;  // 새 아이템 선택
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: select[listName]==item ? Colors.red : Colors.grey
                        )
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10,5,10,5),
                      child: Text(item,style: TextStyle(
                      )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
    }

    return
      ChangeNotifierProvider(
          create: (context) => ProfileProvider(),
          child:  Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                    onPressed: saveLifestyleData,
                    child: Text('다음'))
              ],
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Text('라이프스타일',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ),),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text('나를 가장 잘 나타내는 라이프스타일을 추가해 보세요')
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    //controller: _scrollController,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        // 반려동물
                        guideMessage(
                            '키우는 반려동물이 있나요?',
                            Icon(Icons.pets, size : 20)
                        ),
                        printItem(pets,'pets'),
                        divider(),
                        //술
                        guideMessage(
                            '술은 얼마나 자주 드세요?',
                            Icon(Icons.wine_bar, size : 20)
                        ),
                        printItem(alcohol,'alcohol'),
                        divider(),

                        // 흡연
                        guideMessage(
                            '나의 평균 흡연량은?',
                            Icon(Icons.smoking_rooms, size : 20)
                        ),
                        printItem(smoking,'smoking'),
                        divider(),

                        // 운동
                        guideMessage(
                            '운동 하시나요?',
                            Icon(Icons.fitness_center, size : 20)
                        ),
                        printItem(excercise, 'excercise'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
      );


  }
}


