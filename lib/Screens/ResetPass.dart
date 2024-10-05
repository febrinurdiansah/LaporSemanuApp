import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ResetPassScreen extends StatefulWidget {
  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final TextEditingController _PassCtrl = TextEditingController();
  bool isLoading = true;

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _reset() async {
    final token = await _getToken();
    if (token == null) {
      // Handle no token case
      isLoading = false;
      return;
    }
    try {
      // Headers dan body diubah untuk JSON
      http.Response response = await http.post(
        Uri.parse('https://laporsemanu.my.id/api/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'new_password': _PassCtrl.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kata Sandi berhasil diubah!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        print('Failed with status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kata Sandi gagal diubah, tolong periksa lagi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan, coba lagi nanti'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Kata Sandi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            Text('Silakan isi Kata Sandi di bawah ini.',
              style: TextStyle(
                fontSize: 16
              )
            ),
            SizedBox(height: 30,),
            TextFormField(
              controller: _PassCtrl,
              decoration: InputDecoration(
                labelText: 'Kata Sandi',
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
            SizedBox(height: 40,),
            InkWell(
              onTap: () async {
                if (_PassCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kata Sandi tidak boleh kosong'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                await _reset();
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
                    "Simpan",
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
    );
  }
}
