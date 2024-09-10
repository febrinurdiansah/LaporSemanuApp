import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/UserData.dart';

class ProfileModel extends ChangeNotifier {
  UserProfile? userProfile;
  bool isLoading = true;

  ProfileModel() {
    fetchUserProfile();
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Fetch user profile data
  Future<void> fetchUserProfile() async {
    isLoading = true;
    notifyListeners();

    final token = await _getToken();
    if (token == null) {
      // Handle no token case
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = 'https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/pamong/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userProfile = UserProfile.fromJson(data);
      } else {
        print('Failed to load user profile');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}



class ProfileNotifier extends ChangeNotifier {
  // Define fields for profile data
  String name = '';
  String? gender;
  String? bloodType;
  String birthPlace = '';
  String? birthDate;
  String nik = '';
  String job = '';
  String position = '';
  String lastEducation = '';
  String? maritalStatus;
  String? religion;
  String address = '';
  String nip = '';
  int termStart = 0;
  int termEnd = 0;

  // Update profile fields
  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateGender(String? value) {
    gender = value;
    notifyListeners();
  }

  void updateBloodType(String? value) {
    bloodType = value;
    notifyListeners();
  }

  void updateBirthPlace(String value) {
    birthPlace = value;
    notifyListeners();
  }

  void updateBirthDate(String? value) {
    birthDate = value;
    notifyListeners();
  }

  void updateNik(String value) {
    nik = value;
    notifyListeners();
  }

  void updateJob(String value) {
    job = value;
    notifyListeners();
  }

  void updatePosition(String value) {
    position = value;
    notifyListeners();
  }

  void updateLastEducation(String value) {
    lastEducation = value;
    notifyListeners();
  }

  void updateMaritalStatus(String? value) {
    maritalStatus = value;
    notifyListeners();
  }

  void updateReligion(String? value) {
    religion = value;
    notifyListeners();
  }

  void updateAddress(String value) {
    address = value;
    notifyListeners();
  }

  void updateNip(String value) {
    nip = value;
    notifyListeners();
  }

  void updateTermStart(int value) {
    termStart = value;
    notifyListeners();
  }

  void updateTermEnd(int value) {
    termEnd = value;
    notifyListeners();
  }
}
