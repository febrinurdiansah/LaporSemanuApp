import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monkir/Screens/RegisterScreen.dart';
import 'package:provider/provider.dart';
import 'package:monkir/Screens/HomeScreen.dart';
import 'package:monkir/Screens/LoginScreen.dart';
import 'package:monkir/Screens/ProfileScreen.dart';
import 'package:monkir/Screens/WorkScreen.dart';
import 'package:monkir/widgets/theme_notifier.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:device_preview_plus/device_preview_plus.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) =>  ChangeNotifierProvider(
        create: (context) => ThemeNotifier(),
        child: MyApp())
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    //fungsi login
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _isLoggedIn ? MainScreen() : RegisterScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
   int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    WorkScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              /// Home
              SalomonBottomBarItem(
                icon: Icon(Icons.home),
                title: Text("Home"),
                selectedColor: Colors.purple,
              ),
              /// Likes
              SalomonBottomBarItem(
                icon: Icon(Icons.work),
                title: Text("Work"),
                selectedColor: Colors.brown,
              ),
              /// Profile
              SalomonBottomBarItem(
                icon: Icon(Icons.person),
                title: Text("Profile"),
                selectedColor: Colors.teal,
              ),
            ],
          ),
        ),
      );
  }
}


