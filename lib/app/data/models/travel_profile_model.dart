class TravelProfileModel {
  String? id;
  String? travelName;
  String? ownerName;
  String? logoUrl;
  String? phoneNumber;
  String? whatsappNumber;
  String? email;
  String? website;
  String? address;
  String? city;
  String? province;
  String? country;
  String? description;

  TravelProfileModel({
    this.id,
    this.travelName,
    this.ownerName,
    this.logoUrl,
    this.phoneNumber,
    this.whatsappNumber,
    this.email,
    this.website,
    this.address,
    this.city,
    this.province,
    this.country,
    this.description,
  });

  factory TravelProfileModel.fromJson(Map<String, dynamic> json) {
    return TravelProfileModel(
      id: json['id'] as String?,
      travelName: json['travelName'] as String?,
      ownerName: json['ownerName'] as String?,
      logoUrl: json['logoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      country: json['country'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travelName': travelName,
      'ownerName': ownerName,
      'logoUrl': logoUrl,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'website': website,
      'address': address,
      'city': city,
      'province': province,
      'country': country,
      'description': description,
    };
  }
}
