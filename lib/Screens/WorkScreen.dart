import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkScreen extends StatefulWidget {
  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  DateTime? selectedDate;
  FocusNode _focusNode = FocusNode();
  FocusNode _focusNode2 = FocusNode();

  String? _selectedActivity;
  final TextEditingController _descCrtl = TextEditingController();
  final TextEditingController _placeCrtl = TextEditingController();

  final List<String> _activityOptions = [
    'Seni & Budaya',
    'Pembangunan',
    'Pemberdayaan',
    'Pemerintahan',
    'Darurat (Bencana)',
    'KAMTIBMAS'
  ];

  Future<void> _pickerImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatSelectedDate(DateTime? date) {
    if (date == null) {
      return 'Pilih Tanggal';
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return token;
  }

  Future<void> _submitActivity() async {
    if (selectedDate == null || _selectedActivity == null || _descCrtl.text.isEmpty || _placeCrtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tolong isi semua kolomnya.'))
      );
      return;
    }
    
    final url = Uri.parse('https://laporsemanu.my.id/api/kegiatan/');
    String? token = await _getToken();

    if (token == null) {
      print('Token tidak ditemukan');
      return;
    }

    final newActivity = {
      "nama_kegiatan": _selectedActivity,
      "tanggal": DateFormat('yyyy-MM-dd').format(selectedDate!),
      "tempat": _placeCrtl.text,
      "deskripsi": _descCrtl.text,
    };

    //Send Data to API
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['kegiatan'] = jsonEncode(newActivity);

    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        _imageFile!.path,
      ));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingAnimationWidget.threeRotatingDots(
        color: Colors.blue, 
        size: 30
        );
      },
    );

    try {
      final response = await request.send();
      Navigator.of(context).pop();
      if (response.statusCode == 200 || response.statusCode == 201) {
        //  Provider.of<ActivityModel>(context, listen: false).addActivity(newActivity);
        setState(() {
          _descCrtl.clear();
          _placeCrtl.clear();
          _selectedActivity = null;
          selectedDate = null;
          _imageFile = null;
        });

        _showResultDialog('Berhasil Mengirim', 'lib/assets/lottie/animation-success.json', 'Done');
      } else {
        print('Gagal mengirim data: ${response.statusCode}');
         _showResultDialog('Gagal Mengirim', 'lib/assets/lottie/animation-failed.json', 'Ulangi');
      }
    } catch (e) {
      print('Error: $e');
      Navigator.of(context).pop();
      _showResultDialog('Gagal Mengirim', 'lib/assets/lottie/animation-failed.json', 'Ulangi'); 
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Submit Kegiatan',
              style: TextStyle(
                fontSize: 18
              ),),
            Text('Silakan isi formulir di bawah ini.',
              style: TextStyle(
                fontSize: 16
              ),),
          ],
        ),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Form(
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedActivity,
                        items: _activityOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedActivity = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Pilih Nama Kegiatan',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          contentPadding: const EdgeInsets.all(10.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        focusNode: _focusNode,
                        minLines: 5,
                        maxLines: null,
                        controller: _descCrtl,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi...',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          contentPadding: const EdgeInsets.all(16.0),
                          
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tanggal'),
                      const SizedBox(height: 5),
                      InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(width: 2.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          formatSelectedDate(selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                      const SizedBox(height: 16),
                      TextFormField(
                        focusNode: _focusNode2,
                        controller: _placeCrtl,
                        decoration: InputDecoration(
                          labelText: 'Tempat',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          contentPadding: const EdgeInsets.all(16.0),
                          
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Foto'),
                      GestureDetector(
                        onTap: _showFullImg,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                          )
                          : Image.asset(
                              'lib/assets/img/no-image.jpg',
                              width: double.infinity,
                              height: 200.0,
                              fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showPicker(context),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(width: 2.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.add_a_photo_rounded, size: 32.0),
                              SizedBox(width: 16),
                              Text('Upload Foto'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                        onTap: () => _showConfirmationDialog(),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                              "Simpan",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImg() {
    showDialog(context: context, 
    builder: (BuildContext context) {
      return Dialog(
        child: InteractiveViewer(
          child: _imageFile != null
          ? Image.file(
              _imageFile!,
              fit: BoxFit.contain,
            )
          : Image.asset(
              'lib/assets/img/no-image.jpg',
              width: double.infinity,
              height: 200.0,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickerImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickerImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Kegiatan'),
          content: Text('Apakah anda yakin untuk mengirimkan kegiatan?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Batalkan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _submitActivity();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Simpan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  void _showResultDialog(String message, String lottiePath, String massageButton) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final double width = MediaQuery.of(context).size.width;
        return Container(
          padding: EdgeInsets.all(20),
          child: Dialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: width * 0.8,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Lottie.asset(
                    lottiePath,
                    width: 150,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        massageButton,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
