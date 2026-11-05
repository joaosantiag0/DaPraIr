import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/forum/forum_bloc.dart';
import '../../bloc/forum/forum_event.dart';
import '../../bloc/forum/forum_state.dart';
import '../../components/forum_category_card.dart';
import '../../components/forum_topic_tile.dart';
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
