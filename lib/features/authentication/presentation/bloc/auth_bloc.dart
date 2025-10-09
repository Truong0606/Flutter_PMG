import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetProfileRequested>(_onGetProfileRequested);
    
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        // Try to fetch a fresh profile first when a session exists
        try {
          final profileResult = await _authRepository.getProfile();
          if (profileResult.success && profileResult.user != null) {
            emit(AuthAuthenticated(profileResult.user!));
            return;
          }
        } catch (_) {
          // Ignore and try cached user below
        }

        // Fallback to cached user if profile fetch fails (offline/204/etc.)
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(event.email, event.password);
      if (result.success && result.user != null) {
        // After a successful login, proactively fetch the full profile
        // so subsequent pages (like Profile) have complete data.
        try {
          final profileResult = await _authRepository.getProfile();
          if (profileResult.success && profileResult.user != null) {
            emit(AuthAuthenticated(profileResult.user!));
          } else {
            // Fall back to the basic user info from login if profile fetch fails
            emit(AuthAuthenticated(result.user!));
          }
        } catch (_) {
          // On any exception during profile fetch, still authenticate with login user
          emit(AuthAuthenticated(result.user!));
        }
      } else {
        emit(AuthError(result.error ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      if (result.success) {
        emit(AuthRegistrationSuccess('Registration successful! Please use the mobile app.'));
      } else {
        emit(AuthError(result.error ?? 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onGetProfileRequested(GetProfileRequested event, Emitter<AuthState> emit) async {
    // Don't emit AuthLoading if user is already authenticated - this prevents UI flicker
    // Only emit loading if we're not currently in an authenticated state
    if (state is! AuthAuthenticated) {
      emit(AuthLoading());
    }
    
    try {
      final result = await _authRepository.getProfile();
      if (result.success && result.user != null) {
        emit(AuthAuthenticated(result.user!));
      } else {
        // For any error (including 204), just get the current user and show profile
        final currentUser = await _authRepository.getCurrentUser();
        if (currentUser != null) {
          emit(AuthAuthenticated(currentUser));
        } else {
          emit(AuthError('Please login again'));
        }
      }
    } catch (e) {
      // Even for network errors, try to show cached user
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
      } else {
        emit(AuthError('Please login again'));
      }
    }
  }



  void _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.updateProfile(
        name: event.name,
        phone: event.phone,
        address: event.address,
        avatarUrl: event.avatarUrl,
        gender: event.gender,
        identityNumber: event.identityNumber,
      );
      if (result.success && result.user != null) {
        // Just emit AuthAuthenticated with the updated user data directly
        // This will immediately update the UI with the latest information
        emit(AuthAuthenticated(result.user!));
      } else {
        emit(AuthError(result.error ?? 'Failed to update profile'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}