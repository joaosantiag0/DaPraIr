import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/social_connection.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/social_repository.dart';

// Events
abstract class SocialEvent extends Equatable {
  const SocialEvent();
  @override
  List<Object?> get props => [];
}

class LoadSocialDataEvent extends SocialEvent {}

class SendConnectionRequestEvent extends SocialEvent {
  final String targetUserId;
  const SendConnectionRequestEvent(this.targetUserId);
  @override
  List<Object?> get props => [targetUserId];
}

class UpdateConnectionStatusEvent extends SocialEvent {
  final String connectionId;
  final String status;
  const UpdateConnectionStatusEvent({required this.connectionId, required this.status});
  @override
  List<Object?> get props => [connectionId, status];
}

// States
abstract class SocialState extends Equatable {
  const SocialState();
  @override
  List<Object?> get props => [];
}

class SocialInitial extends SocialState {}
class SocialLoading extends SocialState {}

class SocialLoaded extends SocialState {
  final List<SocialConnection> friends;
  final List<SocialConnection> pendingReceived;
  final List<SocialConnection> pendingSent;
  final List<UserProfile> recommendations;

  const SocialLoaded({
    required this.friends,
    required this.pendingReceived,
    required this.pendingSent,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [friends, pendingReceived, pendingSent, recommendations];
}

class SocialError extends SocialState {
  final String message;
  const SocialError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialRepository repository;

  SocialBloc({required this.repository}) : super(SocialInitial()) {
    on<LoadSocialDataEvent>(_onLoadSocialData);
    on<SendConnectionRequestEvent>(_onSendRequest);
    on<UpdateConnectionStatusEvent>(_onUpdateStatus);
  }

  Future<void> _onLoadSocialData(LoadSocialDataEvent event, Emitter<SocialState> emit) async {
    emit(SocialLoading());
    try {
      final connections = await repository.getConnections();
      final recommendations = await repository.getRecommendations();

      final friends = connections.where((c) => c.status == 'ACCEPTED').toList();
      final pendingReceived = connections.where((c) => c.status == 'PENDING' && !c.isOutgoing).toList();
      final pendingSent = connections.where((c) => c.status == 'PENDING' && c.isOutgoing).toList();

      emit(SocialLoaded(
        friends: friends,
        pendingReceived: pendingReceived,
        pendingSent: pendingSent,
        recommendations: recommendations,
      ));
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }

  Future<void> _onSendRequest(SendConnectionRequestEvent event, Emitter<SocialState> emit) async {
    try {
      await repository.sendConnectionRequest(event.targetUserId);
      add(LoadSocialDataEvent());
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(UpdateConnectionStatusEvent event, Emitter<SocialState> emit) async {
    try {
      await repository.updateConnectionStatus(event.connectionId, event.status);
      add(LoadSocialDataEvent());
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }
}
