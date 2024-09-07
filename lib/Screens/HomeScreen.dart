import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monkir/Screens/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../models/UserData.dart';
import 'CalendarScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState(){
    super.initState();
    _fetchUserProfile();
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
      print('No token found');
      setState(() {
        _isLoading = false;
      });
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
    // FocusScope.of(context).unfocus();
    TextStyle _style = TextStyle(
      fontSize: 16
    );
    String name = _userProfile?.name ?? 'N/A';
    String getTime = '';
    String getQuots = '';
    int hours = DateTime.now().hour;
    if(hours>=0 && hours<=11){
      getTime= 'Selamat Pagi';
      getQuots= 'Have a wonderful day!';
    } else if(hours<=15){
      getTime= 'Selamat Siang';
      getQuots= 'I hope your having a great day!';
    } else if (hours<=20){
      getTime= 'Selamat Sore';
      getQuots= 'ss';
    } else if(hours<=24){
      getTime= 'Selamat Malam';
      getQuots= 'Mimpi Indah';
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Kelurahan Semanu'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer(
                                child: Text('$getTime, $name',
                                  style: _style,),
                              ),
                              const SizedBox(height: 8.0),
                              Text(getQuots,
                                style: _style),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2, 
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => LoginScreen()
                                  ));
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                  _userProfile?.image ?? 'https://via.placeholder.com/150',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Text('Senin, 1 Agustus', style: TextStyle(fontSize: 25)),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_sharp),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => CalendarScreen()
                              ));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border: Border.all(
                      width: 1,
                      color: Colors.black
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kegiatan Sosialisasi', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 5),
                        Text('Tempat Di Desa Maju Mundur', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('12.00', style: TextStyle(fontSize: 20)),
                              Icon(Icons.keyboard_double_arrow_right, size: 32, color: Colors.blue),
                              Text('12.00', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
