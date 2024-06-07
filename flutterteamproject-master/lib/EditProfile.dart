import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';

// dart 파일
import 'EditProfileProvider.dart';
import 'EditProfile_LifeStyle.dart';
import 'EditProfile_Interests.dart';
import 'EditProfile_MyInfo.dart';
import 'EditProfile_Preview.dart';
import 'Profile.dart';

class EditProfile extends StatefulWidget {
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider(
        create: (context) => ProfileProvider(),
        child: ProfileEditPage(),
      );
  }
}

class ProfileEditPage extends StatefulWidget {
  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  bool isSelected = true;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore fs=FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final profile=Provider.of<ProfileProvider>(context); // Profile Provider
    profile.fetchData();

    // 완료 버튼 클릭시
    Future<void> updateProfile(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List images=profile.imgList; // provider의 img 리스트
      List updateImages=[]; // db에 적용시킬 리스트
      String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // 저장될 파일명(밀리세컨시간)
      Reference ref = storage.ref().child('images/$fileName'); // 저장될 주소

      // 로딩 인디케이터를 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // 기등록된 파일인지 신규 파일인지 검증
      for(int i=0; i<images.length; i++){
        if(images[i].containsKey('original')){
          updateImages.add(images[i]['original']);
        }else{
          await ref.putFile(File(images[i]['new'].path)); // 업로드
          String downloadURL = await ref.getDownloadURL(); // URL 변환
          updateImages.add(downloadURL);
        }
      }

      // db 데이터 변경
      await fs.collection('USER').doc(profile.docId).update({
        'IMAGES' : updateImages,
        'INFO' : profile.myInfo,
        'INTERESTS' : profile.interests,
        'INTRODUCE' : profile.introduce,
        'LIFESTYLE' : profile.lifeStyle,
        'RESIDENCE' : profile.residence,
      });
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(),));
    }
    
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Stack(
          children: [
            Center(
              child: Text(
                isSelected ? '프로필 수정' : '미리보기',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Positioned(
              bottom: -10,
              right: 0,
              child: TextButton(
                onPressed: () {
                  // 완료 버튼 클릭 시 동작할 코드 작성
                  updateProfile(context);
                },
                child: Text(
                  '완료',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: 0,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '취소',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼을 숨김
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // 수정하기 버튼 클릭 시 동작할 코드 작성
                    setState(() {
                      isSelected=true;
                    });
                  },
                  child: Text('수정하기', style: TextStyle(
                      color: isSelected ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold,fontSize: 18)),
                ),
              ),
              Container(
                width: 1.0,
                height: 30.0,
                color: Colors.grey,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // 미리보기 버튼 클릭 시 동작할 코드 작성

                    setState(() {
                      isSelected=false;
                    });
                  },
                  child: Text('미리보기', style: TextStyle(
                      color: !isSelected ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold,fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
      // 수정하기 클릭 or 미리보기 클릭
      body: isSelected ? ModifyWidget( // 수정하기
        provider : profile
      ) : Preview(provider : profile),
    );
  }
}


// 수정하기 위젯
class ModifyWidget extends StatefulWidget {
  final ProfileProvider provider;
  ModifyWidget({required this.provider});

  @override
  State<ModifyWidget> createState() => _ModifyWidgetState();
}

class _ModifyWidgetState extends State<ModifyWidget> {
  TextEditingController _introduceController =TextEditingController();
  TextEditingController _residenceController =TextEditingController();
  ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();





  @override
  Widget build(BuildContext context) {
    final profile = widget.provider;
    _introduceController.text=profile.introduce;
    _residenceController.text=profile.residence;

    // 이미지 선택시 provider imgList에 담기
    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          profile.addImgList(File(pickedFile.path));
        });
      }
    }

    Widget image (int index) {
      if(profile.imgList!=null){
        if(profile.imgList[index].containsKey('original')){
          return Image.network(profile.imgList[index]['original'] ,
            fit: BoxFit.cover,
            width: (MediaQuery.of(context).size.width -20-16)/3,
            height: (MediaQuery.of(context).size.width -20-16)/3 * 4/3);
        } else{
          return Image.file(profile.imgList[index]['new'],
            fit: BoxFit.cover,
            width: (MediaQuery.of(context).size.width -20-16)/3,
            );
        }
      } else{
        return CircularProgressIndicator();
      }
    }

    return GestureDetector(
      onTap: () {
        // 스크롤이 발생했을 때 포커스를 제거하여 자판을 숨김
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.circle,size: 7,color: Colors.red,),
                        SizedBox(
                          width: 5,
                        ),
                        Text('콘텐츠',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5,2,5,2),
                            child: Text('지금 추가하기',style: TextStyle(color: Colors.white,fontSize: 11),),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: (MediaQuery.of(context).size.width -20)/3*4/3*2+10,
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 8,
                          crossAxisCount: 3,
                          childAspectRatio: 3 / 4,

                        ),
                        itemBuilder: (context, index) {
                          if(profile.imgList.length>index) { // 프로필 사진 있을 때 출력 화면
                            return GestureDetector(
                              onTap: (){
                                profile.removeImgList(index);
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,

                                    ),
                                    child: ClipRRect(
                                      child:image(index),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  Positioned(
                                    right: -5,
                                    bottom: -8,
                                    child: Container(
                                      child: Icon(Icons.remove, color: Colors.white, size: 30),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          else { // 프로필 사진 없을 때 출력 화면
                            return GestureDetector(
                              onTap: () {
                                _pickImage();
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,

                                    ),
                                  ),
                                  Positioned(
                                    right: -5,
                                    bottom: -8,
                                    child: Container(
                                      child: Icon(Icons.add, color: Colors.white, size: 30),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.circle,size: 7,color: Colors.red,),
                        SizedBox(
                          width: 5,
                        ),
                        Text('자기소개',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5,2,5,2),
                            child: Text('중요',style: TextStyle(color: Colors.white,fontSize: 11),),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Stack(
                  children: [
                    TextFormField(
                      onChanged: (value){
                        profile.setIntroduce(value);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      maxLength: 500,
                      controller: _introduceController,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.circle,size: 7,color: Colors.red,),
                            SizedBox(
                              width: 5,
                            ),
                            Text('라이프스타일',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                ListTile(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context)=>LifeStyle(provider: profile,)));
                  },
                  leading: Icon(Icons.pets),
                  title: Text('반려동물'),
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context)=>LifeStyle(provider: profile,)));
                  },
                  leading: Icon(Icons.wine_bar_rounded),
                  title: Text('음주'),
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context)=>LifeStyle(provider: profile,)));
                  },
                  leading: Icon(Icons.smoking_rooms),
                  title: Text('흡연량'),
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context)=>LifeStyle(provider: profile))
                    );
                  },
                  leading: Icon(Icons.fitness_center),
                  title: Text('운동'),
                  trailing: Icon(Icons.navigate_next),
                ),
              ],
            ),
            Container(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Icon(Icons.circle,size: 7,color: Colors.red,),
                            SizedBox(
                              width: 5,
                            ),
                            Text('관심사',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
           ListTile(
             onTap: (){
               Navigator.push(context, MaterialPageRoute(builder: (context) => Interests(provider:profile),));
             },
             title: Text('관심사 추가하기'),
             trailing: Icon(Icons.navigate_next),
           ),
            Container(
              color: Colors.grey,
              child: Padding(
                padding:EdgeInsets.fromLTRB(10,15,10,10),
                child: Row(
                  children: [
                    Icon(Icons.circle,size: 7,color: Colors.red,),
                    SizedBox(
                      width: 5,
                    ),
                    Text('나에 대한 정보',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
                  ],
                ),
              ),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile),));
              },
              leading: Icon(Icons.accessibility),
              title: Text('키, 몸무게'),
              trailing: Icon(Icons.navigate_next),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile),));
              },
              leading: Icon(Icons.grade),
              title: Text('체형'),
              trailing: Icon(Icons.navigate_next),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile),));
              },
              leading: Icon(Icons.school),
              title: Text('학력'),
              trailing: Icon(Icons.navigate_next),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile),));
              },
              leading: Icon(Icons.location_city),
              title: Text('학교'),
              trailing: Icon(Icons.navigate_next),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile),));
              },
              leading: Icon(Icons.business_center),
              title: Text('직장'),
              trailing: Icon(Icons.navigate_next),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile),));
              },
              leading: Icon(Icons.baby_changing_station),
              title: Text('자녀'),
              trailing: Icon(Icons.navigate_next),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile,selectStyle: 'down',),));
              },
              leading: Icon(Icons.child_friendly),
              title: Text('가족 계획'),
              trailing: Icon(Icons.navigate_next),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile,selectStyle: 'down',),));
              },
              leading: Icon(Icons.money),
              title: Text('연봉'),
              trailing: Icon(Icons.navigate_next),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMyInfo(provider:profile,selectStyle: 'down'),));
              },
              leading: Icon(Icons.extension),
              title: Text('MBTI'),
              trailing: Icon(Icons.navigate_next),
            ),
            Container(
              color: Colors.grey,
              child: Padding(
                padding:EdgeInsets.fromLTRB(10,15,10,10),
                child: Row(
                  children: [
                    Icon(Icons.circle,size: 7,color: Colors.red,),
                    SizedBox(
                      width: 5,
                    ),
                    Text('거주 지역',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
                  ],
                ),
              ),
            ),
            TextField(
              controller: _residenceController,
              onChanged: (value){
                profile.setResidence(value);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10,20,10,20),
                hintText: '거주 지역을 입력하세요'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
