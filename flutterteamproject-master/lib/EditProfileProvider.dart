import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';

// Provider
class ProfileProvider with ChangeNotifier{
  bool flg = false; // 프로필 수정 페이지 로드시 유저 정보를 한번만 불러오기 위한 flg
  List _imgList=[]; // 프로필 이미지 주소들
  String? _introduce; // 자기소개 문구
  Map<String,dynamic> _lifeStyle = {}; // 라이프스타일
  Map<String,dynamic> _myInfo = {}; // 내 정보
  List<String> _interests = []; // 관심사
  String? _residence; // 거주 지역
  String? _nickName; // 닉네임
  int? _currentAge; // 만 나이
  String? _docId; // 문서ID
  String? _birth;

  // 만 나이 계산 함수
  int calculateAge(String birthDateString) {
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // 현재 유저 정보 불러오기
  void fetchData() async{
    if(flg){
      return;
    }

    final FirebaseFirestore fs=FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prefsDocId = prefs.getString('email') ?? '';

    DocumentSnapshot snapShot=await fs.collection('USER').doc(prefsDocId).get();
    Map<String,dynamic> userData=snapShot.data() as Map<String, dynamic>; // 유저 데이터

    List<String> dbImgList = List<String>.from(userData['IMAGES']); // 프로필 사진들

    String dbIntroduce = userData['INTRODUCE']??''; // 자기소개
    Map<String,dynamic> dbLifeStyle = userData['LIFESTYLE'] ?? {}; // 라이프스타일
    List<String> dbInterests = List<String>.from(userData['INTERESTS']??[]); // 관심사


    Map<String,dynamic> dbInfo = userData['INFO'] ?? {}; // 내정보

    if(dbInfo!=null) {
      if (dbInfo.containsKey('height')) {
        dbInfo['height'] = double.parse('${dbInfo['height']}'); // 타입변환
      }
      if (dbInfo.containsKey('weight')) {
        dbInfo['weight'] = double.parse('${dbInfo['weight']}'); // 타입변환
      }
    }

    String dbResidence = userData['RESIDENCE'] ?? ''; // 거주 지역
    String dbNickName = userData['NAME']??''; // 이름
    String dbBirth = userData['BIRTH'] ?? ''; // 생년월일


    // 프로필 사진들
    for (int i = 0; i < dbImgList.length; i++) {
      _imgList.add({'original': dbImgList[i]});
     }

    _birth = dbBirth;
    _introduce = dbIntroduce; // 자기소개
    _lifeStyle = dbLifeStyle; // 라이프스타일
    _interests= dbInterests; // 관심사
    _myInfo=dbInfo; // 나의 정보
    _residence=dbResidence; // 거주 지역
    _nickName = dbNickName; // 이름
    _currentAge=calculateAge(dbBirth); // 만 나이
    _docId=prefsDocId; // 문서ID


    // 최초 한번만 실행
    flg=true;
    notifyListeners();
  }

  // get
  List get imgList => _imgList;
  Map<String,dynamic> get lifeStyle => _lifeStyle;
  Map<String,dynamic> get myInfo => _myInfo;
  List<String> get interests => _interests;
  String get introduce =>_introduce??'';
  String get residence =>_residence??'';
  String get nickName =>_nickName??'';
  int get currentAge =>_currentAge??20;
  String get docId=>_docId??'';
  String get birth=>_birth??'';


  // 자기소개 입력받기
  void setIntroduce(String str){
    _introduce=str;
    notifyListeners();
  }

  // 거주 지역 입력받기
  void setResidence(String str){
    _residence=str;
    notifyListeners();
  }


  // 프로필 이미지 추가(임시)
  void addImgList(File file){
    _imgList.add({'new' : file});
    notifyListeners();
  }

  // 프로필 이미지 삭제
  void removeImgList(int index){
    _imgList.removeAt(index);
    notifyListeners();
  }

  // 라이프스타일 설정
  void setLifeStyle (Map<String,dynamic> map) {
    _lifeStyle=map;
    notifyListeners();
  }

  // 관심사 설정
  void setInterests (List<String> list) {
    _interests=list;
    notifyListeners();
  }

  // 내 정보 설정
  void setMyInfo (Map<String,dynamic> map) {
    _myInfo=map;
    notifyListeners();
  }

  // 키 공개/비공개 바꾸기
  void changeHeightFlg(){
    if(myInfo['heightFlg']){
      myInfo['heightFlg']=false;
    } else{
      myInfo['heightFlg']=true;
    }
    notifyListeners();
  }

  // 몸무게 공개/비공개 바꾸기
  void changeWeightFlg(){
    if(myInfo['weightFlg']){
      myInfo['weightFlg']=false;
    } else{
      myInfo['weightFlg']=true;
    }
    notifyListeners();
  }

}