class UserProfile {
  final String name;
  final String nip;
  final String birthDate;
  final String maritalStatus;
  final String position;
  final String religion;
  final int termStart;
  final String lastEducation;
  final String nik;
  final int id;
  final String birthPlace;
  final String address;
  final String job;
  final String bloodType;
  final String gender;
  final int termEnd;
  final String image;

  UserProfile({
    required this.name,
    required this.nip,
    required this.birthDate,
    required this.maritalStatus,
    required this.position,
    required this.religion,
    required this.termStart,
    required this.lastEducation,
    required this.nik,
    required this.id,
    required this.birthPlace,
    required this.address,
    required this.job,
    required this.bloodType,
    required this.gender,
    required this.termEnd,
    required this.image,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['nama'],
      nip: json['nip'],
      birthDate: json['tanggal_lahir'],
      maritalStatus: json['status_kawin'],
      position: json['jabatan'],
      religion: json['agama'],
      termStart: json['masa_jabatan_mulai'],
      lastEducation: json['pendidikan_terakhir'],
      nik: json['nik'],
      id: json['id'],
      birthPlace: json['tempat_lahir'],
      address: json['alamat'],
      job: json['pekerjaan'],
      bloodType: json['gol_darah'],
      gender: json['jenis_kelamin'],
      termEnd: json['masa_jabatan_selesai'],
      image: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': name,
      'nip': nip,
      'tanggal_lahir': birthDate,
      'status_kawin': maritalStatus,
      'jabatan': position,
      'agama': religion,
      'masa_jabatan_mulai': termStart,
      'pendidikan_terakhir': lastEducation,
      'nik': nik,
      'id': id,
      'tempat_lahir': birthPlace,
      'alamat': address,
      'pekerjaan': job,
      'gol_darah': bloodType,
      'jenis_kelamin': gender,
      'masa_jabatan_selesai': termEnd,
      'gambar': image,
    };
  }
}
