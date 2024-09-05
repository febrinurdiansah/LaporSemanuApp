import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool showEvents = true;

  final List<NeatCleanCalendarEvent> _eventList = [
    NeatCleanCalendarEvent(
      'Kegiatan abcde',
      description: 'test desc',
      location: 'Isekai',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 30),
      endTime: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 50),
      color: Colors.orange,
      isAllDay: false
    ),
    NeatCleanCalendarEvent('Event X',
        description: 'test desc',
        startTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 10, 30),
        endTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 11, 30),
        color: Colors.lightGreen,
        isAllDay: false,
        isDone: true,
        wide: false),
    NeatCleanCalendarEvent('Allday Event B',
        description: 'test desc',
        startTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day , 14, 30),
        endTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day + 3, 17, 0),
        color: Colors.pink,
        isAllDay: false,
        wide: true),
    NeatCleanCalendarEvent(
      'Normal Event D',
      description: 'test desc',
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 14, 30),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0),
      color: Colors.indigo,
      wide: true,
    ),
    NeatCleanCalendarEvent(
      'Normal Event E',
      description: 'test desc',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 5, 7, 45),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 5, 9, 0),
      color: Colors.indigo,
      wide: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Force selection of today on first load, so that the list of today's events gets shown.
    _handleNewDate(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day));
  }

  Widget eventCell(BuildContext context, NeatCleanCalendarEvent event,
      String start, String end) {
    return Container(
        padding: EdgeInsets.all(8.0),
        child: Text('Calendar Event: ${event.summary} from $start to $end'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Calendar(
          startOnMonday: true,
          weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Frd', 'Sat', 'Sun'],
          eventsList: _eventList,
          isExpandable: true,
          // You can set your own event cell builder function to customize the event cells
          // Try it by uncommenting the line below
          // eventCellBuilder: eventCell,
          eventDoneColor: Colors.deepPurple,
          selectedColor: Colors.blue,
          selectedTodayColor: Colors.green,
          todayColor: Colors.teal,
          defaultDayColor: Colors.orange,
          defaultOutOfMonthDayColor: Colors.grey,
          datePickerDarkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.yellow,
              surface: Colors.grey,
              onSurface: Colors.yellow,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ),
          datePickerLightTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.teal,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ),
          eventColor: null,
          locale: 'id_ID',
          todayButtonText: 'Today',
          allDayEventText: 'All Day',
          multiDayEndText: 'End',
          isExpanded: true,
          expandableDateFormat: 'EEEE, dd. MMMM yyyy',
          onEventSelected: (value) {
            print('Event selected ${value.summary}');
            showDialog(
              context: context,
              builder: (context) => AlertDialog.adaptive(
                title: Text(
                  "Kegiatan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actionsAlignment: MainAxisAlignment.end,
                content: Column(
                  mainAxisSize: MainAxisSize.min, 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('desc Kegiatan A', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Isekai', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Jam', style: TextStyle(fontSize: 16)),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('bali'),
                  ),
                ],
              ),
            );
          },
          onEventLongPressed: (value) {
            print('Event long pressed ${value.summary}');
          },
          // onMonthChanged: (value) {
          //   print('Month changed $value');
          // },
          onDateSelected: (value) {
            print('Date selected $value');
          },
          onRangeSelected: (value) {
            print('Range selected ${value.from} - ${value.to}');
          },
          datePickerType: DatePickerType.date,
          dayOfWeekStyle: TextStyle(
              color: Colors.red, fontWeight: FontWeight.w800, fontSize: 11),
          showEventListViewIcon: true,
          
        ),
      ),
    );
  }

  void _handleNewDate(date) {
    print('Date selected: $date');
  }
}