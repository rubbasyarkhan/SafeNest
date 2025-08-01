class ContactModel {
  final String? name;
  final String? phone;
  final String? email;
  final String? image; // Base64 encoded string

  ContactModel({this.name, this.phone, this.email, this.image});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'image': image,
      };

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        name: json['name'],
        phone: json['phone'],
        email: json['email'],
        image: json['image'],
      );
}
