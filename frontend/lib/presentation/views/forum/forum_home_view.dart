import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/forum/forum_bloc.dart';
import '../../bloc/forum/forum_event.dart';
import '../../bloc/forum/forum_state.dart';
import '../../components/forum_category_card.dart';
import '../../components/forum_topic_tile.dart';
import '../../components/community_rules_sheet.dart';
import 'category_topics_view.dart';
import 'topic_detail_view.dart';
import 'create_topic_view.dart';

class ForumHomeView extends StatefulWidget {
  final bool isAuthenticated;
  final VoidCallback? onNavigateToLogin;

  const ForumHomeView({
    super.key,
    this.isAuthenticated = false,
    this.onNavigateToLogin,
  });

  @override
  State<ForumHomeView> createState() => _ForumHomeViewState();
}

class _ForumHomeViewState extends State<ForumHomeView> {
  @override
  void initState() {
    super.initState();
    context.read<ForumBloc>().add(const LoadForumHomeEvent());
  }

  void _onCategoryTap(String categoryId, String categoryName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ForumBloc>(),
          child: CategoryTopicsView(
            categoryId: categoryId,
            categoryName: categoryName,
            isAuthenticated: widget.isAuthenticated,
            onNavigateToLogin: widget.onNavigateToLogin,
          ),
        ),
      ),
    );
  }

  void _onTopicTap(String topicId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ForumBloc>(),
          child: TopicDetailView(
            topicId: topicId,
            isAuthenticated: widget.isAuthenticated,
            onNavigateToLogin: widget.onNavigateToLogin,
          ),
        ),
      ),
    );
  }

  void _onOpenCreateTopic(List<dynamic> categories) {
    if (!widget.isAuthenticated && widget.onNavigateToLogin != null) {
      widget.onNavigateToLogin!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ForumBloc>(),
          child: CreateTopicView(
            categories: categories.cast(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fórum e Debates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rule_folder_outlined),
            tooltip: 'Regras da Comunidade',
            onPressed: () => CommunityRulesSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar fórum',
            onPressed: () => context.read<ForumBloc>().add(const LoadForumHomeEvent()),
          ),
        ],
      ),
      body: BlocConsumer<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state is ForumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700),
            );
          }
        },
        builder: (context, state) {
          if (state is ForumHomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ForumHomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ForumBloc>().add(const LoadForumHomeEvent());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Freedom of Discussion & Rules Card
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.forum_outlined, color: Color(0xFF15803D), size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Espaço Livre para Conversar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => CommunityRulesSheet.show(context),
                              icon: const Icon(Icons.info_outline, size: 16, color: Color(0xFF15803D)),
                              label: const Text(
                                'Regras',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: const Size(48, 36),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Aqui você pode conversar e debater sobre qualquer assunto que quiser — vivências, rotas, dicas, cotidiano, amizade ou lazer —, desde que respeite as regras de convivência da comunidade.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Categories Section Header
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 12),
                    child: Text(
                      'Categorias Temáticas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  // Categories List
                  ...state.categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ForumCategoryCard(
                        category: cat,
                        onTap: () => _onCategoryTap(cat.id, cat.name),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Highlighted Topics Section Header
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 12),
                    child: Text(
                      'Discussões Recentes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  // Highlighted Topics List
                  if (state.highlightedTopics.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Nenhuma discussão recente encontrada.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    ...state.highlightedTopics.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ForumTopicTile(
                          topic: t,
                          onTap: () => _onTopicTap(t.id),
                          onLikeTap: () {
                            if (!widget.isAuthenticated && widget.onNavigateToLogin != null) {
                              widget.onNavigateToLogin!();
                            } else {
                              context.read<ForumBloc>().add(ToggleTopicLikeEvent(topicId: t.id));
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<ForumBloc>().add(const LoadForumHomeEvent()),
              child: const Text('Carregar Fórum'),
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          final categories = state is ForumHomeLoaded ? state.categories : [];
          return Semantics(
            button: true,
            label: 'Abrir novo debate no fórum',
            child: FloatingActionButton.extended(
              onPressed: () => _onOpenCreateTopic(categories),
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Novo Debate'),
            ),
          );
        },
      ),
    );
  }
}
