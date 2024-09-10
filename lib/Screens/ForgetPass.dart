import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPassScreen extends StatefulWidget {
  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _emailCtrl = TextEditingController();

  Future<void> _reset() async {
    try {
      // Headers dan body diubah untuk JSON
      http.Response response = await http.post(
        Uri.parse('https://technological-adriena-taufiqdp-d94bbf04.koyeb.app/auth/forget-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailCtrl.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        print('Failed with status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email gagal dikirim, tolong periksa lagi emailnya'),
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
        title: Text('Lupa Kata Sandi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        child: Column(
          children: [
            Text('Silakan isi email di bawah ini. Lalu tunggu untuk mendapatkan email',
              style: TextStyle(
                fontSize: 16
              )
            ),
            SizedBox(height: 25,),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
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
                if (_emailCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email tidak boleh kosong'),
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
