import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// Fungsi untuk menghasilkan warna cerah secara acak
Color getRandomColor() {
  Random random = Random();
  List<Color> colors = [
    Color(0xFFE57373),
    Color(0xFFF06292),
    Color(0xFFBA68C8),
    Color(0xFF64B5F6),
    Color(0xFF4DB6AC),
    Color(0xFF4CAF50),
    Color(0xFFFFF176),
    Color(0xFFFFB74D),
  ];
  return colors[random.nextInt(colors.length)];
}


// Model Event
class Event {
  final String title;
  final String desc;
  final String place;
  final Color color;
  final String formattedStartTime;
  final String formattedEndTime;
  Event(this.title, this.color, this.desc, this.place, this.formattedStartTime, this.formattedEndTime);

  @override
  String toString() => title;
}


class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  LinkedHashMap<DateTime, List<Event>> kEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    fetchAgendaData();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Token diambil dari SharedPreferences: $token');
    return token;
  }

  // Fungsi untuk mengambil data dari API
  Future<void> fetchAgendaData() async {
    final token = await _getToken();
    if (token == null) {
      print('No token found');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = 'https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/agenda/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
      List<dynamic> agendaData = jsonDecode(response.body);

      // Parsing data dari API dan memasukkannya ke dalam kEvents
      for (var agenda in agendaData) {
        DateTime startDate = DateTime.parse(agenda['tanggal_mulai']);
        DateTime endDate = DateTime.parse(agenda['tanggal_selesai']);
        String eventTitle = agenda['nama_agenda'];
        String eventDesc = agenda['deskripsi'];
        String eventPlace = agenda['tempat'];
        Color eventColor = getRandomColor();

        // Format time using DateFormat from intl package
        String formattedStartTime = DateFormat('HH:mm').format(startDate);
        String formattedEndTime = DateFormat('HH:mm').format(endDate);

        // Masukkan event ke kEvents menggunakan format LinkedHashMap
        for (var day = startDate; day.isBefore(endDate.add(Duration(days: 1))); day = day.add(Duration(days: 1))) {
          if (kEvents[day] == null) {
            kEvents[day] = [Event(eventTitle, eventColor, eventDesc, eventPlace, formattedStartTime, formattedEndTime)];
          } else {
            kEvents[day]!.add(Event(eventTitle, eventColor, eventDesc, eventPlace, formattedStartTime, formattedEndTime));
          }
        }
      }

      // Perbarui UI dengan event dari API
      setState(() {
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } else {
      throw Exception('Failed to load agenda');
    }

      
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender Agenda'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            locale: 'id_ID',
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 1,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1.0,
                    child: Row(
                      children: events.map((event) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: event.color,
                            shape: BoxShape.circle,
                          ),
                          width: 7.0,
                          height: 7.0,
                        );
                      }).toList(),
                    ),
                  );
                }
                return SizedBox.shrink(); // Return an empty widget if no events
              },
            ),
            
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              if (_calendarFormat != format){
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                _selectedEvents.value = _getEventsForDay(selectedDay);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circle with the date of the selected day
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          margin: const EdgeInsets.only(right: 12.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue, 
                          ),
                          child: Center(
                            child: Text(
                              '${_selectedDay?.day}',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Date: ${_selectedDay?.toLocal().toString().split(' ')[0]}', // Display full date or adjust as needed
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List of events for the selected day
                  Expanded(
                    child: ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(events[index].title, style: TextStyle(fontWeight: FontWeight.bold)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8.0),
                                    Text('Deskripsi:\n${events[index].desc}'),
                                    SizedBox(height: 8.0),
                                    Text('Tempat: ${events[index].place}'),
                                    SizedBox(height: 8.0),
                                    Text('Waktu: ${events[index].formattedStartTime} - ${events[index].formattedEndTime}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context), 
                                    child: Text('Kembali'),
                                  ),
                                ],
                              );
                            },
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: events[index].color.withOpacity(0.9), // Background color for the event card
                            ),
                            child: ListTile(
                              title: Text(
                                events[index].title,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${events[index].formattedStartTime} - ${events[index].formattedEndTime}',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ],
      ),
    );
  }
}

// Fungsi getHashCode tetap sama
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
