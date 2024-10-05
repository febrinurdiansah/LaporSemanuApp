import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UserData.dart';
import '../widgets/theme_notifier.dart';
import 'EditProfileScreen.dart';
import 'LoginScreen.dart';
import 'ResetPass.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _appVersion = '';
  String? username;
  bool isLoading = true;
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchAppVersion();
    _fetchUserProfile();
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Fetch username from API
  Future<void> _fetchUsername() async {
    final token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = 'https://laporsemanu.my.id/api/users/me';

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
          username = data['username'];
          isLoading = false;
        });
      } else {
        print('Failed to load username');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  // Fetch user profile data from API
  Future<void> _fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    final token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
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
        setState(() {
          userProfile = UserProfile.fromJson(data);
          isLoading = false;
        });
      } else {
        print('Failed to load user profile');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Get app version
  Future<void> _fetchAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  String _getGenderText(String? gender) {
    if (gender == 'L') {
      return 'Laki-Laki';
    } else if (gender == 'P') {
      return 'Perempuan';
    } else {
      return 'N/A';
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    
    return Scaffold(
          backgroundColor: Colors.blue,
          body: isLoading
              ? Center(
                  child: LoadingAnimationWidget.threeRotatingDots(
                      color: Colors.blue, size: 30))
              : RefreshIndicator(
                onRefresh: _fetchUserProfile,
                child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 200.0,
                        pinned: false,
                        backgroundColor: Colors.blue,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                        userProfile!.image,
                                      ),
                                      child: userProfile!.image.isNotEmpty
                                          ? null 
                                          : Image.asset(
                                              'lib/assets/img/no-profil.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    userProfile?.name ?? 'N/A',
                                    style: TextStyle(fontSize: 20, color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    userProfile?.position ?? 'N/A',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Data Pribadi',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                        ),
                                        IconButton(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfileScreen(
                                                      userProfile: userProfile!
                                                          ),
                                            ),
                                          ),
                                          icon: Icon(Icons.edit),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.badge,
                                      title: 'NIP',
                                      actionText:
                                          userProfile?.nip ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.perm_identity,
                                      title: 'NIK',
                                      actionText:
                                          userProfile?.nik ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.person,
                                      title: 'Pekerjaan',
                                      actionText:
                                          userProfile?.job ??
                                              'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.person,
                                      title: 'Jenis Kelamin',
                                      actionText: _getGenderText(userProfile?.gender),
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.info,
                                      title: 'Agama',
                                      actionText: userProfile?.religion,
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.bloodtype,
                                      title: 'Golongan Darah',
                                      actionText:
                                          userProfile?.bloodType ??
                                              'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.local_hospital,
                                      title: 'Tempat Lahir',
                                      actionText:
                                          userProfile?.birthPlace ??
                                              'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.date_range,
                                      title: 'Tanggal Lahir',
                                      actionText:
                                          userProfile?.birthDate ??
                                              'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.place,
                                      title: 'Alamat',
                                      actionText:
                                          userProfile?.address ??
                                              'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.school,
                                      title: 'Pendidikan Terakhir',
                                      actionText:
                                          userProfile?.lastEducation ??
                                              'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.safety_check,
                                      title: 'Status Pernikahan',
                                      actionText: userProfile?.maritalStatus ??
                                          'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.work_history_outlined,
                                      title: 'Masa Jabatan',
                                      actionText:
                                          '${userProfile?.termStart ?? 'N/A'} - ${userProfile?.termEnd ?? 'N/A'}',
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      'Akun',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.account_circle,
                                      title: 'Username',
                                      actionText: username ??
                                          'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.password,
                                      title: 'Password',
                                      actionWidget: InkWell(
                                        onTap: () => Navigator.push(context, MaterialPageRoute      (builder: (context) => ResetPassScreen()
                                          )
                                        ),
                                        child: Text(
                                              'Ganti Kata Sandi',
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                    color: Colors.blue,
                                                  ),
                                            ),
                                      )
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      'Pengaturan',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.security_update,
                                      title: 'Versi Aplikasi',
                                      actionText: _appVersion,
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.dark_mode,
                                      title: 'Mode Gelap',
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
                                InkWell(
                                  onTap: () async {
                                    await logout(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      color: Colors.red,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Keluar Akun",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('lib/assets/img/logo.png',
                                          fit: BoxFit.cover,
                                          height: 60,
                                          filterQuality: FilterQuality.low,
                                          ),
                                        const SizedBox(width: 20),
                                        Image.asset('lib/assets/img/logo-gk.png',
                                          fit: BoxFit.cover,
                                          height: 60,
                                          filterQuality: FilterQuality.low,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${DateTime.now().year} - Team Pengabdian Informatika F UTY 21',
                                      style: TextStyle(fontSize: 14),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                actionText,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
