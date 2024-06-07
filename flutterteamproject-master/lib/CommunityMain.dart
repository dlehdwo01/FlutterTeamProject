import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'Home/bottomNavi.dart' as bottom;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterteamproject/LogIn/LogInMain.dart';

void CommunityMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GlobalUser.fetchUserId(); // 여기서 fetchUserId 호출하여 userId 설정
  runApp(MyApp());
}

void main() {
  CommunityMain(); // main 함수에서 CommunityMain 호출
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BoardModel(),
      child: MaterialApp(
        routes: {
          'loginMain': (context) => LogInMain(), // LogInMain.dart 파일의 화면
        },
        home: BoardScreen(),
      ),
    );
  }
}

class PostCreationScreen extends StatefulWidget {
  @override
  _PostCreationScreenState createState() => _PostCreationScreenState();
}

class GlobalUser {
  static String userId = '';

  static Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('email') ?? ''; // 기본값을 'admin'으로 설정
  }

// 기본값을 'admin'으로 설정 (로그인된 사용자 ID로 변경 필요)
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  @override
  void initState() {
    super.initState();
    GlobalUser.fetchUserId();
  }

  final ImagePicker _picker = ImagePicker();
  final titleController = TextEditingController();
  final contentsController = TextEditingController();
  String _selectedCategory = '자유';
  File? _selectedImage;
  bool isLoading = false;
  final List<String> categories = ['자유', '운동', 'MBTI', '오운완', '레시피', '당근마켓'];

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      print("이미지를 선택해 주세요");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var storageRef = FirebaseStorage.instance
          .ref()
          .child('CommunityImage/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_selectedImage!);

      var downloadUrl = await storageRef.getDownloadURL();

      print("다운로드 주소: $downloadUrl");
      savePost(downloadUrl);
    } catch (e) {
      print("에러");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> savePost(var link) async {
    final String title = titleController.text;
    final String contents = contentsController.text;
    final String userId = GlobalUser.userId; // 전역 사용자 ID 사용
    final DateTime cdatetime = DateTime.now();

    if (titleController.text.isEmpty || contentsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('제목과 내용을 입력하세요.'),
        ),
      );
      return;
    } else {
      await FirebaseFirestore.instance.collection('Community').add({
        'title': title,
        'contents': contents,
        'userId': userId,
        'category': _selectedCategory,
        'cdatetime': cdatetime,
        'imgLink': link,
        'likeCount': 0 // 좋아요 수 필드 추가
      });

      // 저장 후 이전 화면으로 돌아가기

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickImage() async {
      XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('게시글 작성'),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: categories
                      .map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: '카테고리'),
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: '제목'),
                ),
                TextField(
                  controller: contentsController,
                  decoration: InputDecoration(labelText: '내용'),
                  maxLines: 5,
                ),
                if (_selectedImage != null) Image.file(_selectedImage!), // 미리보기
                ElevatedButton(
                  onPressed: isLoading ? null : _pickImage,
                  child: Text('이미지 선택'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 우측 정렬
                  children: [
                    ElevatedButton(
                      // _uploadImage
                      onPressed: _uploadImage,
                      child: Text('게시글 저장'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Post {
  final String id;
  final String title;
  final String contents;
  final String userid;
  final DateTime cdatetime;
  final String category;
  final String imgLink;
  int likeCount;
  int viewCount; // 조회수 필드

  Post({
    required this.id,
    required this.title,
    required this.contents,
    required this.userid,
    required this.cdatetime,
    required this.category,
    required this.imgLink,
    required this.likeCount,
    required this.viewCount,
  });
}

class Comment {
  final String contents;
  final String userId;
  final String cdatetime;

  Comment({
    required this.contents,
    required this.userId,
    required this.cdatetime,
  });
}

class BoardModel extends ChangeNotifier {
  String _selectedCategory = '전체';
  bool _isLoading = true;
  List<Post> _posts = [];

  String get selectedCategory => _selectedCategory;

  bool get isLoading => _isLoading;

  List<Post> get posts => _posts;

  BoardModel() {
    _fetchPosts();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _fetchPosts();
    notifyListeners();
  }

  Future<void> _fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot;
      if (_selectedCategory == '전체') {
        snapshot =
            await FirebaseFirestore.instance.collection('Community').get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('Community')
            .where('category', isEqualTo: _selectedCategory)
            .get();
      }

      _posts = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp? timestamp = data['cdatetime'];
        DateTime dateTime =
            timestamp != null ? timestamp.toDate() : DateTime.now();
        return Post(
          id: doc.id,
          // 문서 ID를 Post 객체에 저장
          title: data['title'] ?? 'No Title',
          contents: data['contents'] ?? 'No Contents',
          userid: data['userId'] ?? 'Anonymous',
          cdatetime: dateTime,
          category: data['category'] ?? 'category',
          imgLink: data['imgLink'] ??
              'https://firebasestorage.googleapis.com/v0/b/teamproject-972bd.appspot.com/o/no_img.jpg?alt=media&token=aa730b3e-fffa-45ac-9f9f-8ab6055813bf',
          likeCount: data['likeCount'] ?? 0,
          viewCount: data['viewCount'] ?? 0, // 숫자로 저장
        );
      }).toList();
      print(_posts);
    } catch (e) {
      // 에러 처리
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Post> getPostsForCategory(String category) {
    return category == '전체'
        ? _posts
        : _posts.where((post) => post.category == category).toList();
  }
}

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: SizedBox(
            width: 95,
            child: Image.asset(
              "assets/mainlogo.png",
              width: 75,
              height: 75,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.grey),
              onPressed: () {
                // 설정 버튼 클릭 시 동작 추가
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.grey),
              onPressed: () {
                // 알림 버튼 클릭 시 동작 추가
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.grey),
              onPressed: () {
                // 내 정보 버튼 클릭 시 동작 추가
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            CategorySelector(),
            Expanded(
              child: PostList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostCreationScreen()),
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
        ),
        bottomNavigationBar: bottom.CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ));
  }
}

