import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/base/equatable.dart';
import '../../../domain/entities/user_penalty.dart';
import '../../../domain/repositories/admin_repository.dart';

// Events
abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();
  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends AdminUsersEvent {
  final String? status;
  final String? query;

  const LoadUsersEvent({this.status, this.query});

  @override
  List<Object?> get props => [status, query];
}

class ApplyUserPenaltyEvent extends AdminUsersEvent {
  final String userId;
  final String penaltyType;
  final String reason;

  const ApplyUserPenaltyEvent({
    required this.userId,
    required this.penaltyType,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, penaltyType, reason];
}

class RevokeUserPenaltyEvent extends AdminUsersEvent {
  final String userId;
  final String penaltyId;
  final String reason;

  const RevokeUserPenaltyEvent({
    required this.userId,
    required this.penaltyId,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, penaltyId, reason];
}

// States
abstract class AdminUsersState extends Equatable {
  const AdminUsersState();
  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUserSummary> users;
  final String? currentStatus;
  final String? currentQuery;

  const AdminUsersLoaded({
    required this.users,
    this.currentStatus,
    this.currentQuery,
  });

  @override
  List<Object?> get props => [users, currentStatus, currentQuery];
}

class AdminUsersError extends AdminUsersState {
  final String message;
  const AdminUsersError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUsersActionSuccess extends AdminUsersState {
  final String message;
  const AdminUsersActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final AdminRepository _repository;

  AdminUsersBloc({required AdminRepository repository})
      : _repository = repository,
        super(AdminUsersInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<ApplyUserPenaltyEvent>(_onApplyPenalty);
    on<RevokeUserPenaltyEvent>(_onRevokePenalty);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      final users = await _repository.listUsers(
        status: event.status,
        query: event.query,
      );
      emit(AdminUsersLoaded(
        users: users,
        currentStatus: event.status,
        currentQuery: event.query,
      ));
    } catch (e) {
      emit(AdminUsersError('Erro ao carregar lista de usuários: $e'));
    }
  }

  Future<void> _onApplyPenalty(
    ApplyUserPenaltyEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.applyPenalty(
        userId: event.userId,
        penaltyType: event.penaltyType,
        reason: event.reason,
      );
      emit(const AdminUsersActionSuccess('Penalidade aplicada com sucesso.'));
      add(const LoadUsersEvent());
    } catch (e) {
      emit(AdminUsersError('Erro ao aplicar penalidade: $e'));
    }
  }

  Future<void> _onRevokePenalty(
    RevokeUserPenaltyEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.revokePenalty(
        userId: event.userId,
        penaltyId: event.penaltyId,
        reason: event.reason,
      );
      emit(const AdminUsersActionSuccess('Penalidade revogada com sucesso.'));
      add(const LoadUsersEvent());
    } catch (e) {
      emit(AdminUsersError('Erro ao revogar penalidade: $e'));
    }
  }
}
