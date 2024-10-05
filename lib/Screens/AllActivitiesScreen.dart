import 'package:LaporSemanu/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';

class AllActivitiesScreen extends StatelessWidget {
  final List<dynamic> activities;

  AllActivitiesScreen({required this.activities});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semua Kegiatan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ActivityList(
            context: context, 
            activities: activities,
          ),
        ),
      ),
    );
  }
}
