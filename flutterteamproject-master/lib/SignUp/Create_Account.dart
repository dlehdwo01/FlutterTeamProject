import 'package:flutter/material.dart';
import 'package:flutterteamproject/CustomWidget/CustomButtonColor.dart';
import 'package:flutterteamproject/CustomWidget/prevPageButton.dart';
import 'package:flutterteamproject/SignUp/Notification.dart';
import 'package:flutterteamproject/SignUp/Profile_BasicInfo.dart';
import 'package:flutterteamproject/Models/Profile_Model.dart';
import 'package:flutterteamproject/SignUp/Profile_Interests.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyWidget());
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _emailController;
  late final TextEditingController _pwdController;
  late final TextEditingController _pwdConfirmController;

  bool isEmail(String input) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(input);
  }

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileModel>(context, listen: false);
    _emailController = TextEditingController();
    _pwdController = TextEditingController();
    _pwdConfirmController = TextEditingController();

    // _emailController.addListener(_updateTextFieldIcon);
    // _pwdController.addListener(_updateTextFieldIcon);
    // _pwdConfirmController.addListener(_updateTextFieldIcon);
  }

  void _updateTextFieldIcon() {
    setState(() {

    });
  }
  @override
  // void dispose() {
  //   _emailController.dispose();
  //   _pwdController.dispose();
  //   _pwdConfirmController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Noti()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 90),
                CustomTextField(_emailController, '아이디(이메일)', isEmailField: true),
                Text(
                  '전화번호',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: TextEditingController(text: Provider.of<ProfileModel>(context).phoneNumber),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  enabled: false,
                ),
                SizedBox(height: 30),
                CustomTextField(_pwdController, '비밀번호', isPasswordField: true),
                CustomTextField(_pwdConfirmController, '비밀번호 확인', isPasswordField: true),
                SizedBox(height: 80),
                Container(
                  alignment: Alignment.center,
                  child: CustomColorButton(
                    buttonText: '다음',
                    onPressed: _validateAndProceed,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget CustomTextField(TextEditingController controller, String label, {bool isEmailField = false, bool isPasswordField = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label를 입력해주세요',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          obscureText: isPasswordField,
          decoration: InputDecoration(
            hintText: '최소 6자 이상 입력해주세요',
            labelStyle: TextStyle(color: Colors.black),
            suffixIcon: controller.text.isNotEmpty
                ? (isEmailField && !isEmail(controller.text))
                ? Icon(Icons.error, color: Colors.red)
                : Icon(Icons.check, color: Colors.green)
                : null,
          ),
        ),
        if (isEmailField && !isEmail(controller.text) && controller.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text('유효한 이메일 주소를 입력해주세요.', style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
        SizedBox(height: 30),
      ],
    );
  }

  void _validateAndProceed() async{
    if (_emailController.text.length < 6 || _pwdController.text.length < 6 || _pwdConfirmController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('아이디 혹은 비밀번호가 짧습니다. 최소 6자 이상 입력해주세요.'))
      );
      return;
    }
    if (!isEmail(_emailController.text)) {
      // 이메일 형식이 유효하지 않을 경우
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('유효한 이메일 주소를 입력해주세요.'))
      );
      return;
    }
    if (_pwdController.text != _pwdConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 일치하지 않습니다.'))
      );
      return;
    }
    // Firestore에서 이메일 중복 체크
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('USER')
        .where('EMAIL', isEqualTo: _emailController.text)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      // 중복된 이메일이 있을 경우
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 회원가입된 이메일입니다.'))
      );
      return;
    }

    Provider.of<ProfileModel>(context, listen: false).updateEmail(_emailController.text);
    Provider.of<ProfileModel>(context, listen: false).updatePassword(_pwdController.text);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpProfile()),
    );
  }
}
