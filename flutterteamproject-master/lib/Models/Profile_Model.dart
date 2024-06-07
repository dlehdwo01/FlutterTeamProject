import 'dart:io';
import 'package:flutter/foundation.dart';

class ProfileModel with ChangeNotifier {
  String _phoneNumber = '';
  String _email = '';
  String _password = '';
  String? name;
  String? dateOfBirth;
  String? gender;
  String? residence;
  String? introduce;
  List<File> selectedImages = [];
  String? height;
  String? bodyType;
  String? pay;

  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String get password => _password;

  void updatePhoneNumber(String newNumber) {
    _phoneNumber = newNumber;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  void updatePassword(String newPassword) {
    _password = newPassword;
    notifyListeners();
  }

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }

  void updateDateOfBirth(String newDateOfBirth) {
    dateOfBirth = newDateOfBirth;
    notifyListeners();
  }

  void updateGender(String newGender) {
    gender = newGender;
    notifyListeners();
  }

  void updateSelectedImages(List<File> newSelectedImages) {
    selectedImages = newSelectedImages;
    notifyListeners();
  }

  void updateSelectedResidence(String newResidence) {
    residence = newResidence;
    notifyListeners();
  }

  void updateSelectedIntroduce(String newIntroduce) {
    introduce = newIntroduce;
    notifyListeners();
  }

  void updateHeight(String newHeight) {
    height = newHeight;
    notifyListeners();
  }

  void updateBodyType(String newBodyType) {
    bodyType = newBodyType;
    notifyListeners();
  }

  void updatePay(String newPay) {
    pay = newPay;
    notifyListeners();
  }

  void reset() {
    name = null;
    dateOfBirth = null;
    gender = null;
    selectedImages = [];
    notifyListeners();
  }



}
