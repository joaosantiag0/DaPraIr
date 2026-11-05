import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/social_connection.dart';
import '../../bloc/social/social_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_card.dart';
import '../../components/responsive_container.dart';

class BlockedContactsScreen extends StatefulWidget {
  const BlockedContactsScreen({super.key});

  @override
  State<BlockedContactsScreen> createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends State<BlockedContactsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SocialBloc>().add(LoadBlockedUsersEvent());
  }

  void _confirmUnblock(BuildContext context, String connectionId, String peerName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_open_rounded, color: AppColors.primaryBlue, size: 24),
            SizedBox(width: 8),
            Expanded(child: Text('Desbloquear Contato')),
          ],
        ),
        content: Text(
          'Deseja desbloquear $peerName? Ao desbloquear, vocês poderão se encontrar na comunidade e enviar novas solicitações de amizade.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SocialBloc>().add(UnblockUserEvent(connectionId));
              SemanticsHelper.announce('$peerName foi desbloqueado.');
            },
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos Bloqueados'),
      ),
      body: BlocConsumer<SocialBloc, SocialState>(
        listener: (context, state) {
          if (state is SocialLoaded) {
            if (state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionMessage!),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state.actionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionError!),
                  backgroundColor: AppColors.warningOrange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is SocialLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando contatos bloqueados...'),
                ],
              ),
            );
          }

          final List<SocialConnection> blockedUsers =
              (state is SocialLoaded) ? state.blockedUsers : <SocialConnection>[];

          return ResponsiveContainer.medium(
            child: blockedUsers.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.block,
                              size: 54,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum contato bloqueado',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Usuários que você bloquear em conversas ou no perfil não poderão enviar mensagens diretas para você e aparecerão listados aqui.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textHint, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: blockedUsers.length,
                    itemBuilder: (context, index) {
                      final item = blockedUsers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AccessibleCard(
                          semanticLabel: 'Contato bloqueado ${item.peer.name}. Toque para opções.',
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.surfaceMuted,
                                child: Text(
                                  item.peer.name.isNotEmpty ? item.peer.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.peer.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.peer.handle,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textHint,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                  side: const BorderSide(color: AppColors.primaryBlue),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.lock_open, size: 16),
                                label: const Text('Desbloquear'),
                                onPressed: () => _confirmUnblock(context, item.id, item.peer.name),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
