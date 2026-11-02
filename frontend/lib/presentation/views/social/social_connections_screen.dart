import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/social/social_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_card.dart';
import 'chat_conversation_screen.dart';

class SocialConnectionsScreen extends StatefulWidget {
  const SocialConnectionsScreen({super.key});

  @override
  State<SocialConnectionsScreen> createState() => _SocialConnectionsScreenState();
}

class _SocialConnectionsScreenState extends State<SocialConnectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<SocialBloc>().add(LoadSocialDataEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidade e Amigos'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.hcPrimaryYellow,
          tabs: const [
            Tab(text: 'Amigos'),
            Tab(text: 'Solicitações'),
            Tab(text: 'Sugestões'),
          ],
        ),
      ),
      body: BlocBuilder<SocialBloc, SocialState>(
        builder: (context, state) {
          if (state is SocialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SocialError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erro ao carregar conexões: ${state.message}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    AccessibleButton(
                      label: 'Tentar Novamente',
                      onPressed: () => context.read<SocialBloc>().add(LoadSocialDataEvent()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SocialLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                // 1. Friends Tab
                state.friends.isEmpty
                    ? const Center(child: Text('Você ainda não tem amigos conectados.'))
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
                                  backgroundColor: AppColors.primaryBlue,
                                  child: Text(friend.peer.name.isNotEmpty ? friend.peer.name[0] : 'U'),
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
                                      Text(
                                        friend.peer.handle,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chat_bubble_outline, color: AppColors.primaryBlue),
                              ],
                            ),
                          );
                        },
                      ),

                // 2. Pending Requests Tab
                state.pendingReceived.isEmpty
                    ? const Center(child: Text('Nenhuma solicitação de amizade pendente.'))
                    : ListView.builder(
                        itemCount: state.pendingReceived.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, i) {
                          final req = state.pendingReceived[i];
                          return AccessibleCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${req.peer.name} (${req.peer.handle}) quer se conectar',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 12),
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
                          );
                        },
                      ),

                // 3. Recommendations Tab
                state.recommendations.isEmpty
                    ? const Center(child: Text('Nenhuma recomendação disponível no momento.'))
                    : ListView.builder(
                        itemCount: state.recommendations.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, i) {
                          final rec = state.recommendations[i];
                          return AccessibleCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.accentTeal,
                                  child: Text(rec.name.isNotEmpty ? rec.name[0] : 'U'),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rec.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        rec.handle,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                AccessibleButton(
                                  label: 'Conectar',
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
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
