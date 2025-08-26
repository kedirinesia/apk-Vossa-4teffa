class Student {
  String name;
  String? kelas;
  String? programKeahlian;

  Student({
    required this.name,
    this.kelas,
    this.programKeahlian,
  });

  Student copyWith({String? name, String? kelas, String? programKeahlian}) {
    return Student(
      name: name ?? this.name,
      kelas: kelas ?? this.kelas,
      programKeahlian: programKeahlian ?? this.programKeahlian,
    );
  }
}
