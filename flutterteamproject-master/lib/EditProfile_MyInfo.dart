import 'package:flutter/material.dart';
import 'package:flutterteamproject/EditProfileProvider.dart';
import 'package:flutter/cupertino.dart';

class EditMyInfo extends StatefulWidget {
  final ProfileProvider provider;
  final selectStyle;
  EditMyInfo({required this.provider, this.selectStyle});

  @override
  State<EditMyInfo> createState() => _EditMyInfoState();
}

class _EditMyInfoState extends State<EditMyInfo> {
  late Map<String,dynamic> select;
  ScrollController _scrollController = ScrollController();
  TextEditingController _school = TextEditingController();
  TextEditingController _company = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    select =  Map<String,dynamic>.from(widget.provider.myInfo);
    if(!select.containsKey('height')){
      select['height']=150.0;
    }
    if(!select.containsKey('heightFlg')){
      select['heightFlg']=false;
    }
    if(!select.containsKey('weight')){
      select['weight']=50.0;
    }
    if(!select.containsKey('weightFlg')){
      select['weightFlg']=false;
    }
    print(select);
    _school.text=select['school']??'';
    _company.text=select['company']??'';


    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // 화면이 로드된 후 최하단으로 스크롤
      if(widget.selectStyle == 'down') {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 1000),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.provider;

    List<String> bodyType = [
      '덩치가 작음','슬림','슬림 탄탄','보통','통통','건강미','글래머','덩치가 큼','근육질'
    ];

    List<String> education = [
    '직업전문학교','고등학교 졸업','전문대학 졸업','대학교 졸업','박사','대학원 재학중'
    ];

    List<String> character = [
      'INTJ','INTP','ENTJ','ENTP', 'INFJ', 'INFP','ENFJ','ENFP','ISTJ','ISFJ','ESTJ','ESFJ',
      'ENFP','ISTJ','ISFJ','ESTJ','ESFJ','ISTP','ISFP','ESTP','ESFP',
    ];

    final List<String> baby = [
      '1명','2명','3명',
      '있음', '없음'
    ];

    List<String> salary = [
      '3천만원 미만','5천만원 미만', '7천만원 미만', '1억원 미만', '1억원 초과'
    ];

    List<String> hopeBaby = [
      '있다','없다'
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
                  select[text] = minValue  + index.toDouble(); // Example range from 140 to 200
                });
              },
              scrollController: FixedExtentScrollController(
                initialItem: (defaultValue - minValue).toInt()
              ),
              children: List<Widget>.generate(range, (index) {
                return Text(
                  '${minValue  + index}', // Example range from 140 to 200
                  style: TextStyle(fontSize: 20.0),
                );
              }),
            ),
          ),
        ],
      );
    }


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
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      if(select[listName]==item){
                        select[listName]='';
                        return;
                      }
                      select[listName]=item;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: select[listName] ==item ? Colors.red : Colors.grey
                        )
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10,5,10,5),
                      child: Text(item,style: TextStyle(
                          color: select[listName]==item ? Colors.red : Colors.grey
                      )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
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

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Icon(Icons.close)
          ),
          actions: [
            TextButton(
                onPressed: (){
                  select['school']=_school.text;
                  select['company']=_company.text;
                  profile.setMyInfo(select);
                  Navigator.pop(context);
                },
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
          controller: _scrollController,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              guideMessage('키, 몸무게',Icon(Icons.accessibility,size: 20,)),
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
                                  Text('키 공개하기'),
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
                                  Text('몸무게 공개하기'),
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
