import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/social/social_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_card.dart';
import '../../components/responsive_container.dart';
import 'chat_conversation_screen.dart';

class SocialConnectionsScreen extends StatefulWidget {
  final bool isAuthenticated;
  final VoidCallback? onNavigateToLogin;

  const SocialConnectionsScreen({
    super.key,
    this.isAuthenticated = true,
    this.onNavigateToLogin,
  });

  @override
  State<SocialConnectionsScreen> createState() => _SocialConnectionsScreenState();
}

class _SocialConnectionsScreenState extends State<SocialConnectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.isAuthenticated) {
      context.read<SocialBloc>().add(LoadSocialDataEvent());
    }
  }

  @override
  void didUpdateWidget(covariant SocialConnectionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isAuthenticated && widget.isAuthenticated) {
      context.read<SocialBloc>().add(LoadSocialDataEvent());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Comunidade e Amigos'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    size: 56,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Conecte-se com a Comunidade',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Encontre amigos que compartilham experiências semelhantes de acessibilidade, troque recomendações de rotas e converse diretamente pelo chat.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 28),
                AccessibleButton(
                  label: 'Entrar ou Cadastrar',
                  icon: Icons.login,
                  onPressed: () {
                    if (widget.onNavigateToLogin != null) {
                      widget.onNavigateToLogin!();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidade e Amigos'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.hcPrimaryYellow,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Amigos'),
            Tab(text: 'Solicitações'),
            Tab(text: 'Sugestões'),
          ],
        ),
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
                  Text('Carregando comunidade...'),
                ],
              ),
            );
          }

          if (state is SocialError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.warningLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, size: 48, color: AppColors.warningOrange),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar conexões:\n${state.message}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AccessibleButton(
                      label: 'Tentar Novamente',
                      icon: Icons.refresh,
                      onPressed: () => context.read<SocialBloc>().add(LoadSocialDataEvent()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SocialLoaded) {
            return ResponsiveContainer.wide(
              child: TabBarView(
                controller: _tabController,
                children: [
                // 1. Friends Tab
                state.friends.isEmpty
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
                                child: const Icon(Icons.people_outline, size: 54, color: AppColors.textHint),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Você ainda não tem amigos conectados.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Adicione amigos na aba de Sugestões para conversar diretamente sobre qualquer assunto, combinar passeios e trocar ideias.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textHint),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.friends.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, i) {
                          final friend = state.friends[i];
                          return AccessibleCard(
                            semanticLabel: 'Amigo ${friend.peer.name}, clique para abrir a conversa',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatConversationScreen(
                                    peerUserId: friend.peer.id,
                                    peerName: friend.peer.name,
                                    peerHandle: friend.peer.handle,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primaryContainer,
                                  child: Text(
                                    friend.peer.name.isNotEmpty ? friend.peer.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend.peer.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        friend.peer.handle,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textHint,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryBlue, size: 20),
                                ),
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: AppColors.textHint, size: 20),
                                  tooltip: 'Mais opções',
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (val) {
                                    if (val == 'block') {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Row(
                                            children: [
                                              Icon(Icons.block, color: AppColors.warningOrange, size: 24),
                                              SizedBox(width: 8),
                                              Expanded(child: Text('Bloquear Usuário?')),
                                            ],
                                          ),
                                          content: Text(
                                            'Deseja bloquear ${friend.peer.name}? Ao bloquear, ele não poderá enviar mensagens para você. Você poderá desbloqueá-lo em Perfil > Contatos Bloqueados.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.warningOrange,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                context.read<SocialBloc>().add(
                                                      BlockUserEvent(
                                                        targetUserId: friend.peer.id,
                                                        connectionId: friend.id,
                                                      ),
                                                    );
                                              },
                                              child: const Text('Bloquear'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'block',
                                      child: Row(
                                        children: [
                                          Icon(Icons.block, color: AppColors.warningOrange, size: 18),
                                          SizedBox(width: 8),
                                          Text('Bloquear Contato', style: TextStyle(color: AppColors.warningOrange)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // 2. Pending Requests Tab
                state.pendingReceived.isEmpty
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
                                child: const Icon(Icons.mark_email_read_outlined, size: 54, color: AppColors.textHint),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma solicitação de amizade pendente.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          if (state.pendingReceived.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AccessibleButton(
                                label: 'Aceitar Todas (${state.pendingReceived.length})',
                                icon: Icons.done_all,
                                onPressed: () {
                                  context.read<SocialBloc>().add(AcceptAllPendingRequestsEvent());
                                  SemanticsHelper.announce('Aceitando todas as solicitações de amizade');
                                },
                              ),
                            ),
                          ...state.pendingReceived.map(
                            (req) => AccessibleCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.secondaryContainer,
                                        child: Text(
                                          req.peer.name.isNotEmpty ? req.peer.name[0].toUpperCase() : 'U',
                                          style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${req.peer.name} (${req.peer.handle}) quer se conectar',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AccessibleButton(
                                          label: 'Recusar',
                                          isSecondary: true,
                                          onPressed: () {
                                            context.read<SocialBloc>().add(
                                                  UpdateConnectionStatusEvent(
                                                    connectionId: req.id,
                                                    status: 'DECLINED',
                                                  ),
                                                );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: AccessibleButton(
                                          label: 'Aceitar',
                                          onPressed: () {
                                            context.read<SocialBloc>().add(
                                                  UpdateConnectionStatusEvent(
                                                    connectionId: req.id,
                                                    status: 'ACCEPTED',
                                                  ),
                                                );
                                            SemanticsHelper.announce('Solicitação de amizade aceita!');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                // 3. Recommendations Tab
                state.recommendations.isEmpty
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
                                child: const Icon(Icons.explore_outlined, size: 54, color: AppColors.textHint),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma recomendação disponível no momento.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.recommendations.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, i) {
                          final rec = state.recommendations[i];
                          return AccessibleCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.secondaryContainer,
                                  child: Text(
                                    rec.name.isNotEmpty ? rec.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: AppColors.accentTeal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rec.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rec.handle,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textHint,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                AccessibleButton(
                                  label: 'Conectar',
                                  icon: Icons.person_add_alt_1,
                                  minHeight: 40,
                                  onPressed: () {
                                    context.read<SocialBloc>().add(
                                          SendConnectionRequestEvent(rec.id),
                                        );
                                    SemanticsHelper.announce('Solicitação enviada para ${rec.name}');
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
