import 'package:flutter/material.dart';
import 'package:monkir/Screens/EditProfileScreen.dart';
import 'package:monkir/Screens/LoginScreen.dart';
import 'package:monkir/widgets/theme_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../models/ProfileModel.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
  }

  // Get app version
  Future<void> _fetchAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileModel = Provider.of<ProfileModel>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final profileNotifier = Provider.of<ProfileNotifier>(context);

    return Consumer<ProfileModel>(
      builder: (context, profileModel, child) {
        return Scaffold(
        backgroundColor: Colors.green,
        body: profileModel.isLoading
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
                          profileModel.userProfile?.image ?? 'https://via.placeholder.com/150',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profileModel.userProfile?.name ?? 'N/A',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profileModel.userProfile?.position ?? 'Position',
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
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditProfileScreen(userProfile: profileModel.userProfile!),
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
                                      actionText: profileModel.userProfile?.nip ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.perm_identity,
                                      title: 'NIK',
                                      actionText: profileModel.userProfile?.nik ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.person,
                                      title: 'Gender',
                                      actionText: profileModel.userProfile?.gender ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.bloodtype,
                                      title: 'Blood Type',
                                      actionText: profileModel.userProfile?.bloodType ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.local_hospital,
                                      title: 'Date of Birth',
                                      actionText: profileModel.userProfile?.birthPlace ?? 'N/A'
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.date_range,
                                      title: 'Birth Place',
                                      actionText:  profileModel.userProfile?.birthDate ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.place,
                                      title: 'Address',
                                      actionText: profileModel.userProfile?.address ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.school,
                                      title: 'Last Education',
                                      actionText: profileModel.userProfile?.lastEducation ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.safety_check,
                                      title: 'Marital Status',
                                      actionText: profileModel.userProfile?.maritalStatus ?? 'N/A',
                                    ),
                                    _buildSettingItem(
                                      context,
                                      icon: Icons.work_history_outlined,
                                      title: 'Term Duration',
                                      actionText: '${profileModel.userProfile?.termStart ?? 'N/A'} - ${profileModel.userProfile?.termEnd ?? 'N/A'}',
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
                                InkWell(
                                  onTap: () => Navigator.push(context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                    ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      color: Colors.red,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Logout",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
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
        );
      },
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

