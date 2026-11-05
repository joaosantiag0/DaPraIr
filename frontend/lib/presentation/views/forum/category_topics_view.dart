import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/forum/forum_bloc.dart';
import '../../bloc/forum/forum_event.dart';
import '../../bloc/forum/forum_state.dart';
import '../../components/forum_topic_tile.dart';
import '../../components/guest_action_dialog.dart';
import 'topic_detail_view.dart';
import 'create_topic_view.dart';
import '../../../domain/entities/forum_category.dart';

class CategoryTopicsView extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final bool isAuthenticated;
  final VoidCallback? onNavigateToLogin;

  const CategoryTopicsView({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.isAuthenticated = false,
    this.onNavigateToLogin,
  });

  @override
  State<CategoryTopicsView> createState() => _CategoryTopicsViewState();
}

class _CategoryTopicsViewState extends State<CategoryTopicsView> {
  String _selectedSort = 'recent';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  void _loadTopics() {
    context.read<ForumBloc>().add(
          LoadCategoryTopicsEvent(
            categoryId: widget.categoryId,
            sortBy: _selectedSort,
            query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
          ),
        );
  }

  void _onSortChanged(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _loadTopics();
  }

  void _onRequireLogin(String actionTitle) {
    GuestActionDialog.show(
      context: context,
      actionTitle: actionTitle,
      onLoginPressed: () {
        Navigator.of(context).pop();
        if (widget.onNavigateToLogin != null) {
          widget.onNavigateToLogin!();
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar debates nesta categoria...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadTopics();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onSubmitted: (_) => _loadTopics(),
                ),
                const SizedBox(height: 10),

                // Sort Filter Chips (Min touch target 48x48 dp via constraints or padding)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('recent', 'Recentes', Icons.access_time),
                      const SizedBox(width: 8),
                      _buildSortChip('likes', 'Mais Curtidos', Icons.thumb_up_alt_outlined),
                      const SizedBox(width: 8),
                      _buildSortChip('comments', 'Mais Comentados', Icons.chat_bubble_outline),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Topics List
          Expanded(
            child: BlocConsumer<ForumBloc, ForumState>(
              listener: (context, state) {
                if (state is ForumError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700),
                  );
                }
              },
              builder: (context, state) {
                if (state is CategoryTopicsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CategoryTopicsLoaded) {
                  if (state.topics.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.forum_outlined, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum debate encontrado nesta categoria.',
                            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _openCreateTopic(),
                            icon: const Icon(Icons.add),
                            label: const Text('Iniciar o Primeiro Debate'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadTopics(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.topics.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final topic = state.topics[index];
                        return ForumTopicTile(
                          topic: topic,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ForumBloc>(),
                                  child: TopicDetailView(
                                    topicId: topic.id,
                                    isAuthenticated: widget.isAuthenticated,
                                    onNavigateToLogin: widget.onNavigateToLogin,
                                  ),
                                ),
                              ),
                            );
                          },
                          onLikeTap: () {
                            if (!widget.isAuthenticated) {
                              _onRequireLogin('curtir debates');
                            } else {
                              context.read<ForumBloc>().add(ToggleTopicLikeEvent(topicId: topic.id));
                            }
                          },
                        );
                      },
                    ),
                  );
                }

                return Center(
                  child: ElevatedButton(
                    onPressed: _loadTopics,
                    child: const Text('Carregar Debates'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Criar debate nesta categoria',
        child: FloatingActionButton.extended(
          onPressed: _openCreateTopic,
          icon: const Icon(Icons.add),
          label: const Text('Novo Debate'),
        ),
      ),
    );
  }

  void _openCreateTopic() {
    if (!widget.isAuthenticated) {
      _onRequireLogin('abrir novos debates');
      return;
    }

    final singleCat = ForumCategory(
      id: widget.categoryId,
      name: widget.categoryName,
      slug: widget.categoryName.toLowerCase().replaceAll(' ', '-'),
      description: '',
      iconName: 'forum',
      displayOrder: 0,
      isActive: true,
      topicsCount: 0,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ForumBloc>(),
          child: CreateTopicView(
            categories: [singleCat],
            preselectedCategoryId: widget.categoryId,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String sortKey, String label, IconData icon) {
    final isSelected = _selectedSort == sortKey;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF334155)),
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0D47A1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF334155),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      onSelected: (_) => _onSortChanged(sortKey),
    );
  }
}
