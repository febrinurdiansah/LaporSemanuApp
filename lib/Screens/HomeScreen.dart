import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:provider/provider.dart';

import '../models/ProfileModel.dart';
import '../models/UserData.dart';
import 'AllActivitiesScreen.dart';
import 'CalendarScreen.dart';
import 'LoginScreen.dart';

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
  List<dynamic> activities = [];

  LinkedHashMap<DateTime, List<Event>> kEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void initState(){
    super.initState();
    _fetchUserProfile();
    _fetchActivities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FocusScope.of(context).unfocus();
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

    final urlUsers = 'https://laporsemanu.my.id/api/pamong/'; 
    final urlEvent = 'https://laporsemanu.my.id/api/agenda/';

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

  // Fetch activities (limited to 5)
Future<void> _fetchActivities() async {
  final token = await _getToken();
  if (token == null) {
    // Handle no token case
    return;
  }

  final urlActivities = 'https://laporsemanu.my.id/api/kegiatan/';

  try {
    final response = await http.get(
      Uri.parse(urlActivities),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> activityData = jsonDecode(response.body);

      // Limit to first 5 activities
      setState(() {
        activities = activityData.take(5).toList();
      });
    } else {
      throw Exception('Failed to load activities');
    }
  } catch (e) {
    print('Error fetching activities: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileModel>(
      builder: (context, profileModel, child) {
        if (profileModel.userProfile == null) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: Colors.blue, 
              size: 30
              ));
            }
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.blue,
          appBar: AppBar(
            title: Text('Kelurahan Semanu',
              style: TextStyle(
                fontWeight: FontWeight.w500
              ),
              ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue,
        ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Colors.blue,
                  automaticallyImplyLeading: false,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: _buildGreetingSection(profileModel),
                  ),
                ),
              ];
            },
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20)
                      ),
                    child: Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.background,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(_dateTimeNow, style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                    )
                                  ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_sharp),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CalendarScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            // Event section
                            todayEvents.isNotEmpty
                                ? _buildEventSection()
                                : Center(child: Text("Tidak ada event untuk hari ini", style: TextStyle(fontSize: 16))),
                            const SizedBox(height: 20),
                            // Activities section
                            _buildActivityList(),
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
    },
  );
}

  Widget _buildGreetingSection(dynamic profileModel) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$getTime, ${profileModel.userProfile?.name ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    ),
                const SizedBox(height: 8.0),
                Text(getQuots, 
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 17,
                    )
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                  decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                        radius: 70,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSection() {
    return todayEvents.length > 1
        ? SizedBox(
            height: 150,
            child: Swiper(
              itemCount: todayEvents.length,
              itemBuilder: (context, index) {
                final event = todayEvents[index];
                return _buildEventCard(event);
              },
              pagination: SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  color: Colors.lightBlue[200],
                  activeColor: Colors.blue,
                  size: 8,
                  activeSize: 8
                )
              ),
              scale: 0.9,
              scrollDirection: Axis.horizontal,
              loop: false,
            ),
          )
        : _buildEventCard(todayEvents[0]);
  }

  //Fungsi Agenda
  Widget _buildEventCard(Event event) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          width: 1,
          color: Theme.of(context).dividerColor,
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
              Text(event.formattedStartTime, 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                  )
                ),
              Icon(Icons.keyboard_double_arrow_right, 
                size: 32, 
                color: Colors.blue
                ),
              Text(event.formattedEndTime, 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                  )
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi Kegiatan
  Widget _buildActivityList() {
    if (activities.isEmpty) {
      return Center(child: Text('Tidak ada kegiatan'));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kegiatan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllActivitiesScreen(activities: activities),
                  ),
                );
              },
              child: Text('Lihat Semua', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            print('Total activities: ${activities.length}');
            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        activity['nama_kegiatan'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (activity['gambar'] != null && activity['gambar']!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                activity['gambar']!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'lib/assets/img/no-image.jpg',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            )
                          else
                            Image.asset(
                              'lib/assets/img/no-image.jpg',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          const SizedBox(height: 10),
                          Text('Tempat: ${activity['tempat']}'),
                          const SizedBox(height: 8),
                          Text('Deskripsi: ${activity['deskripsi'] ?? 'Tidak ada deskripsi'}'),
                          const SizedBox(height: 8),
                          Text('Tanggal: ${activity['tanggal']}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Tutup'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        (activity['gambar'] != null && activity['gambar']!.isNotEmpty)
                            ? activity['gambar']!
                            : 'lib/assets/img/no-image.jpg',
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'lib/assets/img/no-image.jpg',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(activity['nama_kegiatan'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(activity['tempat'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

