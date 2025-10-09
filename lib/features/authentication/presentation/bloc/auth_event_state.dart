import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class GetProfileRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final String? gender;
  final String? identityNumber;

  const UpdateProfileRequested({
    required this.name,
    this.phone,
    this.address,
    this.avatarUrl,
    this.gender,
    this.identityNumber,
  });

  @override
  List<Object> get props => [name, if (phone != null) phone!, if (address != null) address!, if (avatarUrl != null) avatarUrl!, if (gender != null) gender!, if (identityNumber != null) identityNumber!];
}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileUpdateSuccess extends AuthState {
  final String message;
  final User user;

  const ProfileUpdateSuccess(this.message, this.user);

  @override
  List<Object> get props => [message, user];
}