class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final String? gender;
  final String? identityNumber;
  final String? status;
  final DateTime? createAt;
  final String? token;
  final DateTime? tokenExpiry;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.address,
    this.avatarUrl,
    this.gender,
    this.identityNumber,
    this.status,
    this.createAt,
    this.token,
    this.tokenExpiry,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'address': address,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'identityNumber': identityNumber,
      'status': status,
      'createAt': createAt?.toIso8601String(),
      'token': token,
      'tokenExpiry': tokenExpiry?.millisecondsSinceEpoch,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      gender: json['gender']?.toString(),
      identityNumber: json['identityNumber']?.toString(),
      status: json['status']?.toString(),
      createAt: json['createAt'] != null 
          ? DateTime.tryParse(json['createAt'].toString())
          : null,
      token: json['token']?.toString(),
      tokenExpiry: json['tokenExpiry'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['tokenExpiry'])
          : null,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? address,
    String? avatarUrl,
    String? gender,
    String? identityNumber,
    String? status,
    DateTime? createAt,
    String? token,
    DateTime? tokenExpiry,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      identityNumber: identityNumber ?? this.identityNumber,
      status: status ?? this.status,
      createAt: createAt ?? this.createAt,
      token: token ?? this.token,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}