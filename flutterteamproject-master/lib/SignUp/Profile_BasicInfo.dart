import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterteamproject/CustomWidget/CustomButtonColor.dart';
import 'package:flutterteamproject/Models/Profile_Model.dart';
import 'package:flutterteamproject/SignUp/SignUpCompleted.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpProfile extends StatelessWidget {

  const SignUpProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MyWidget());
  }
}


class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late TextEditingController _nameCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _residenceCtrl;
  late TextEditingController _introduceCtrl;
  String? gender;
  late List<File> _selectedImages;
  bool _isUploading = false;

  //프로필 이미지 업로드
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Controller 초기화
    _nameCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
    _residenceCtrl = TextEditingController();
    _introduceCtrl = TextEditingController();
    _selectedImages = [];

    Future.delayed(Duration.zero, () {
      final profile = Provider.of<ProfileModel>(context, listen: false);
      setState(() {
        _nameCtrl.text = profile.name ?? '';
        _dateCtrl.text = profile.dateOfBirth ?? '';
        gender = profile.gender ?? 'Male';
        _selectedImages = profile.selectedImages;
      });
    });
  }

  // 이미지 선택
  Future<void> _pickImage(int index) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        if (index < _selectedImages.length) {
          _selectedImages[index] = File(pickedImage.path);
        } else {
          _selectedImages.add(File(pickedImage.path));
        }
      });
    }
  }

  // 선택한 이미지 지우기
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        // margin: EdgeInsets.all(10),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30,),
                Text('회원님의 사진을 등록해주세요', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10,),
                Container(
                  color: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
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
                          // 이미지 선택시
                          if (_selectedImages.length>index){
                            return GestureDetector(
                              onTap: (){
                                _removeImage(index);
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
                                      child:Image.file(_selectedImages[index],
                                        fit: BoxFit.cover,
                                        width: (MediaQuery.of(context).size.width -20-16)/3,
                                        height: (MediaQuery.of(context).size.width -20-16)/3 * 4/3,
                                      ),
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
                            );}
                          else { // 이미지가 없을 경우
                            return GestureDetector(
                              onTap: () {
                                _pickImage(index);
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
                                      child: Icon(
                                          Icons.add, color: Colors.white,
                                          size: 30),
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
                  ),
                ),
                SizedBox(height: 15,),
                Text(' 이름은 무엇인가요?', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: ' 프로필에 표시될 이름입니다.',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 15,),
                Text(' 생일은 언제인가요?', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _dateCtrl,
                  maxLength: 8,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '생년(예: 1980) / 월(예: 07) / 일(예: 08)로 입력해주세요',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 15,),
                Text(' 성별을 선택해주세요', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('남성'),
                        leading: Radio<String>(
                          value: 'Male',
                          groupValue: gender,
                          onChanged: (String? value) {
                            setState(() {
                              gender = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('여성'),
                        leading: Radio<String>(
                          value: 'Female',
                          groupValue: gender,
                          onChanged: (String? value) {
                            setState(() {
                              gender = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Text(' 어디에 거주하고 계신가요?', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _residenceCtrl,
                  decoration: InputDecoration(
                    hintText: ' 거주지를 입력해주세요',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 20,),
                Text(' 자기소개 부탁드립니다.', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _introduceCtrl,
                  decoration: InputDecoration(
                    hintText: ' 자기를 멋지게 표현해보아요',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                ),
                SizedBox(height: 20,),
                Container(
                  alignment: Alignment.center,
                  child: CustomColorButton(
                      buttonText: ' 회원가입',
                      onPressed: _submitProfileData
                  ),
                ),
                SizedBox(height: 50,),
              ],
            )
          ],
        ),
      ),
    );
  }


  void _submitProfileData() {
    if (_selectedImages.isEmpty || _nameCtrl.text.isEmpty || _dateCtrl.text.isEmpty || gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('선택되지 않거나 입력하지 않는 항목이 존재합니다.')),
      );
      return;
    }
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
    final profile = Provider.of<ProfileModel>(context, listen: false);
    profile.updateName(_nameCtrl.text);
    profile.updateDateOfBirth(_dateCtrl.text);
    profile.updateGender(gender!);
    profile.updateSelectedImages(_selectedImages);
    profile.updateSelectedIntroduce(_introduceCtrl.text);
    profile.updateSelectedResidence(_residenceCtrl.text);
    _saveUserdata();
  }

  Future<void> _saveUserdata() async {
    final profile = Provider.of<ProfileModel>(context, listen: false);

    setState(() {
      _isUploading = true;
    });

    try {
      // 이미지 업로드
      List<String> imageUrls = await _uploadImages(profile);
      // Firestore에 저장
      await _saveUserData(profile, imageUrls);

      setState(() {
        _isUploading = false;
      });

      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('email', profile.email);
      Navigator.of(context, rootNavigator: true).pop();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpWaiting(email: profile.email)),
      );

      Provider.of<ProfileModel>(context, listen: false).reset();

    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Future<List<String>> _uploadImages(ProfileModel profile) async {
    List<String> imageUrls = [];
    for (File image in profile.selectedImages) {
      String fileName = image.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profiles/${profile.email}/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  Future<void> _saveUserData(ProfileModel profile, List<String> imageUrls) async {
    CollectionReference users = FirebaseFirestore.instance.collection('USER');
    Map<String, dynamic> userData = {
      'EMAIL' : profile.email,
      'IMAGES': imageUrls,
      'NAME': profile.name,
      'BIRTH': profile.dateOfBirth,
      'GENDER': profile.gender == 'Male' ? 'M' : 'F',
      'CDATETIME': Timestamp.now(),
      'PHONE' : profile.phoneNumber,
      'RESIDENCE' : profile.residence,
      'INTRODUCE' : profile.introduce

    };

    if (profile.password != '') {
      userData['PWD'] = profile.password;
    }
    await users.doc(profile.email).set(userData, SetOptions(merge: true));
  }

}
