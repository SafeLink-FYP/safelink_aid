import 'dart:io';

class SignUpModel {
  final String fullName;
  final String email;
  final String password;
  final String cnic;
  final String dateOfBirth;
  final String? phone;
  final String? region;
  final String? city;
  final File? profilePicture;

  const SignUpModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.cnic,
    required this.dateOfBirth,
    this.phone,
    this.region,
    this.city,
    this.profilePicture,
  });

  /// Organization, designation, and department are intentionally NOT here.
  /// The user picks/inherits an org when they create or join a team — that's
  /// when `aid_worker_profiles` is first written. The handle_new_user trigger
  /// skips the aid_worker_profiles INSERT when organization_id is missing,
  /// which is the desired behavior.
  Map<String, dynamic> toAuthMetadata() => {
    'full_name': fullName.trim(),
    'phone': phone,
    'cnic': cnic.trim(),
    'date_of_birth': dateOfBirth,
    'role': 'aid_worker',
    'region': region?.trim(),
    'city': city?.trim(),
  };

  /// Avatar uploads happen after signup, so they're the only column the
  /// `handle_new_user` trigger can't populate from auth metadata.
  Map<String, dynamic> toProfileUpdate(String? avatarUrl) => {
    if (avatarUrl != null) 'avatar_url': avatarUrl,
  };
}

class SignInModel {
  final String email;
  final String password;

  const SignInModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'password': password,
  };
}

class ResetPasswordModel {
  final String email;

  const ResetPasswordModel({required this.email});

  Map<String, dynamic> toJson() => {'email': email.trim()};
}
