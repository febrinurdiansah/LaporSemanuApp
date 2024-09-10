import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monkir/Screens/FailedScreen.dart';
import 'package:monkir/Screens/SuccessScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkScreen extends StatefulWidget {
  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  List<DateTime>? dateTimeList;

  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  Future<void> _pickerImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  String formatDateRange(List<DateTime> dateRange) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String start = formatter.format(dateRange[0]);
    String end = formatter.format(dateRange[1]);

    return '$start to $end';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Token diambil dari SharedPreferences: $token');
    return token;
  }

  Future<void> _submitActivity() async {
    if (dateTimeList == null || _activityController.text.isEmpty || _descController.text.isEmpty || _placeController.text.isEmpty) {
      // Handle error case: if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.'))
      );
      return;
    }
    final url = Uri.parse('https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/kegiatan/');
    
    // Ambil token dari SharedPreferences
    String? token = await _getToken();

    // Cek apakah token tersedia
    if (token == null) {
      print('Token tidak ditemukan');
      return;
    }

    // Membuat permintaan multipart
    var request = http.MultipartRequest('POST', url);
    // Menambahkan header Authorization dengan token yang diambil
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    // Menambahkan data kegiatan dalam bentuk string
    request.fields['kegiatan'] = jsonEncode({
      "nama_kegiatan": _activityController.text,
      "tanggal": DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTimeList![0]),
      "tempat": _placeController.text,
      "deskripsi": _descController.text,
    });

    // Menambahkan file jika ada (opsional)
    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        _imageFile!.path,
      ));
    }

    final response = await request.send();
    // Memeriksa status respons
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Data berhasil dikirim');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen())
      );
      // Lakukan hal lain jika sukses
    } else {
      print('Gagal mengirim data: ${response.statusCode}');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FailedScreen())
      );
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');
    }
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
                      TextFormField(
                        controller: _activityController,
                        decoration: InputDecoration(
                          labelText: 'Kegiatan',
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
                        minLines: 5,
                        maxLines: null,
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Description...',
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
                      const Text('Due Date'),
                      InkWell(
                        onTap: () async {
                          List<DateTime>? selectedDates = await showOmniDateTimeRangePicker(
                          context: context,
                          startInitialDate: DateTime.now(),
                          startFirstDate:DateTime(1600).subtract(const Duration(days: 3652)),
                          startLastDate: DateTime.now().add( const Duration(days: 3652),),
                          endInitialDate: DateTime.now(),
                          endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
                          endLastDate: DateTime.now().add(const Duration(days: 3652), ),
                          is24HourMode: true,
                          minutesInterval: 1,
                          secondsInterval: 1,
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          constraints: const BoxConstraints(
                            maxWidth: 350,
                            maxHeight: 650,
                          ),
                          transitionBuilder: (context, anim1, anim2, child) {
                            return FadeTransition(
                              opacity: anim1.drive(
                                Tween(
                                  begin: 0,
                                  end: 1,
                                ),
                              ),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 200),
                          barrierDismissible: true,
                        );
                        if (selectedDates != null){
                          setState(() {
                            dateTimeList = selectedDates;
                          });
                        }
                        },
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
                            dateTimeList == null
                            ? 'Select a date'
                            : formatDateRange(dateTimeList!),
                            style: const TextStyle(fontSize: 16),
                            ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _placeController,
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
                          : Image.network(
                            'https://picsum.photos/seed/867/600',
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
                              "Submit",
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
          : Image.network(
              'https://picsum.photos/seed/867/600',
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
          title: Text('Submit Activity'),
          content: Text('Are you sure you want to submit the activity?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _submitActivity(); 
              },
              child: Text('Submit'),
            ),
          ],
        );
      }
    );
  }
}
