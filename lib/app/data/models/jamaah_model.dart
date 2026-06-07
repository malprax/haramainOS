class JamaahModel {
  String? id;
  String? fullName;
  String? passportNumber;
  String? phoneNumber;

  JamaahModel({this.id, this.fullName, this.passportNumber, this.phoneNumber});

  factory JamaahModel.fromJson(Map<String, dynamic> json) {
    return JamaahModel(
      id: json['id'],
      fullName: json['fullName'],
      passportNumber: json['passportNumber'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'passportNumber': passportNumber,
      'phoneNumber': phoneNumber,
    };
  }
}
