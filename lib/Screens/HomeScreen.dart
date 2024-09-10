import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monkir/Screens/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:card_swiper/card_swiper.dart';

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
  String _dateTimeNow = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
  List<Event> todayEvents = [];

  LinkedHashMap<DateTime, List<Event>> kEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

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

  // Fetch user profile data and agenda for today
  Future<void> _fetchUserProfile() async {
    final token = await _getToken();
    if (token == null) {
      print('No token found');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No token found'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    final urlUsers = 'https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/pamong/'; 
    final urlEvent = 'https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/agenda/';

    try {
      // Fetch user profile
      final userResponse = await http.get(
        Uri.parse(urlUsers),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (userResponse.statusCode == 200) {
        final data = jsonDecode(userResponse.body);
        setState(() {
          _userProfile = UserProfile.fromJson(data);
        });
      } else {
        print('Failed to load user profile');
      }

      // Fetch agenda
      final eventResponse = await http.get(
        Uri.parse(urlEvent),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (eventResponse.statusCode == 200) {
        List<dynamic> agendaData = jsonDecode(eventResponse.body);

        // Filtering events for today
        final today = DateTime.now();
        for (var agenda in agendaData) {
          DateTime startDate = DateTime.parse(agenda['tanggal_mulai']).toLocal();
          DateTime endDate = DateTime.parse(agenda['tanggal_selesai']).toLocal();
          String eventTitle = agenda['nama_agenda'];
          String eventDesc = agenda['deskripsi'];
          String eventPlace = agenda['tempat'];
          Color eventColor = getRandomColor();

          String formattedStartTime = DateFormat('HH:mm').format(startDate);
          String formattedEndTime = DateFormat('HH:mm').format(endDate);

          // Check if today's date falls within the event's start and end date (inclusive)
          if (today.isAfter(startDate) && today.isBefore(endDate.add(Duration(days: 1))) || isSameDay(today, startDate)) {
            todayEvents.add(Event(eventTitle, eventColor, eventDesc, eventPlace, formattedStartTime, formattedEndTime));
            print('Added event: ${Event(eventTitle, eventColor, eventDesc, eventPlace, formattedStartTime, formattedEndTime)}');
          }
        }
      } else {
        throw Exception('Failed to load agenda');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Kelurahan Semanu'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: LoadingAnimationWidget.threeRotatingDots(
                color: Colors.blue, 
                size: 20
                ))
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    children: [
                      // Greeting and profile section
                      _buildGreetingSection(),
                      const SizedBox(height: 16.0),
                      
                      // Event section
                      Row(
                        children: [
                          Text(_dateTimeNow, style: TextStyle(fontSize: 20)),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_sharp),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CalendarScreen()));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      todayEvents.isNotEmpty
                          ? todayEvents.length > 1
                              ? SizedBox(
                                  height: 150,
                                  child: Swiper(
                                    itemCount: todayEvents.length,
                                    itemBuilder: (context, index) {
                                      final event = todayEvents[index];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.black,
                                        ),
                                      ),
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(event.title, style: TextStyle(fontSize: 18)),
                                          const SizedBox(height: 5),
                                          Text(event.place, style: TextStyle(fontSize: 16)),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(event.formattedStartTime, style: TextStyle(fontSize: 20)),
                                              Icon(Icons.keyboard_double_arrow_right, size: 32, color: Colors.blue),
                                              Text(event.formattedEndTime, style: TextStyle(fontSize: 20)),
                                            ],
                                          ),
                                        ],
                                        ),
                                      );
                                    },
                                    pagination: SwiperPagination(),
                                    scale: 0.9,
                                    scrollDirection: Axis.horizontal,
                                    loop: false,
                                  ),
                                )
                              : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.black,
                                        ),
                                      ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(todayEvents[0].title, style: TextStyle(fontSize: 18)),
                                    const SizedBox(height: 5),
                                    Text(todayEvents[0].place, style: TextStyle(fontSize: 16)),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(todayEvents[0].formattedStartTime, style: TextStyle(fontSize: 20)),
                                        Icon(Icons.keyboard_double_arrow_right, size: 32, color: Colors.blue),
                                        Text(todayEvents[0].formattedEndTime, style: TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                          : Center(child: Text("Tidak ada event untuk hari ini", style: TextStyle(fontSize: 16))),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    String getTime = '';
    String getQuots = '';
    int hours = DateTime.now().hour;
    if (hours >= 0 && hours <= 11) {
      getTime = 'Selamat Pagi';
      getQuots = 'Mulai hari dengan semangat baru!';
    } else if (hours <= 15) {
      getTime = 'Selamat Siang';
      getQuots = 'Tetap produktif dan terus maju!';
    } else if (hours <= 20) {
      getTime = 'Selamat Sore';
      getQuots = 'Terus semangat sampai akhir hari!';
    } else if (hours <= 24) {
      getTime = 'Selamat Malam';
      getQuots = 'Istirahat yang cukup, semoga besok lebih baik!';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer(
                child: Text('$getTime, ${_userProfile?.name ?? 'N/A'}',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 8.0),
              Text(getQuots, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
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
    );
  }
}

