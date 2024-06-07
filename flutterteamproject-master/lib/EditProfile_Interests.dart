import 'package:flutter/material.dart';
import 'package:flutterteamproject/EditProfileProvider.dart';
import 'EditProfileProvider.dart';

class Interests extends StatefulWidget {
  final ProfileProvider provider;
  Interests({required this.provider});

  @override
  State<Interests> createState() => _InterestsState();
}

class _InterestsState extends State<Interests> {
  // late List select;
  late List<String> select;
  List<String> list= [
    '동네 산책','한강에서 치맥','만화카페',
    'PC방','K-드라마','오버워치','합기도','테니스','주짓수','태권도','아쿠아리움','유도','마라톤','방탈출 카페','캠핑'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    select=widget.provider.interests;
  }


  @override
  Widget build(BuildContext context) {
    final profile = widget.provider;
    ScrollController _scrollController = ScrollController();

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
                  profile.setInterests(select);
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
                    Text('관심사',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ),),
                  ],
                ),
                Row(
                  children: [
                    Text('${select.length}/5'),
                    SizedBox(width: 20,)
                  ],
                )

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
                Text('최대 5개의 관심사를 프로필에 추가하고 대화를 훨씬 더 쉽게\n시작해 보세요')
              ],
            ),
            SizedBox(
              height: 10,
            ),
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
                        bool flg=select.contains(item);
                        return GestureDetector(
                          onTap: (){
                            if(select.contains(item)){
                              setState(() {
                                select.remove(item);
                              });
                              return;
                            }
                            if(select.length>=5){
                              return;
                            }
                            setState(() {
                              if(!select.contains(item)){
                                select.add(item);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: flg?  Colors.red :Colors.grey
                                )
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10,5,10,5),
                              child: Text(item,style: TextStyle(
                                  color: flg?  Colors.red :Colors.grey
                              )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
