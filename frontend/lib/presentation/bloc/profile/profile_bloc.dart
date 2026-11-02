import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/accessibility_profile.dart';
import '../../../domain/repositories/user_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final List<String> disabilityTypes;
  final List<String> assistanceNeeds;
  final String visibility;
  final bool consentGranted;

  const UpdateProfileEvent({
    required this.disabilityTypes,
    required this.assistanceNeeds,
    required this.visibility,
    required this.consentGranted,
  });

  @override
  List<Object?> get props => [disabilityTypes, assistanceNeeds, visibility, consentGranted];
}

class ExportDataEvent extends ProfileEvent {}
class AnonymizeAccountEvent extends ProfileEvent {}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final AccessibilityProfile profile;
  final Map<String, dynamic>? exportedData;
  final bool anonymizeSuccess;

  const ProfileLoaded({
    required this.profile,
    this.exportedData,
    this.anonymizeSuccess = false,
  });

  ProfileLoaded copyWith({
    AccessibilityProfile? profile,
    Map<String, dynamic>? exportedData,
    bool? anonymizeSuccess,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      exportedData: exportedData ?? this.exportedData,
      anonymizeSuccess: anonymizeSuccess ?? this.anonymizeSuccess,
    );
  }

  @override
  List<Object?> get props => [profile, exportedData, anonymizeSuccess];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await repository.getAccessibilityProfile();
        emit(ProfileLoaded(profile: profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await repository.updateAccessibilityProfile(
          disabilityTypes: event.disabilityTypes,
          assistanceNeeds: event.assistanceNeeds,
          visibility: event.visibility,
          consentGranted: event.consentGranted,
        );
        emit(ProfileLoaded(profile: profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<ExportDataEvent>((event, emit) async {
      try {
        final data = await repository.exportUserData();
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(exportedData: data));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<AnonymizeAccountEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        await repository.anonymizeAccount();
        emit(const ProfileLoaded(
          profile: AccessibilityProfile(userId: ''),
          anonymizeSuccess: true,
        ));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
