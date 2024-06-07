
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterteamproject/Home/Home.dart';
import 'package:flutter/cupertino.dart';

class MyInfo extends StatefulWidget {
  final String email;
  const MyInfo({super.key, required this.email});

  @override
  State<MyInfo> createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  TextEditingController _school = TextEditingController();
  TextEditingController _company = TextEditingController();

  Map<String, dynamic> select = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      select['height'] = 150.0;
      select['weight'] = 50.0;
      select['heightFlg'] = false;
      select['weightFlg'] = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    List<String> education = [
      '직업전문학교','고등학교 졸업','전문대학 졸업','대학교 졸업','박사','대학원 재학중'
    ];

    List<String> character = [
      'INTJ','INTP','ENTJ','ENTP', 'INFJ', 'INFP','ENFJ','ENFP','ISTJ','ISFJ','ESTJ','ESFJ',
      'ISTP','ISFP','ESTP','ESFP',
    ];

    final List<String> baby = [
      '1명','2명','3명',
      '있음', '없음'
    ];

    List<String> hopeBaby = [
      '있다','없다'
    ];

    List<String> salary = [
      '3천만원 미만','5천만원 미만', '7천만원 미만', '1억원 미만', '1억원 초과'
    ];

    List<String> bodyType = [
      '덩치가 작음','슬림','슬림 탄탄','보통','통통','건강미','글래머','덩치가 큼','근육질'
    ];


    // 입력 박스 출력
    Widget inputText (TextEditingController textCtrl, String text) {
      return  Padding(
        padding: const EdgeInsets.fromLTRB(20,10,20,0),
        child: TextField(
          controller: textCtrl,
          decoration: InputDecoration(
              hintText: text,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none
          ),
        ),
      );
    }

    // 클릭 박스 출력
    Widget printItem(List<String> list, String category) {

      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 10.0,
            runSpacing: 10.0,
            children: list.map((item) => GestureDetector(
              onTap: () {
                setState(() {
                  bool isSelected = select[category] == item;
                  if (isSelected) {
                    select[category] = '';  // 선택 해제
                  } else {
                    select[category] = item;  // 새 아이템 선택
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),  // 간격 조정
                decoration: BoxDecoration(
                  border: Border.all(
                    color: select[category] == item ? Colors.red : Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(item),
              ),
            )).toList(),
          ),
        ),
      );
    }

// 키, 몸무게 입력 박스 출력
    Widget inputNumText (String text,double minValue, int range,double? defaultValue) {
      String str;
      if(text=='height'){
        str='키';
      }else{
        str='몸무게';
      }
      if(defaultValue==null){
        if(text=='height'){
          defaultValue=150;
        }else{
          defaultValue=50;
        }
      }
      return  Row(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20,20,20,20),
                child: Text(str,style:TextStyle(
                    fontWeight: FontWeight.bold,fontSize: 18
                )),
              ),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 32.0,
              onSelectedItemChanged: (index) {
                setState(() {
                  // Handle picker value change
                  select[text] = minValue  + index.toDouble();
                });
              },
              scrollController: FixedExtentScrollController(
                  initialItem: (defaultValue - minValue).toInt()
              ),
              children: List<Widget>.generate(range, (index) {
                return Text(
                  '${minValue  + index}',
                  style: TextStyle(fontSize: 20.0),
                );
              }),
            ),
          ),
        ],
      );
    }

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

    //데이터 베이스 저장
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    void saveMyInfoData() async {
      setState(() {
        select['school']=_school.text;
        select['company']=_company.text;
      });

      try {
        await _firestore.collection('USER').doc(widget.email).set({
          'INFO': select
        }, SetOptions(merge: true));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyDatingApp(loggedInEmail: '${widget.email}',)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터 저장에 실패했습니다: $e')));
      }
    }

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                  onPressed: saveMyInfoData,
                  child: Text('완료'))
            ],
          ),
          body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 20,),
                        Text('나에 대한 정보',style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25
                        ),),
                      ],
                    ),
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
                    Text('나를 가장 잘 나타내는 정보를 추가해 보세요'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          guideMessage('키(cm), 몸무게(kg)',Icon(Icons.accessibility,size: 20,)),
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(20,20,20,0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                if(select['heightFlg']==null){
                                                  select['heightFlg']=false;
                                                }
                                                select['heightFlg']=!select['heightFlg'];
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Text('키 입력하기'),
                                                Checkbox(
                                                    value: select['heightFlg'] ?? false, onChanged: (value){
                                                  setState(() {
                                                    if(select['heightFlg']==null){
                                                      select['heightFlg']=false;
                                                    }
                                                    select['heightFlg']=!select['heightFlg'];
                                                  });
                                                }),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (){

                                              setState(() {
                                                if(select['weightFlg']==null){
                                                  select['weightFlg']=false;
                                                }
                                                select['weightFlg']=!select['weightFlg'];
                                              });
                                              print(select['weightFlg']);
                                            },
                                            child: Row(
                                              children: [
                                                Text('몸무게 입력하기'),
                                                Checkbox(value: select['weightFlg']??false, onChanged: (value){
                                                  setState(() {
                                                    if(select['weightFlg']==null){
                                                      select['weightFlg']=false;
                                                    }
                                                    select['weightFlg']=!select['weightFlg'];
                                                  });
                                                })
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                          select['heightFlg']??false ? inputNumText('height',90,240,select['height'] ?? 150) : Container(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,20,0),
                            child: Container(
                              height: 1,
                              color: Colors.grey,
                            ),
                          ),
                          select['weightFlg']??false ? inputNumText ('weight',30,120,select['weight'] ?? 50) : Container(),
                          divider(),
                          guideMessage('나의 몸매', Icon(Icons.grade,size: 20,)),
                          printItem(bodyType,'bodyType'),
                          divider(),
                          guideMessage('나의 최종학력', Icon(Icons.school,size: 20,)),
                          printItem(education,'education'),
                          divider(),
                          guideMessage('출신 학교', Icon(Icons.location_city,size: 20,)),
                          inputText (_school, '출신 학교 또는 재학 중인 학교를 입력하세요'),
                          divider(),
                          guideMessage('재직중인 회사', Icon(Icons.business_center,size: 20,)),
                          inputText (_company, '소속된 단체 또는 회사를 입력하세요'),
                          divider(),
                          guideMessage('자녀 유무', Icon(Icons.baby_changing_station,size: 20,)),
                          printItem(baby,'baby'),
                          divider(),
                          guideMessage('아이를 가질 의향', Icon(Icons.child_friendly,size: 20,)),
                          printItem(hopeBaby,'hopeBaby'),
                          divider(),
                          guideMessage('나의 연봉', Icon(Icons.money,size: 20,)),
                          printItem(salary,'salary'),
                          divider(),
                          guideMessage('성격 유형을 알려줘!', Icon(Icons.extension,size: 20,)),
                          printItem(character,'character'),
                          divider()
                        ],
                      ),
                    )
                )
              ])
      ),
    );
  }
}