class CategorySelector extends StatelessWidget {
  final List<String> categories = [
    '전체',
    '자유',
    '운동',
    'MBTI',
    '오운완',
    '레시피',
    '당근마켓'
  ];

  @override
  Widget build(BuildContext context) {
    var boardModel = Provider.of<BoardModel>(context);

    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              boardModel.selectCategory(categories[index]);
            },
            child: CustomPaint(
              painter: BoxBorderPainter(
                showLeftBorder: true,
                showRightBorder: true,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: boardModel.selectedCategory == categories[index]
                        ? Colors.black
                        : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BoxBorderPainter extends CustomPainter {
  final bool showLeftBorder;
  final bool showRightBorder;

  BoxBorderPainter({
    this.showLeftBorder = false,
    this.showRightBorder = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    if (showLeftBorder) {
      canvas.drawLine(
          Offset(0, size.height * 0.2), Offset(0, size.height * 0.8), paint);
    }

    if (showRightBorder) {
      canvas.drawLine(Offset(size.width, size.height * 0.2),
          Offset(size.width, size.height * 0.8), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PostList extends StatelessWidget {
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    var boardModel = Provider.of<BoardModel>(context);

    if (boardModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    var posts = boardModel.getPostsForCategory(boardModel.selectedCategory);

    if (posts.isEmpty) {
      return Center(child: Text('작성된 게시글이 없습니다.'));
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post.imgLink),
                  ),
                  title: Text(
                    post.userid,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_formatDateTime(post.cdatetime)),
                  trailing: Icon(Icons.more_vert),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Image.network(post.imgLink),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(post.contents),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${post.likeCount}'),
                      SizedBox(width: 16),
                      Icon(Icons.remove_red_eye, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${post.viewCount}'),
                    ],
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final Post post;

  PostDetailScreen({required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    GlobalUser.fetchUserId().then((_) {
      _incrementViewCount();
      _fetchComments();
      _checkIfLiked();
    });
  }

  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _showComments = false;
  bool _isLiked = false;

  Future<void> _incrementViewCount() async {
    final postRef =
        FirebaseFirestore.instance.collection('Community').doc(widget.post.id);
    await postRef.update({
      'viewCount': FieldValue.increment(1),
    });
    setState(() {
      widget.post.viewCount += 1;
    });
  }

  Future<void> _fetchComments() async {
    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('Community')
        .doc(widget.post.id)
        .collection('comments')
        .get();

    setState(() {
      _comments = commentsSnapshot.docs.map((doc) {
        var data = doc.data();
        return Comment(
          contents: data['contents'],
          userId: data['userId'],
          cdatetime: data['cdatetime'],
        );
      }).toList();
    });
  }

  Future<void> _checkIfLiked() async {
    final likeDoc = await FirebaseFirestore.instance
        .collection('Community')
        .doc(widget.post.id)
        .collection('likes')
        .doc(GlobalUser.userId) // 전역 사용자 ID 사용
        .get();

    setState(() {
      _isLiked = likeDoc.exists;
    });
  }

  Future<void> _toggleLike() async {
    final postRef =
        FirebaseFirestore.instance.collection('Community').doc(widget.post.id);
    final likeRef =
        postRef.collection('likes').doc(GlobalUser.userId); // 전역 사용자 ID 사용

    if (_isLiked) {
      await likeRef.delete();
      await postRef.update({
        'likeCount': FieldValue.increment(-1),
      });
    } else {
      await likeRef.set({
        'userId': GlobalUser.userId, // 전역 사용자 ID 사용
      });
      await postRef.update({
        'likeCount': FieldValue.increment(1),
      });
    }

    setState(() {
      _isLiked = !_isLiked;
      widget.post.likeCount += _isLiked ? 1 : -1;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy.MM.dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final newComment = Comment(
      contents: _commentController.text,
      userId: GlobalUser.userId, // 전역 사용자 ID 사용
      cdatetime: DateTime.now().toString(),
    );

    await FirebaseFirestore.instance
        .collection('Community')
        .doc(widget.post.id)
        .collection('comments')
        .add({
      'contents': newComment.contents,
      'userId': newComment.userId,
      'cdatetime': newComment.cdatetime,
    });

    setState(() {
      _comments.add(newComment);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('게시글 상세보기'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.post.userid,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye,
                        color: CupertinoColors.inactiveGray),
                    SizedBox(width: 4),
                    Text(
                      '${widget.post.viewCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.favorite,
                        color: _isLiked
                            ? Colors.redAccent
                            : CupertinoColors.inactiveGray),
                    SizedBox(width: 4),
                    Text(
                      '${widget.post.likeCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    Text(
                      _formatDateTime(widget.post.cdatetime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 20),
                Image.network(widget.post.imgLink),
                SizedBox(height: 10),
                Text(
                  widget.post.contents,
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite,
                          color: _isLiked ? Colors.redAccent : Colors.grey),
                      onPressed: _toggleLike,
                    ),
                    SizedBox(width: 5),
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () {
                        setState(() {
                          _showComments = !_showComments;
                        });
                      },
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 10),
                if (_showComments) ...[
                  Text(
                    '댓글',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_comments[index].contents),
                        subtitle: Text(
                          '${_comments[index].userId} - ${_comments[index].cdatetime}',
                        ),
                      );
                    },
                  ),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: '댓글 작성',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _addComment,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
