import 'package:flutter/material.dart';
import 'package:flutterteamproject/EditProfileProvider.dart';
import 'dart:io';
import 'Home/ProfileDetailPage.dart';

class Preview extends StatefulWidget {
  final ProfileProvider provider;
  const Preview({required this.provider});

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  int currentImageIndex = 0;

  // 나이 계산 함수
  int calculateAge(String birthDateString) {
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.provider;

    // 프로필 사진
    Widget _buildBackgroundImage(Map map) {
      if (map.containsKey('original')) {
        return Image.network(
          map['original'],
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        );
      } else {
        return Image.file(
          map['new'],
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        );
      }
    }

    // 상단 바(이미지 개수, 현재 이미지 알림바)
    Widget _buildSmallBox(int index, int totalImages) {
      double containerWidth = totalImages == 1
          ? MediaQuery.of(context).size.width / totalImages - 50
          : MediaQuery.of(context).size.width / totalImages - 15;

      return Flexible(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          width: containerWidth,
          height: 4,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: currentImageIndex == index ? Colors.white : Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 50),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Stack(
              children: [
                if (profile.imgList.isNotEmpty)
                  _buildBackgroundImage(profile.imgList[currentImageIndex]),
                Positioned.fill(
                  child: Column(
                    children: [
                      SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          profile.imgList.length,
                              (index) =>
                              _buildSmallBox(index, profile.imgList.length),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
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
                                flex: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (currentImageIndex <
                                          profile.imgList.length - 1) {
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
                      ),
                      if (profile.imgList.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileDetailPage(
                                  profiles: [
                                    {
                                      'NAME': profile.nickName,
                                      'BIRTH': profile.birth, // 생년월일 임의 설정
                                      'IMAGES': profile.imgList
                                          .map((img) => img.containsKey(
                                          'original')
                                          ? img['original']
                                          : img['new'].path)
                                          .toList(),
                                      'INTRODUCE': profile.introduce,
                                      'INFO': profile.myInfo,
                                      'GENDER': 'M', // 성별 임의 설정
                                      'INTERESTS': profile.interests,
                                      'LIFESTYLE': profile.lifeStyle,
                                    }
                                  ],
                                  initialIndex: 0,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                  Colors.black.withOpacity(0.8),
                                  Colors.black,
                                ],
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              '${profile.nickName}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '${profile.currentAge}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 23,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Icon(
                                              Icons.info_outline,
                                              size: 30,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    profile.introduce != ''
                                        ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20),
                                      child: Text(
                                        '${profile.introduce}',
                                        style: TextStyle(
                                            color: Colors.white),
                                      ),
                                    )
                                        : Container(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20),
                                          child: Image.asset(
                                            'assets/Location.png',
                                            width: 18,
                                            height: 18,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5)),
                                        Text(
                                          '1km 이내',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
