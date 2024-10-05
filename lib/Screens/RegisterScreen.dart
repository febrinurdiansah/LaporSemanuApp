import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _nikCrtl = TextEditingController();
  final _usnmCrtl = TextEditingController();
  final _emailCrtl = TextEditingController();
  final _pswdCrtl = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _nikCrtl.dispose();
    _usnmCrtl.dispose();
    _emailCrtl.dispose();
    _pswdCrtl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nik = _nikCrtl.text;
    final username = _usnmCrtl.text;
    final email = _emailCrtl.text;
    final password = _pswdCrtl.text;

    if (nik.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Tolong isi semua kolomnya'),
        ),
      );
      return;
    }

    final url = 'https://laporsemanu.my.id/api/auth/users';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nik': nik,
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Membuat akun berhasil!!'),
        ),
      );

      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Membuat Akun'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.teal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Lapor Semanu',
                            style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Colors.black26,
                                offset: const Offset(0.0, 2.0),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Buat Akun',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    ),
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  'Tolong isi sesuai dengan perintah.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    ),
                                ),
                                const SizedBox(height: 24.0),
                                TextFormField(
                                  controller: _nikCrtl,
                                  decoration: InputDecoration(
                                    labelText: 'NIK',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _usnmCrtl,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _emailCrtl,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _pswdCrtl,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: 'Kata Sandi',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: _togglePasswordView,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 50),
                                InkWell(
                                  onTap: () => _register(),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      color: Colors.blue,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Buat Akun",
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
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah Punya Akun?',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              ),
                              child: Text(
                                'Klik sini',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
