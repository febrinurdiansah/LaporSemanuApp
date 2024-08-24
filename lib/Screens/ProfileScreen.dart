import 'package:flutter/material.dart';
import 'package:monkir/Screens/LoginScreen.dart';
import 'package:monkir/widgets/theme_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

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

  //Get versi aplikasi
  Future<void> _fetchAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.green,
        body: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'John Titor',
                  style: TextStyle(
                    fontSize: 18
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kepala Desa',
                  style: TextStyle(
                    fontSize: 16
                  ),
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
                              Text(
                                'Data Pribadi',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 12),
                              _buildSettingItem(
                                context,
                                icon: Icons.edit,
                                title: 'Jenis Kelamin',
                                actionText: 'Pria',
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.bloodtype,
                                title: 'golongan darah',
                                actionText: 'J',
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.local_hospital,
                                title: 'tempat tanggal lahir',
                                actionText: 'isekai, '+'6969-08-24',
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.place,
                                title: 'alamat',
                                actionText: 'gak tahu',
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.school,
                                title: 'pendidikan_terakhir',
                                actionText: 'TK',
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.safety_check,
                                title: 'status_kawin',
                                actionText: 'Belum Kawin',
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.work_history_outlined,
                                title: 'masa_jabatan',
                                actionText: '7869 - '+'9990',
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
                                title: 'Versi Aplikasi',
                                actionText: '{_appVersion}',/// aaaaaaaaaaaaaaaaaaa
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.dark_mode,
                                title: 'Mode Hitam',
                                actionWidget: Switch(
                                  value: themeNotifier.isDarkMode, 
                                  onChanged: (value) {
                                    themeNotifier.toggleDarkMode();
                                  },),
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
                            child: Text('Keluar Akun')
                            )
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

  //List Setting
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (actionWidget != null)
            actionWidget
          else
            Text(
            actionText ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
