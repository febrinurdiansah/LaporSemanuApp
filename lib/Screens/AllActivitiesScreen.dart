import 'package:flutter/material.dart';

class AllActivitiesScreen extends StatelessWidget {
  final List<dynamic> activities;

  AllActivitiesScreen({required this.activities});

  // Fungsi untuk menampilkan detail kegiatan
  Future<dynamic> _showDetailActivity(BuildContext context, dynamic activity) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            activity['nama_kegiatan'],
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activity['gambar'] != null && activity['gambar']!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    activity['gambar']!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'lib/assets/img/no-image.jpg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                )
              else
                Image.asset(
                  'lib/assets/img/no-image.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),
              Text('Tempat: ${activity['tempat']}'),
              const SizedBox(height: 8),
              Text('Deskripsi: ${activity['deskripsi'] ?? 'Tidak ada deskripsi'}'),
              const SizedBox(height: 8),
              Text('Tanggal: ${activity['tanggal']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semua Kegiatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return InkWell(
              onTap: () {
                _showDetailActivity(context, activity);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white 
                        : Colors.black,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        (activity['gambar'] != null && activity['gambar']!.isNotEmpty)
                            ? activity['gambar']!
                            : 'lib/assets/img/no-image.jpg',
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'lib/assets/img/no-image.jpg',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(activity['nama_kegiatan'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(activity['tempat'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
