import 'package:flutter/material.dart';
import 'package:monkir/Screens/FailedScreen.dart';
import 'package:monkir/Screens/LoginScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // FocusScope.of(context).unfocus();
    TextStyle _style = TextStyle(
      fontSize: 16
    );
    String name = 'Joe';
    String getTime = '';
    String getQuots = '';
    int hours = DateTime.now().hour;
    if(hours>=0 && hours<=11){
      getTime= 'Selamat Pagi';
      getQuots= 'Have a wonderful day!';
    } else if(hours<=15){
      getTime= 'Selamat Siang';
      getQuots= 'I hope your having a great day!';
    } else if (hours<=20){
      getTime= 'Selamat Sore';
      getQuots= 'ss';
    } else if(hours<=24){
      getTime= 'Selamat Malam';
      getQuots= 'Mimpi Indah';
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Kelurahan Semanu'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$getTime, $name',
                              style: _style,),
                            const SizedBox(height: 8.0),
                            Text(getQuots,
                              style: _style),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2, 
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => LoginScreen()
                                ));
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1611590027211-b954fd027b51?auto=format&fit=crop&w=1338&q=80',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Text('Senin, 1 Agustus', style: TextStyle(fontSize: 25)),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_sharp),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => FailedScreen()
                              ));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border: Border.all(
                      width: 1,
                      color: Colors.black
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kegiatan Sosialisasi', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 5),
                        Text('Tempat Di Desa Maju Mundur', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('12.00', style: TextStyle(fontSize: 20)),
                              Icon(Icons.keyboard_double_arrow_right, size: 32, color: Colors.blue),
                              Text('12.00', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
