// ==================== APP USER MODEL ====================

class AppUser {
  // ==================== PROPERTIES ====================
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime? createdAt;

  // ==================== CONSTRUCTOR ====================
  const AppUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.createdAt,
  });

  // ==================== FACTORY METHODS ====================
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        firstName: json['first_name'],
        lastName: json['last_name'],
        createdAt: _parseDateTime(json['created_at']),
      );

  // ==================== CONVERSION METHODS ====================
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'created_at': createdAt?.toIso8601String(),
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'createdAt': createdAt?.millisecondsSinceEpoch,
      };

  // ==================== STATIC HELPERS ====================
  static DateTime? _parseDateTime(String? dateTimeString) =>
      dateTimeString != null ? DateTime.parse(dateTimeString) : null;

  // ==================== COMPUTED PROPERTIES ====================
  String get fullName => [firstName, lastName]
      .where((name) => name != null && name!.isNotEmpty)
      .join(' ');

  String get displayName => fullName.isNotEmpty ? fullName : email.split('@').first;

  String get initials => _getInitials();

  bool get hasCompleteProfile => 
      (firstName?.isNotEmpty ?? false) && (lastName?.isNotEmpty ?? false);

  // ==================== PRIVATE METHODS ====================
  String _getInitials() {
    if (firstName == null && lastName == null) return '';
    if (firstName == null) return lastName![0].toUpperCase();
    if (lastName == null) return firstName![0].toUpperCase();
    return '${firstName![0]}${lastName![0]}'.toUpperCase();
  }

  // ==================== COPY METHOD ====================
  AppUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
  }) =>
      AppUser(
        id: id ?? this.id,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        createdAt: createdAt ?? this.createdAt,
      );

  // ==================== EQUALITY ====================
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, email, firstName, lastName, createdAt);

  // ==================== STRING REPRESENTATION ====================
  @override
  String toString() => 'AppUser(id: $id, email: $email, name: $fullName)';
}