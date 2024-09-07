import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monkir/Screens/EditProfileScreen.dart';
import 'package:monkir/Screens/LoginScreen.dart';
import 'package:monkir/widgets/theme_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/UserData.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _appVersion = '';
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
    _fetchUserProfile();
  }

  // Get app version
  Future<void> _fetchAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Token diambil dari SharedPreferences: $token');
    return token;
  }

  // Fetch user profile data
  Future<void> _fetchUserProfile() async {
    final token = await _getToken();
    if (token == null) {
      // Handle case where token is not found
      print('No token found');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = 'https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/pamong/'; // Replace with your API URL

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userProfile = UserProfile.fromJson(data);
          _isLoading = false;
        });
      } else {
        print('Failed to load user profile');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.green,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          _userProfile?.image ?? 'https://via.placeholder.com/150',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userProfile?.name ?? 'N/A',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _userProfile?.position ?? 'Position',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 3,
                                color: Color(0x33000000),
                                offset: Offset(0, -1),
                              ),
                            ],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Personal Data',
                                          style: Theme.of(context).textTheme.headlineSmall,
                                        ),
                                        IconButton(
                                          onPressed: () => Navigator.push( context, MaterialPageRoute(
                                            builder: (context) => EditProfileScreen(userProfile: _userProfile!,),
                                            )), 
                                          icon: Icon(Icons.edit)
                                          )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.badge,
                                      title: 'NIP',
                                      actionText: _userProfile?.nip ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.perm_identity,
                                      title: 'NIK',
                                      actionText: _userProfile?.nik ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.person,
                                      title: 'Gender',
                                      actionText: _userProfile?.gender ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.bloodtype,
                                      title: 'Blood Type',
                                      actionText: _userProfile?.bloodType ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.local_hospital,
                                      title: 'Birth Place',
                                      actionText: '${_userProfile?.birthPlace ?? 'N/A'}, ${_userProfile?.birthDate ?? 'N/A'}',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.place,
                                      title: 'Address',
                                      actionText: _userProfile?.address ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.school,
                                      title: 'Last Education',
                                      actionText: _userProfile?.lastEducation ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.safety_check,
                                      title: 'Marital Status',
                                      actionText: _userProfile?.maritalStatus ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.work_history_outlined,
                                      title: 'Term Duration',
                                      actionText: '${_userProfile?.termStart ?? 'N/A'} - ${_userProfile?.termEnd ?? 'N/A'}',
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Settings',
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.security_update,
                                      title: 'App Version',
                                      actionText: _appVersion,
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.dark_mode,
                                      title: 'Dark Mode',
                                      actionWidget: Switch(
                                        value: themeNotifier.isDarkMode, 
                                        onChanged: (value) {
                                          themeNotifier.toggleDarkMode();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, 
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                                  }, 
                                  child: Text('Logout'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // List Setting
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? actionText,
    Widget? actionWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (actionWidget != null) actionWidget,
          if (actionText != null)
            Text(
              actionText,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.grey,
                  ),
            ),
        ],
      ),
    );
  }
}
