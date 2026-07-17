class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String street;
  final String city;
  final String pincode;
  final String state;

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.pincode,
    required this.state,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['_id'] ?? json['id']) as String? ?? '',
      name: (json['fullName'] ?? json['name']) as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: (json['addressLine1'] ?? json['street']) as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: (json['postalCode'] ?? json['pincode']) as String? ?? '',
      state: json['state'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (id.isNotEmpty) '_id': id,
      'fullName': name,
      'name': name,
      'phone': phone,
      'addressLine1': street,
      'street': street,
      'postalCode': pincode,
      'pincode': pincode,
      'state': state,
      'city': city,
    };
  }
}
