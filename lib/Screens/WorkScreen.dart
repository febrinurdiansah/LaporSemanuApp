import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:monkir/Screens/SuccessScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

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
    final DateFormat formatter = DateFormat('MMMM d, yyyy');
    String start = formatter.format(dateRange[0]);
    String end = formatter.format(dateRange[1]);

    return '$start to $end';
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
                child: ElevatedButton(
                  onPressed: () => _showConfirmationDialog(),
                  child: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Fungsi dialog konfirmasi
  void _showConfirmationDialog(){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Anda yakin mengirim?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                //tested
                print('Kegiatan: ${_activityController.text}');
                print('desc: ${_descController.text}');
                print('Tanggal: ${dateTimeList}');
                print('Foto: ${_imageFile != null ? _imageFile!.path : 'No Image Selected'}');
                print('Tempat: ${_placeController.text}');

                //bersih-bersih
                _activityController.clear();
                _descController.clear();
                _placeController.clear();
                setState(() {
                  dateTimeList = null;
                  _imageFile = null;
                });

                Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => SuccessScreen()
                  ));
              },
              child: Text('Ya')
              ),
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text('Tidak')
              ),
          ],
        );
      },
    );
  }

  //Fungsi Mengambil gambar
  void _showPicker(BuildContext context) {
  showModalBottomSheet(
    context: context, 
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Photo Library'),
              onTap: () {
                _pickerImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Photo Camera'),
              onTap: () {
                _pickerImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        )
        );
      },
    );
  }

  //Fungsi untuk menampilkan gambar full preview
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
}