class MutawwifModel {
  String? id;
  String? fullName;
  String? phoneNumber;
  String? whatsappNumber;
  String? email;
  String? notes;
  String? imageUrl;
  bool? isActive;

  MutawwifModel({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.whatsappNumber,
    this.email,
    this.notes,
    this.imageUrl,
    this.isActive,
  });

  factory MutawwifModel.fromJson(Map<String, dynamic> json) {
    return MutawwifModel(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      whatsappNumber: json['whatsappNumber'],
      email: json['email'],
      notes: json['notes'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'notes': notes,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
