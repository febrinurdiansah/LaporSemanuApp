import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/UserData.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  EditProfileScreen({required this.userProfile});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _jenisKelamin;
  String? _golDarah;
  String? _statusKawin;
  String? _agama;
  late String _nama;
  late String _tempatLahir;
  late String _pekerjaan;
  late String _tanggalLahir;
  late String _alamat;
  late String _jabatan;
  late String _nik;
  late String _pendidikanTerakhir;
  late String _nip;

  @override
  void initState() {
    super.initState();
    // Initialize fields with the profile data
    final profile = widget.userProfile;
    _jenisKelamin = profile.gender;
    _golDarah = profile.bloodType;
    _statusKawin = profile.maritalStatus;
    
    _agama = profile.religion;
    _nama = profile.name;
    _tempatLahir = profile.birthPlace;
    _pekerjaan = profile.job;
    _tanggalLahir = profile.birthDate;
    _alamat = profile.address;
    _jabatan = profile.position;
    _nik = profile.nik;
    _pendidikanTerakhir = profile.lastEducation;
    _nip = profile.nip;
  }

  Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2101),
  );

  if (picked != null && picked != DateTime.now()) {
    setState(() {
      _tanggalLahir = "${picked.toLocal().day}/${picked.toLocal().month}/${picked.toLocal().year}";
    });
  }
}

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Token diambil dari SharedPreferences: $token');
    return token;
  }

  // Function to send data to API
  Future<void> _updateProfile() async {
    final token = await _getToken();
    final url = 'https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/pamong/'; // Replace with your API URL

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama': _nama,
        'jenis_kelamin': _jenisKelamin,
        'golongan_darah': _golDarah,
        'tempat_lahir': _tempatLahir,
        'tanggal_lahir': _tanggalLahir,
        'nik': _nik,
        'pekerjaan': _pekerjaan,
        'jabatan': _jabatan,
        'pendidikan_terakhir': _pendidikanTerakhir,
        'status_kawin': _statusKawin,
        'agama': _agama,
        'alamat': _alamat,
        'nip': _nip,
      }),
    );

    if (response.statusCode == 200) {
      print('Profile updated successfully');
      Navigator.pop(context); // Go back to the profile screen
    } else {
      print('Failed to update profile');
    }
  }

  void _printValues() {
    print('Nama: $_nama');
    print('Jenis Kelamin: $_jenisKelamin');
    print('Golongan Darah: $_golDarah');
    print('Tempat Lahir: $_tempatLahir');
    print('Tanggal Lahir: $_tanggalLahir');
    print('NIK: $_nik');
    print('Pekerjaan: $_pekerjaan');
    print('Jabatan: $_jabatan');
    print('Pendidikan Terakhir: $_pendidikanTerakhir');
    print('Status Kawin: $_statusKawin');
    print('Agama: $_agama');
    print('Alamat: $_alamat');
    print('NIP: $_nip');
  }

  @override
  Widget build(BuildContext context) {
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
                // NIK
                TextFormField(
                  decoration: InputDecoration(labelText: 'NIK'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _nik = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIK tidak boleh kosong';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'NIK hanya boleh berisi angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                // NIK
                TextFormField(
                  decoration: InputDecoration(labelText: 'NIP'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _nip = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIP tidak boleh kosong';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'NIP hanya boleh berisi angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                // Nama
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nama'),
                  onChanged: (value) => _nama = value,
                ),
                const SizedBox(height: 16.0),

                // Jenis Kelamin
                DropdownButtonFormField<String>(
                  value: _jenisKelamin,
                  decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                  items: ['L', 'P'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender == 'L' ? 'Laki-laki' : 'Perempuan'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _jenisKelamin = value;
                  }),
                ),
                const SizedBox(height: 16.0),

                // Golongan Darah
                DropdownButtonFormField<String>(
                  value: _golDarah,
                  decoration: InputDecoration(labelText: 'Golongan Darah'),
                  items: ['A', 'B', 'AB', 'O'].map((bloodType) {
                    return DropdownMenuItem(
                      value: bloodType,
                      child: Text(bloodType),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _golDarah = value;
                  }),
                ),
                const SizedBox(height: 16.0),

                // Tempat Lahir
                TextFormField(
                  decoration: InputDecoration(labelText: 'Tempat Lahir'),
                  onChanged: (value) => _tempatLahir = value,
                ),
                const SizedBox(height: 16.0),

                // Tanggal Lahir (DatePicker)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Tanggal Lahir'),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  controller: TextEditingController(text: _tanggalLahir),
                ),

                // Pekerjaan
                TextFormField(
                  decoration: InputDecoration(labelText: 'Pekerjaan'),
                  onChanged: (value) => _pekerjaan = value,
                ),
                const SizedBox(height: 16.0),

                // Jabatan
                TextFormField(
                  decoration: InputDecoration(labelText: 'Jabatan'),
                  onChanged: (value) => _jabatan = value,
                ),
                const SizedBox(height: 16.0),

                // Pendidikan Terakhir
                TextFormField(
                  decoration: InputDecoration(labelText: 'Pendidikan Terakhir'),
                  onChanged: (value) => _pendidikanTerakhir = value,
                ),
                const SizedBox(height: 16.0),

                // Status Kawin
                DropdownButtonFormField<String>(
                  value: _statusKawin,
                  decoration: InputDecoration(labelText: 'Status Kawin'),
                  items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _statusKawin = value;
                  }),
                ),
                const SizedBox(height: 16.0),

                // Agama
                DropdownButtonFormField<String>(
                  value: _agama,
                  decoration: InputDecoration(labelText: 'Agama'),
                  items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Budha', 'Konghucu'].map((religion) {
                    return DropdownMenuItem(
                      value: religion,
                      child: Text(religion),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _agama = value;
                  }),
                ),
                const SizedBox(height: 16.0),

                // Alamat
                TextFormField(
                  decoration: InputDecoration(labelText: 'Alamat'),
                  onChanged: (value) => _alamat = value,
                ),
                const SizedBox(height: 24.0),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _printValues(); // Print form values to console
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
