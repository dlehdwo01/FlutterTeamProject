import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterteamproject/SignUp/Profile_LifeStyle.dart';

class InterestsInfo extends StatefulWidget {
  final String email;
  const InterestsInfo({super.key, required this.email});


  @override
  State<InterestsInfo> createState() => _InterestsInfoState();
}

class _InterestsInfoState extends State<InterestsInfo> {
  List<String> selectedInterests = [];
  List<String> list = [
    '동네 산책', '한강에서 치맥', '만화카페', 'PC방', 'K-드라마', '오버워치', '합기도', '테니스', '주짓수', '태권도', '아쿠아리움', '유도', '마라톤', '방탈출 카페', '캠핑'
  ];

  void _toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else if (selectedInterests.length < 5) {
        selectedInterests.add(interest);
      }
    });
  }

  Future<void> _saveInterestsAndNavigate() async {
    if(selectedInterests.length == 0){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LifeStyleInfo(email: widget.email)),
      );
      return;
    }
    CollectionReference users = FirebaseFirestore.instance.collection('USER');
    await users.doc(widget.email).update({
      'INTERESTS': selectedInterests
    }).then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LifeStyleInfo(email: widget.email)),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('관심사를 저장하는데 실패했습니다: $error'))
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
                onPressed: _saveInterestsAndNavigate,
                child: Text('다음'))
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text('관심사', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('${selectedInterests.length}/5'),
                      SizedBox(width: 20)
                    ],
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 20),
                  Text('최대 5개의 관심사를 프로필에 추가하고 대화를 훨씬 더 쉽게\n시작해 보세요')
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: list.map((item) {
                          bool isSelected = selectedInterests.contains(item);
                          return GestureDetector(
                            onTap: () => _toggleInterest(item),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: isSelected ? Colors.red : Colors.grey)
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Text(item, style: TextStyle(color: isSelected ? Colors.red : Colors.grey)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
