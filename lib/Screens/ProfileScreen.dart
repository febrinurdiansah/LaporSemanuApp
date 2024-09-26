import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../models/ProfileModel.dart';
import '../widgets/theme_notifier.dart';
import 'EditProfileScreen.dart';

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
    
    return Consumer<ProfileModel>(
      builder: (context, profileModel, child) {
        return Scaffold(
          backgroundColor: Colors.blue,
          body: profileModel.isLoading
              ? Center(
                  child: LoadingAnimationWidget.threeRotatingDots(
                      color: Colors.blue, size: 30))
              : CustomScrollView(
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
                                CircleAvatar(
                                  radius: 50,
                                  child: ClipOval(
                                    child: Image.network(
                                      profileModel.userProfile?.image ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'lib/assets/img/no-profil.jpg',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  profileModel.userProfile?.name ?? 'N/A',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  profileModel.userProfile?.position ?? 'N/A',
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
                                                    userProfile: profileModel
                                                        .userProfile!),
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
                                        profileModel.userProfile?.nip ?? 'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.perm_identity,
                                    title: 'NIK',
                                    actionText:
                                        profileModel.userProfile?.nik ?? 'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.person,
                                    title: 'Pekerjaan',
                                    actionText:
                                        profileModel.userProfile?.job ??
                                            'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.person,
                                    title: 'Jenis Kelamin',
                                    actionText: _getGenderText(profileModel.userProfile?.gender),
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.bloodtype,
                                    title: 'Golongan Darah',
                                    actionText:
                                        profileModel.userProfile?.bloodType ??
                                            'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.local_hospital,
                                    title: 'Tanggal Lahir',
                                    actionText:
                                        profileModel.userProfile?.birthPlace ??
                                            'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.date_range,
                                    title: 'Tempat Lahir',
                                    actionText:
                                        profileModel.userProfile?.birthDate ??
                                            'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.place,
                                    title: 'Alamat',
                                    actionText:
                                        profileModel.userProfile?.address ??
                                            'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.school,
                                    title: 'Pendidikan Terakhir',
                                    actionText:
                                        profileModel.userProfile?.lastEducation ??
                                            'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.safety_check,
                                    title: 'Status Pernikahan',
                                    actionText: profileModel
                                            .userProfile?.maritalStatus ??
                                        'N/A',
                                  ),
                                  _buildSettingItem(
                                    context,
                                    icon: Icons.work_history_outlined,
                                    title: 'Masa Jabatan',
                                    actionText:
                                        '${profileModel.userProfile?.termStart ?? 'N/A'} - ${profileModel.userProfile?.termEnd ?? 'N/A'}',
                                  ),
                                  const SizedBox(height: 12),
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
                                  await profileModel.logout(context);
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
