import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ProfileModel.dart';
import '../models/UserData.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  EditProfileScreen({required this.userProfile});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final profileNotifier = Provider.of<ProfileNotifier>(context, listen: false);

    // Initialize fields with profile data
    profileNotifier.updateName(widget.userProfile.name);
    profileNotifier.updateGender(widget.userProfile.gender);
    profileNotifier.updateBloodType(widget.userProfile.bloodType);
    profileNotifier.updateBirthPlace(widget.userProfile.birthPlace);
    profileNotifier.updateBirthDate(widget.userProfile.birthDate);
    profileNotifier.updateNik(widget.userProfile.nik);
    profileNotifier.updateJob(widget.userProfile.job);
    profileNotifier.updatePosition(widget.userProfile.position);
    profileNotifier.updateLastEducation(widget.userProfile.lastEducation);
    profileNotifier.updateMaritalStatus(widget.userProfile.maritalStatus);
    profileNotifier.updateReligion(widget.userProfile.religion);
    profileNotifier.updateAddress(widget.userProfile.address);
    profileNotifier.updateNip(widget.userProfile.nip);
    profileNotifier.updateTermStart(widget.userProfile.termStart);
    profileNotifier.updateTermEnd(widget.userProfile.termEnd);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      final profileNotifier = Provider.of<ProfileNotifier>(context, listen: false);
      final formattedDate = "${picked.toLocal().year.toString().padLeft(4, '0')}-${picked.toLocal().month.toString().padLeft(2, '0')}-${picked.toLocal().day.toString().padLeft(2, '0')}";
      profileNotifier.updateBirthDate(formattedDate);
    }
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Token diambil dari SharedPreferences: $token');
    return token;
  }

  Future<void> _updateProfile() async {
  final profileNotifier = Provider.of<ProfileNotifier>(context, listen: false);
  final token = await _getToken();
  final url = 'https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/pamong/'; // Replace with your API URL

  try {
    final request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['pamong'] = jsonEncode({
        'nama': profileNotifier.name,
        'jenis_kelamin': profileNotifier.gender,
        'gol_darah': profileNotifier.bloodType,
        'tempat_lahir': profileNotifier.birthPlace,
        'tanggal_lahir': profileNotifier.birthDate,
        'nik': profileNotifier.nik,
        'pekerjaan': profileNotifier.job,
        'jabatan': profileNotifier.position,
        'pendidikan_terakhir': profileNotifier.lastEducation,
        'status_kawin': profileNotifier.maritalStatus,
        'agama': profileNotifier.religion,
        'alamat': profileNotifier.address,
        'nip': profileNotifier.nip,
        'masa_jabatan_mulai': profileNotifier.termStart.toString(),
        'masa_jabatan_selesai': profileNotifier.termEnd.toString(),
      });

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Profile updated successfully');
      final profileModel = Provider.of<ProfileModel>(context, listen: false);
      await profileModel.fetchUserProfile(); // Fetch updated profile data
      Navigator.pop(context); // Go back to the profile screen
    } else {
      final responseBody = await response.stream.bytesToString();
      print('Failed to update profile: $responseBody');
    }
  } catch (e) {
    print('Error: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    final profileNotifier = Provider.of<ProfileNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: profileNotifier.nik,
                  decoration: InputDecoration(labelText: 'NIK'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => profileNotifier.updateNik(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.nip,
                  decoration: InputDecoration(labelText: 'NIP'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => profileNotifier.updateNip(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.name,
                  decoration: InputDecoration(labelText: 'Nama'),
                  onChanged: (value) => profileNotifier.updateName(value),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: profileNotifier.gender,
                  decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                  items: ['L', 'P'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender == 'L' ? 'Laki-laki' : 'Perempuan'),
                    );
                  }).toList(),
                  onChanged: (value) => profileNotifier.updateGender(value),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: profileNotifier.bloodType,
                  decoration: InputDecoration(labelText: 'Golongan Darah'),
                  items: ['A', 'B', 'AB', 'O'].map((bloodType) {
                    return DropdownMenuItem(
                      value: bloodType,
                      child: Text(bloodType),
                    );
                  }).toList(),
                  onChanged: (value) => profileNotifier.updateBloodType(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.birthPlace,
                  decoration: InputDecoration(labelText: 'Tempat Lahir'),
                  onChanged: (value) => profileNotifier.updateBirthPlace(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Tanggal Lahir'),
                  readOnly: true,
                  controller: TextEditingController(text: profileNotifier.birthDate),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.job,
                  decoration: InputDecoration(labelText: 'Pekerjaan'),
                  onChanged: (value) => profileNotifier.updateJob(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.position,
                  decoration: InputDecoration(labelText: 'Jabatan'),
                  onChanged: (value) => profileNotifier.updatePosition(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.lastEducation,
                  decoration: InputDecoration(labelText: 'Pendidikan Terakhir'),
                  onChanged: (value) => profileNotifier.updateLastEducation(value),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: profileNotifier.maritalStatus,
                  decoration: InputDecoration(labelText: 'Status Kawin'),
                  items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'].map((maritalStatus) {
                    return DropdownMenuItem(
                      value: maritalStatus,
                      child: Text(maritalStatus),
                    );
                  }).toList(),
                  onChanged: (value) => profileNotifier.updateMaritalStatus(value),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: profileNotifier.religion,
                  decoration: InputDecoration(labelText: 'Agama'),
                  items: ['Islam', 'Kristen', 'Hindu', 'Budha', 'Konghucu'].map((religion) {
                    return DropdownMenuItem(
                      value: religion,
                      child: Text(religion),
                    );
                  }).toList(),
                  onChanged: (value) => profileNotifier.updateReligion(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.address,
                  decoration: InputDecoration(labelText: 'Alamat'),
                  onChanged: (value) => profileNotifier.updateAddress(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.termStart.toString(),
                  decoration: InputDecoration(labelText: 'Masa Jabatan Mulai'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => profileNotifier.updateTermStart(int.tryParse(value) ?? 0),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: profileNotifier.termEnd.toString(),
                  decoration: InputDecoration(labelText: 'Masa Jabatan Selesai'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => profileNotifier.updateTermEnd(int.tryParse(value) ?? 0),
                ),
                const SizedBox(height: 32.0),
                InkWell(
                  onTap: () => _updateProfile(),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                          color: Colors.white,
                        ),
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
}
