import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin/admin_content_bloc.dart';
import '../../../domain/entities/unified_content.dart';

class AdminContentView extends StatefulWidget {
  const AdminContentView({super.key});

  @override
  State<AdminContentView> createState() => _AdminContentViewState();
}

class _AdminContentViewState extends State<AdminContentView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    context.read<AdminContentBloc>().add(
          LoadContentEvent(
            type: _selectedType == 'ALL' ? null : _selectedType,
            query: _searchController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminContentBloc, AdminContentState>(
      listener: (context, state) {
        if (state is AdminContentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AdminContentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Buscar publicações por título ou conteúdo...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _triggerSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        button: true,
                        label: 'Buscar conteúdos',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
                          onPressed: _triggerSearch,
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['ALL', 'FORUM_TOPIC', 'FORUM_COMMENT', 'PLACE_REVIEW'].map((t) {
                        final isSelected = _selectedType == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(t),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedType = t);
                                _triggerSearch();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content list
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state is AdminContentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AdminContentLoaded) {
                    final items = state.items;
                    if (items.isEmpty) {
                      return const Center(
                        child: Text('Nenhum conteúdo encontrado para os filtros aplicados.'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ContentCard(item: items[index]);
                      },
                    );
                  }

                  return Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
                      onPressed: _triggerSearch,
                      child: const Text('Carregar Conteúdos'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ContentCard extends StatelessWidget {
  final UnifiedContent item;

  const _ContentCard({required this.item});

  void _showReasonDialog(BuildContext context, String action) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(action == 'HIDE' ? 'Ocultar Conteúdo' : 'Excluir Conteúdo em Cascata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action == 'HIDE'
                  ? 'O conteúdo e subthreads subordinadas sairão da circulação pública (reversível).'
                  : 'ATENÇÃO: A exclusão removerá o conteúdo e todas as respostas filhas em cascata de forma permanente.',
              style: TextStyle(
                color: action == 'DELETE' ? Colors.red.shade900 : Colors.black87,
                fontWeight: action == 'DELETE' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Justificativa mandatória (mínimo 10 caracteres)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'DELETE' ? Colors.red.shade800 : Colors.blue.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(88, 48),
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('A justificativa deve ter no mínimo 10 caracteres.')),
                );
                return;
              }
              Navigator.of(dialogCtx).pop();

              if (action == 'HIDE') {
                context.read<AdminContentBloc>().add(
                      HideContentEvent(type: item.type, id: item.id, reason: reason),
                    );
              } else if (action == 'DELETE') {
                context.read<AdminContentBloc>().add(
                      DeleteContentEvent(type: item.type, id: item.id, reason: reason),
                    );
              }
            },
            child: Text(action == 'DELETE' ? 'Excluir Definitivo' : 'Ocultar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHidden = item.status == 'HIDDEN_BY_ADMIN' || item.status == 'HIDDEN';
    final isRemoved = item.status == 'REMOVED_BY_ADMIN' || item.status == 'REMOVED';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text(item.type)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRemoved
                        ? Colors.red.shade900
                        : isHidden
                            ? Colors.orange.shade900
                            : Colors.green.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.titleOrSnippet,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              item.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              'Autor: ${item.authorName ?? 'Desconhecido'} (@${item.authorHandle ?? 'anon'})',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isHidden)
                  Semantics(
                    button: true,
                    label: 'Restaurar conteúdo para público',
                    child: TextButton.icon(
                      style: TextButton.styleFrom(minimumSize: const Size(100, 48)),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Restaurar'),
                      onPressed: () {
                        context.read<AdminContentBloc>().add(
                              RestoreContentEvent(
                                type: item.type,
                                id: item.id,
                                reason: 'Restauração manual aprovada pelo moderador.',
                              ),
                            );
                      },
                    ),
                  )
                else if (!isRemoved)
                  Semantics(
                    button: true,
                    label: 'Ocultar publicação',
                    child: TextButton.icon(
                      style: TextButton.styleFrom(minimumSize: const Size(100, 48)),
                      icon: const Icon(Icons.visibility_off),
                      label: const Text('Ocultar'),
                      onPressed: () => _showReasonDialog(context, 'HIDE'),
                    ),
                  ),
                const SizedBox(width: 8),
                if (!isRemoved)
                  Semantics(
                    button: true,
                    label: 'Excluir conteúdo permanentemente com cascata',
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade800,
                        minimumSize: const Size(100, 48),
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Excluir'),
                      onPressed: () => _showReasonDialog(context, 'DELETE'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
