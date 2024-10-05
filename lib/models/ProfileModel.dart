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

    final url = 'https://laporsemanu.my.id/api/pamong/';

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
  String? gender;
  String? bloodType;
  String? birthDate;
  String? maritalStatus;
  String? religion;

  // Update profile fields

  void updateGender(String? value) {
    gender = value;
    notifyListeners();
  }

  void updateBloodType(String? value) {
    bloodType = value;
    notifyListeners();
  }

  void updateBirthDate(String? value) {
    birthDate = value;
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
}
