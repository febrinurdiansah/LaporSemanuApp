import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  File? _profileImage;
  bool _isLoading = false;

  // Create TextEditingControllers
  late TextEditingController _nikController;
  late TextEditingController _nipController;
  late TextEditingController _nameController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _birthDateController;
  late TextEditingController _jobController;
  late TextEditingController _positionController;
  late TextEditingController _lastEducationController;
  late TextEditingController _addressController;
  late TextEditingController _termStartController;
  late TextEditingController _termEndController;

  @override
  void initState() {
    super.initState();

    // Initialize TextEditingControllers with the user profile data
    _nikController = TextEditingController(text: widget.userProfile.nik);
    _nipController = TextEditingController(text: widget.userProfile.nip);
    _nameController = TextEditingController(text: widget.userProfile.name);
    _birthPlaceController = TextEditingController(text: widget.userProfile.birthPlace);
    _birthDateController = TextEditingController(text: widget.userProfile.birthDate);
    _jobController = TextEditingController(text: widget.userProfile.job);
    _positionController = TextEditingController(text: widget.userProfile.position);
    _lastEducationController = TextEditingController(text: widget.userProfile.lastEducation);
    _addressController = TextEditingController(text: widget.userProfile.address);
    _termStartController = TextEditingController(text: widget.userProfile.termStart.toString());
    _termEndController = TextEditingController(text: widget.userProfile.termEnd.toString());
  // Initialize ProfileNotifier with existing values
    final profileNotifier = Provider.of<ProfileNotifier>(context, listen: false);
    profileNotifier.updateGender(widget.userProfile.gender);
    profileNotifier.updateBloodType(widget.userProfile.bloodType);
    profileNotifier.updateBirthDate(widget.userProfile.birthDate);
    profileNotifier.updateReligion(widget.userProfile.religion);
    profileNotifier.updateMaritalStatus(widget.userProfile.maritalStatus);
}

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nikController.dispose();
    _nipController.dispose();
    _nameController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _jobController.dispose();
    _positionController.dispose();
    _lastEducationController.dispose();
    _addressController.dispose();
    _termStartController.dispose();
    _termEndController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final profileNotifier = Provider.of<ProfileNotifier>(context, listen: false);
      final formattedDate = "${picked.toLocal().year.toString().padLeft(4, '0')}-${picked.toLocal().month.toString().padLeft(2, '0')}-${picked.toLocal().day.toString().padLeft(2, '0')}";
      profileNotifier.updateBirthDate(formattedDate);
      _birthDateController.text = formattedDate;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Token diambil dari SharedPreferences: $token');
    return token;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final profileNotifier = Provider.of<ProfileNotifier>(context, listen: false);
    final token = await _getToken();
    final url = 'https://laporsemanu.my.id/api/pamong/'; 

    try {
      setState(() {
        _isLoading = true;
      });

      final request = http.MultipartRequest('PUT', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['pamong'] = jsonEncode({
          'nama': _nameController.text,
          'jenis_kelamin': profileNotifier.gender,
          'gol_darah': profileNotifier.bloodType,
          'tempat_lahir': _birthPlaceController.text,
          'tanggal_lahir': profileNotifier.birthDate,
          'nik': _nikController.text,
          'pekerjaan': _jobController.text,
          'jabatan': _positionController.text,
          'pendidikan_terakhir': _lastEducationController.text,
          'status_kawin': profileNotifier.maritalStatus,
          'agama': profileNotifier.religion,
          'alamat': _addressController.text,
          'nip': _nipController.text,
          'masa_jabatan_mulai': _termStartController.text,
          'masa_jabatan_selesai': _termEndController.text,
        });

      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _profileImage!.path,
        ));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Profile updated successfully');
        final profileModel = Provider.of<ProfileModel>(context, listen: false);
        await profileModel.fetchUserProfile(); 
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ubah data berhasil!'),
              backgroundColor: Colors.green,
            )
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to update profile: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ubah data gagal, tolong lagi periksa data Anda'),
              backgroundColor: Colors.red,
            ),
        );
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
    final profileNotifier = Provider.of<ProfileNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: _isLoading
      ? Center(
        child: LoadingAnimationWidget.threeRotatingDots(
                color: Colors.blue, size: 30
                )
              )
      :Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Image Display
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : NetworkImage(widget.userProfile.image) as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16.0),
                // Content Data
                TextFormField(
                  controller: _nikController,
                  decoration: InputDecoration(labelText: 'NIK'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _nipController,
                  decoration: InputDecoration(labelText: 'NIP'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nama'),
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
                  controller: _birthPlaceController,
                  decoration: InputDecoration(labelText: 'Tempat Lahir'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(labelText: 'Tanggal Lahir'),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  initialValue: profileNotifier.birthDate,
                ),
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
                TextFormField(
                  controller: _jobController,
                  decoration: InputDecoration(labelText: 'Pekerjaan'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _positionController,
                  decoration: InputDecoration(labelText: 'Jabatan'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _lastEducationController,
                  decoration: InputDecoration(labelText: 'Pendidikan Terakhir'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Alamat'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _termStartController,
                  decoration: InputDecoration(labelText: 'Masa Jabatan Mulai'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _termEndController,
                  decoration: InputDecoration(labelText: 'Masa Jabatan Selesai'),
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _updateProfile();
                    }
                  },
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
