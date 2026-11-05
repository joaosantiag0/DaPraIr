import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/base/equatable.dart';
import 'package:dio/dio.dart';
import '../../../domain/entities/social_connection.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/social_repository.dart';

// Helper to format friendly user messages
String cleanSocialErrorMessage(dynamic error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (error.response?.statusCode == 401) {
      return 'Você precisa estar conectado para acessar a comunidade e amigos.';
    }
    if (error.response?.statusCode == 403) {
      return 'Você não tem permissão para realizar esta ação.';
    }
    if (error.response?.statusCode == 404) {
      return 'Usuário ou conexão não encontrada.';
    }
    if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de resposta excedido. Verifique sua conexão com a internet.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Não foi possível conectar ao servidor. Verifique se o servidor está ativo.';
    }
  }
  return error.toString();
}

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

class BlockUserEvent extends SocialEvent {
  final String targetUserId;
  final String? connectionId;
  const BlockUserEvent({required this.targetUserId, this.connectionId});
  @override
  List<Object?> get props => [targetUserId, connectionId];
}

class UnblockUserEvent extends SocialEvent {
  final String connectionId;
  const UnblockUserEvent(this.connectionId);
  @override
  List<Object?> get props => [connectionId];
}

class LoadBlockedUsersEvent extends SocialEvent {}

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
  final List<SocialConnection> blockedUsers;
  final List<UserProfile> recommendations;
  final String? actionMessage;
  final String? actionError;

  const SocialLoaded({
    required this.friends,
    required this.pendingReceived,
    required this.pendingSent,
    this.blockedUsers = const [],
    required this.recommendations,
    this.actionMessage,
    this.actionError,
  });

  SocialLoaded copyWith({
    List<SocialConnection>? friends,
    List<SocialConnection>? pendingReceived,
    List<SocialConnection>? pendingSent,
    List<SocialConnection>? blockedUsers,
    List<UserProfile>? recommendations,
    String? actionMessage,
    String? actionError,
  }) {
    return SocialLoaded(
      friends: friends ?? this.friends,
      pendingReceived: pendingReceived ?? this.pendingReceived,
      pendingSent: pendingSent ?? this.pendingSent,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      recommendations: recommendations ?? this.recommendations,
      actionMessage: actionMessage,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [friends, pendingReceived, pendingSent, blockedUsers, recommendations, actionMessage, actionError];
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
    on<LoadBlockedUsersEvent>(_onLoadBlockedUsers);
    on<SendConnectionRequestEvent>(_onSendRequest);
    on<UpdateConnectionStatusEvent>(_onUpdateStatus);
    on<BlockUserEvent>(_onBlockUser);
    on<UnblockUserEvent>(_onUnblockUser);
  }

  Future<void> _onLoadSocialData(LoadSocialDataEvent event, Emitter<SocialState> emit) async {
    emit(SocialLoading());
    try {
      final connections = await repository.getConnections();
      final recommendations = await repository.getRecommendations();
      final blocked = await repository.getBlockedUsers();

      final friends = connections.where((c) => c.status == 'ACCEPTED').toList();
      final pendingReceived = connections.where((c) => c.status == 'PENDING' && !c.isOutgoing).toList();
      final pendingSent = connections.where((c) => c.status == 'PENDING' && c.isOutgoing).toList();

      emit(SocialLoaded(
        friends: friends,
        pendingReceived: pendingReceived,
        pendingSent: pendingSent,
        blockedUsers: blocked,
        recommendations: recommendations,
      ));
    } catch (e) {
      emit(SocialError(cleanSocialErrorMessage(e)));
    }
  }

  Future<void> _onLoadBlockedUsers(LoadBlockedUsersEvent event, Emitter<SocialState> emit) async {
    try {
      final blocked = await repository.getBlockedUsers();
      if (state is SocialLoaded) {
        final current = state as SocialLoaded;
        emit(current.copyWith(blockedUsers: blocked));
      } else {
        emit(SocialLoaded(
          friends: const [],
          pendingReceived: const [],
          pendingSent: const [],
          blockedUsers: blocked,
          recommendations: const [],
        ));
      }
    } catch (e) {
      if (state is SocialLoaded) {
        final current = state as SocialLoaded;
        emit(current.copyWith(actionError: cleanSocialErrorMessage(e)));
      } else {
        emit(SocialError(cleanSocialErrorMessage(e)));
      }
    }
  }

  Future<void> _onSendRequest(SendConnectionRequestEvent event, Emitter<SocialState> emit) async {
    try {
      await repository.sendConnectionRequest(event.targetUserId);
      final connections = await repository.getConnections();
      final recommendations = await repository.getRecommendations();
      final blocked = await repository.getBlockedUsers();

      final friends = connections.where((c) => c.status == 'ACCEPTED').toList();
      final pendingReceived = connections.where((c) => c.status == 'PENDING' && !c.isOutgoing).toList();
      final pendingSent = connections.where((c) => c.status == 'PENDING' && c.isOutgoing).toList();

      emit(SocialLoaded(
        friends: friends,
        pendingReceived: pendingReceived,
        pendingSent: pendingSent,
        blockedUsers: blocked,
        recommendations: recommendations,
        actionMessage: 'Solicitação de conexão enviada com sucesso!',
      ));
    } catch (e) {
      if (state is SocialLoaded) {
        final current = state as SocialLoaded;
        emit(current.copyWith(actionError: cleanSocialErrorMessage(e)));
      } else {
        emit(SocialError(cleanSocialErrorMessage(e)));
      }
    }
  }

  Future<void> _onUpdateStatus(UpdateConnectionStatusEvent event, Emitter<SocialState> emit) async {
    try {
      await repository.updateConnectionStatus(event.connectionId, event.status);
      final connections = await repository.getConnections();
      final recommendations = await repository.getRecommendations();
      final blocked = await repository.getBlockedUsers();

      final friends = connections.where((c) => c.status == 'ACCEPTED').toList();
      final pendingReceived = connections.where((c) => c.status == 'PENDING' && !c.isOutgoing).toList();
      final pendingSent = connections.where((c) => c.status == 'PENDING' && c.isOutgoing).toList();

      final msg = event.status == 'ACCEPTED'
          ? 'Solicitação aceita!'
          : (event.status == 'BLOCKED' ? 'Usuário bloqueado com sucesso.' : 'Solicitação recusada.');
      emit(SocialLoaded(
        friends: friends,
        pendingReceived: pendingReceived,
        pendingSent: pendingSent,
        blockedUsers: blocked,
        recommendations: recommendations,
        actionMessage: msg,
      ));
    } catch (e) {
      if (state is SocialLoaded) {
        final current = state as SocialLoaded;
        emit(current.copyWith(actionError: cleanSocialErrorMessage(e)));
      } else {
        emit(SocialError(cleanSocialErrorMessage(e)));
      }
    }
  }

  Future<void> _onBlockUser(BlockUserEvent event, Emitter<SocialState> emit) async {
    try {
      if (event.connectionId != null) {
        await repository.updateConnectionStatus(event.connectionId!, 'BLOCKED');
      } else {
        await repository.blockUser(event.targetUserId);
      }

      final connections = await repository.getConnections();
      final recommendations = await repository.getRecommendations();
      final blocked = await repository.getBlockedUsers();

      final friends = connections.where((c) => c.status == 'ACCEPTED').toList();
      final pendingReceived = connections.where((c) => c.status == 'PENDING' && !c.isOutgoing).toList();
      final pendingSent = connections.where((c) => c.status == 'PENDING' && c.isOutgoing).toList();

      emit(SocialLoaded(
        friends: friends,
        pendingReceived: pendingReceived,
        pendingSent: pendingSent,
        blockedUsers: blocked,
        recommendations: recommendations,
        actionMessage: 'Contato bloqueado com sucesso.',
      ));
    } catch (e) {
      if (state is SocialLoaded) {
        final current = state as SocialLoaded;
        emit(current.copyWith(actionError: cleanSocialErrorMessage(e)));
      } else {
        emit(SocialError(cleanSocialErrorMessage(e)));
      }
    }
  }

  Future<void> _onUnblockUser(UnblockUserEvent event, Emitter<SocialState> emit) async {
    try {
      await repository.unblockUser(event.connectionId);

      final connections = await repository.getConnections();
      final recommendations = await repository.getRecommendations();
      final blocked = await repository.getBlockedUsers();

      final friends = connections.where((c) => c.status == 'ACCEPTED').toList();
      final pendingReceived = connections.where((c) => c.status == 'PENDING' && !c.isOutgoing).toList();
      final pendingSent = connections.where((c) => c.status == 'PENDING' && c.isOutgoing).toList();

      emit(SocialLoaded(
        friends: friends,
        pendingReceived: pendingReceived,
        pendingSent: pendingSent,
        blockedUsers: blocked,
        recommendations: recommendations,
        actionMessage: 'Contato desbloqueado com sucesso.',
      ));
    } catch (e) {
      if (state is SocialLoaded) {
        final current = state as SocialLoaded;
        emit(current.copyWith(actionError: cleanSocialErrorMessage(e)));
      } else {
        emit(SocialError(cleanSocialErrorMessage(e)));
      }
    }
  }
}
