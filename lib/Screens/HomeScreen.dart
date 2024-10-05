import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:card_swiper/card_swiper.dart';

import '../models/UserData.dart';
import 'AllActivitiesScreen.dart';
import 'CalendarScreen.dart';
import 'DetailScreen.dart';
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
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchActivities();
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    // print('Token diambil dari SharedPreferences: $token');
    return token;
  }

  // Fetch user profile data and agenda for today
  Future<void> _fetchUserProfile() async {
    final token = await _getToken();
    if (token == null) {
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
          _isLoading = false;
        });
      } else {
        print('Failed to load user profile');
      }
      setState(() {
        _isLoading = false;
      });

      todayEvents.clear();

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
    }
  }

  Future<void> _fetchActivities() async {
  final token = await _getToken();
  final urlActivities = 'https://laporsemanu.my.id/api/kegiatan/';
  final urlUser = 'https://laporsemanu.my.id/api/users/me';

  try {
    // Fetch user data to get the current user ID
    final userResponse = await http.get(
      Uri.parse(urlUser),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (userResponse.statusCode == 200) {
      final userData = jsonDecode(userResponse.body);
      final currentUserId = userData['id'];

      // Fetch activities data
      final activitiesResponse = await http.get(
        Uri.parse(urlActivities),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (activitiesResponse.statusCode == 200) {
        List<dynamic> activityData = jsonDecode(activitiesResponse.body);

        // Filter activities based on the current user ID
        List<dynamic> userActivities = activityData
            .where((activity) => activity['user_id'] == currentUserId)
            .toList();

        // Sort activities by ID
        userActivities.sort((a, b) => b['id'].compareTo(a['id']));

        setState(() {
          activities = userActivities;
        });
      } else {
        throw Exception('Failed to load activities');
      }
    } else {
      throw Exception('Failed to load user data');
    }
  } catch (e) {
    print('Error fetching activities: $e');
  }
}


  @override
  Widget build(BuildContext context) {
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
                background: _buildGreetingSection(),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchUserProfile();
            await _fetchActivities();
          },
          child: _isLoading
              ? Center(
                  child: LoadingAnimationWidget.threeRotatingDots(
                    color: Colors.blue,
                    size: 30,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _dateTimeNow,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                  todayEvents.isNotEmpty
                                      ? _buildEventSection()
                                      : Center(
                                          child: Text(
                                            "Tidak ada agenda untuk hari ini",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Kegiatan',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
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
                                  ActivityList(
                                    context: context,
                                    activities: activities,
                                    limit: 5,
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
      ),
      );
}

  Widget _buildGreetingSection() {
    if (_userProfile == null) {
    return Center(
          child: LoadingAnimationWidget.threeRotatingDots(
            color: Colors.blue,
            size: 30,
          ),
        );
  }

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
                Text('$getTime, ${_userProfile?.name ?? 'N/A'}',
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
          SizedBox(width: 2,),
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
                  backgroundImage: NetworkImage(
                    _userProfile!.image,
                  ),
                  child: _userProfile!.image.isNotEmpty
                      ? null 
                      : Image.asset(
                          'lib/assets/img/no-profil.jpg',
                          fit: BoxFit.cover,
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

  // Fungsi Agenda
  Widget _buildEventCard(Event event) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.black12, Colors.black26] // Dark mode colors
              : [Colors.white, Colors.grey[100]!], // Light mode colors
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.4), //Dark/Light on Left Top
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(4, 4),
          ),
          BoxShadow(
            color: isDarkMode ? Colors.grey[700]!.withOpacity(0.1) : Colors.white.withOpacity(0.8), //Dark/Light on Right Bottom
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(-4, -4),
          ),
        ],
        border: Border.all(
          width: 0.8,
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 5),
          Text(
            event.place,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                event.formattedStartTime,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Icon(Icons.keyboard_double_arrow_right, size: 32, color: Colors.blue),
              Text(
                event.formattedEndTime,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityList extends StatelessWidget {
  const ActivityList({
    super.key,
    required this.context,
    required this.activities, 
    this.limit,
  });

  final BuildContext context;
  final List activities;
  final int? limit;

  @override
  Widget build(BuildContext context) {
  if (activities.isEmpty) {
    return Center(child: Text('Tidak ada kegiatan'));
  }

  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  int itemCount = limit != null && limit! < activities.length ? limit! : activities.length;

  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: itemCount,
    itemBuilder: (context, index) {
      final activity = activities[index];
      String dateString = activity['tanggal'];
      DateTime date = DateTime.parse(dateString);
      return InkWell(
        onTap: () {
          Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                image: activity['gambar'],
                title: activity['nama_kegiatan'],
                date: date,
                place: activity['tempat'],
                desc: activity['deskripsi'],
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5,),
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [Colors.black12, Colors.black26] // Dark mode colors
                  : [Colors.white, Colors.grey[100]!], // Light mode colors
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.4), //Dark/Light on Left Top
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(4, 4),
              ),
              BoxShadow(
                color: isDarkMode ? Colors.grey[700]!.withOpacity(0.1) : Colors.white.withOpacity(0.8), //Dark/Light on Right Bottom
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(-4, -4),
              ),
            ],
            border: Border.all(
              color: isDarkMode ? Colors.white : Colors.black,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
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
  );
}
}

