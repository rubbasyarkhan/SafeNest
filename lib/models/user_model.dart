class UserModel {
  final String? name;
  final String? email;
  final String? image;
  final double? latitude;
  final double? longitude;
  final String? locationLink;

  UserModel({
    this.name,
    this.email,
    this.image,
    this.latitude,
    this.longitude,
    this.locationLink,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'locationLink': locationLink,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      image: json['image'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationLink: json['locationLink'],
    );
  }
}
