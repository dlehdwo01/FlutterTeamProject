import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterteamproject/Home/bottomNavi.dart';
import 'dart:io';

class UserProfile {
  final String name;
  final int age;
  final String imageUrl;
  final bool isLocalImage;
  final String? introduce;
  final int? height;
  final int? weight;
  final String gender;
  final String character;
  final List<String>? interests;
  final String? alcohol;
  final String? exercise;
  final String? pets;
  final String? smoking;
  final String? company;
  final String? education;
  final String? hopeBaby;
  final String? school;
  final String? baby;

  UserProfile({
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.isLocalImage,
    this.introduce,
    this.height,
    this.weight,
    required this.gender,
    required this.character,
    this.interests,
    this.alcohol,
    this.exercise,
    this.pets,
    this.smoking,
    this.company,
    this.education,
    this.hopeBaby,
    this.school,
    this.baby,
  });
}

class ProfileDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> profiles;
  final int initialIndex;

  ProfileDetailPage({required this.profiles, required this.initialIndex});

  @override
  _ProfileDetailPageState createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late int currentIndex;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _validateCurrentIndex();
  }

  void _validateCurrentIndex() {
    if (currentIndex < 0 || currentIndex >= widget.profiles.length) {
      currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileData = widget.profiles[currentIndex];
    final List<dynamic>? images = profileData['IMAGES'] as List<dynamic>?;

    if (profileData == null || images == null || images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('프로필 상세'),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        ),
        body: Center(child: Text('프로필 정보를 가져올 수 없습니다.')),
      );
    }

    final String imageUrl = images[currentImageIndex] as String;
    final bool isLocalImage = !imageUrl.startsWith('http');

    final userProfile = UserProfile(
      name: profileData['NAME'] ?? '',
      age: calculateAge(profileData['BIRTH']),
      imageUrl: imageUrl,
      isLocalImage: isLocalImage,
      introduce: profileData['INTRODUCE'] ?? '',
      height: (profileData['INFO']?['height'] as num?)?.toInt(),
      weight: (profileData['INFO']?['weight'] as num?)?.toInt(),
      gender: profileData['GENDER'] ?? '',
      character: profileData['INFO']?['character'] ?? '',
      interests: (profileData['INTERESTS'] as List<dynamic>?)
          ?.map((interest) => interest.toString())
          .toList(),
      alcohol: profileData['LIFESTYLE']?['alcohol'] ?? '',
      exercise: profileData['LIFESTYLE']?['exercise'] ?? '',
      pets: profileData['LIFESTYLE']?['pets'] ?? '',
      smoking: profileData['LIFESTYLE']?['smoking'] ?? '',
      company: profileData['INFO']?['company'] ?? '',
      education: profileData['INFO']?['education'] ?? '',
      hopeBaby: profileData['INFO']?['hopeBaby'] ?? '',
      school: profileData['INFO']?['school'] ?? '',
      baby: profileData['INFO']?['baby'] ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/Back.png',color: Colors.grey,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              userProfile.name,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '${userProfile.age}세',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black12,
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  images.length,
                      (index) => _buildSmallBox(index, images.length),
                ),
              ),
              SizedBox(height: 5),
              Container(
                height: 480,
                child: Stack(
                  children: [
                    _buildImageBox(userProfile.imageUrl, userProfile.isLocalImage),
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (currentImageIndex > 0) {
                                    currentImageIndex--;
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (currentImageIndex < images.length - 1) {
                                    currentImageIndex++;
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              _buildProfileSection(
                title: '자기 소개',
                iconPath: 'assets/introduce.png',
                content: userProfile.introduce != null && userProfile.introduce!.isNotEmpty
                    ? Text(
                  userProfile.introduce!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                )
                    : Text(
                  '아직 자기 소개가 작성되지 않았습니다.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildProfileSection(
                title: '기본 정보',
                iconPath: 'assets/Profile.png',
                content: _buildBasicInfo(userProfile),
              ),
              SizedBox(height: 10),
              _buildProfileSection(
                title: '나만의 TMI',
                iconPath: 'assets/tag.png',
                content: _buildTmiInfo(userProfile),
              ),
              SizedBox(height: 10),
              _buildProfileSection(
                title: '관심사',
                iconPath: 'assets/tag.png',
                content: _buildInterests(userProfile.interests),
              ),
              SizedBox(height: 10),
              _buildProfileSection(
                title: '라이프스타일',
                iconPath: 'assets/tag.png',
                content: _buildLifestyle(userProfile),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            _validateCurrentIndex();
          });
        },
      ),
    );
  }

  Widget _buildImageBox(String imageUrl, bool isLocalImage) {
    return Container(
      width: 450,
      height: 480,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: isLocalImage
            ? Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
        )
            : Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSmallBox(int index, int totalImages) {
    double containerWidth = MediaQuery.of(context).size.width / totalImages - 8;

    return Flexible(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: containerWidth,
        height: 5,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: currentImageIndex == index ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required String iconPath,
    required Widget? content,
  }) {
    if (content == null) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  color: Colors.grey,
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget? _buildBasicInfo(UserProfile userProfile) {
    final basicInfo = <String>[];

    if (userProfile.height != null) {
      basicInfo.add('키: ${userProfile.height} cm');
    }
    if (userProfile.weight != null) {
      basicInfo.add('몸무게: ${userProfile.weight} kg');
    }
    basicInfo.add('성별: ${userProfile.gender == 'M' ? '남자' : '여자'}');

    if (basicInfo.isEmpty)
      return Text('아직 기본 정보가 작성되지 않았습니다.', style: TextStyle(color: Colors.black, fontSize: 16));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: basicInfo.map((info) => Text(info, style: TextStyle(color: Colors.black, fontSize: 16))).toList(),
    );
  }

  Widget? _buildInterests(List<String>? interests) {
    if (interests == null || interests.isEmpty)
      return Text('아직 관심사가 작성되지 않았습니다.', style: TextStyle(color: Colors.black, fontSize: 16));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: interests.map((interest) => Text(interest, style: TextStyle(color: Colors.black, fontSize: 16))).toList(),
    );
  }

  Widget? _buildLifestyle(UserProfile userProfile) {
    final lifestyleInfo = <String>[];

    if (userProfile.alcohol != null && userProfile.alcohol!.isNotEmpty) {
      lifestyleInfo.add('음주: ${userProfile.alcohol}');
    }
    if (userProfile.exercise != null && userProfile.exercise!.isNotEmpty) {
      lifestyleInfo.add('운동: ${userProfile.exercise}');
    }
    if (userProfile.pets != null && userProfile.pets!.isNotEmpty) {
      lifestyleInfo.add('애완동물: ${userProfile.pets}');
    }
    if (userProfile.smoking != null && userProfile.smoking!.isNotEmpty) {
      lifestyleInfo.add('흡연: ${userProfile.smoking}');
    }

    if (lifestyleInfo.isEmpty)
      return Text('아직 라이프스타일 정보가 작성되지 않았습니다.', style: TextStyle(color: Colors.black, fontSize: 16));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lifestyleInfo.map((info) => Text(info, style: TextStyle(color: Colors.black, fontSize: 16))).toList(),
    );
  }

  Widget? _buildTmiInfo(UserProfile userProfile) {
    final tmiInfo = <String>[];

    if (userProfile.character.isNotEmpty) {
      tmiInfo.add('성격: ${userProfile.character}');
    }
    if (userProfile.company != null && userProfile.company!.isNotEmpty) {
      tmiInfo.add('회사: ${userProfile.company}');
    }
    if (userProfile.education != null && userProfile.education!.isNotEmpty) {
      tmiInfo.add('학력: ${userProfile.education}');
    }
    if (userProfile.hopeBaby != null && userProfile.hopeBaby!.isNotEmpty) {
      tmiInfo.add('아이를 낳을 계획: ${userProfile.hopeBaby}');
    }
    if (userProfile.school != null && userProfile.school!.isNotEmpty) {
      tmiInfo.add('학교: ${userProfile.school}');
    }
    if (userProfile.baby != null && userProfile.baby!.isNotEmpty) {
      tmiInfo.add('아이: ${userProfile.baby}');
    }

    if (tmiInfo.isEmpty) return Text('아직 TMI가 작성되지 않았습니다.', style: TextStyle(color: Colors.black, fontSize: 16));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tmiInfo.map((info) => Text(info, style: TextStyle(color: Colors.black, fontSize: 16))).toList(),
    );
  }

  int calculateAge(String? birth) {
    if (birth != null && birth.length == 8) {
      final year = int.tryParse(birth.substring(0, 4)) ?? 0;
      final month = int.tryParse(birth.substring(4, 6)) ?? 0;
      final day = int.tryParse(birth.substring(6, 8)) ?? 0;
      if (year != 0 && month != 0 && day != 0) {
        final birthDateTime = DateTime(year, month, day);
        final now = DateTime.now();
        int age = now.year - birthDateTime.year;
        if (now.month < birthDateTime.month ||
            (now.month == birthDateTime.month && now.day < birthDateTime.day)) {
          age--;
        }
        return age;
      }
    }
    return 0;
  }
}
