import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/forum/forum_bloc.dart';
import '../../bloc/forum/forum_event.dart';
import '../../bloc/forum/forum_state.dart';
import '../../../domain/entities/forum_category.dart';
import '../../components/visibility_badge.dart';

class CreateTopicView extends StatefulWidget {
  final List<ForumCategory> categories;
  final String? preselectedCategoryId;

  const CreateTopicView({
    super.key,
    required this.categories,
    this.preselectedCategoryId,
  });

  @override
  State<CreateTopicView> createState() => _CreateTopicViewState();
}

class _CreateTopicViewState extends State<CreateTopicView> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedCategoryId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedVisibility = 'PUBLIC';

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.preselectedCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma categoria temática')),
        );
        return;
      }

      context.read<ForumBloc>().add(
            CreateTopicEvent(
              categoryId: _selectedCategoryId!,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              visibility: _selectedVisibility,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Novo Debate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state is TopicCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Debate publicado com sucesso!'),
                backgroundColor: Color(0xFF15803D),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ForumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is TopicCreating;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Category Picker
                if (widget.categories.isNotEmpty) ...[
                  const Text(
                    'Categoria Temática',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: widget.categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) => val == null ? 'Selecione uma categoria' : null,
                  ),
                  const SizedBox(height: 20),
                ],

                // Title Input
                const Text(
                  'Título da Discussão',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Rampas de acesso em novas linhas de ônibus...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 5) {
                      return 'O título deve ter no mínimo 5 caracteres';
                    }
                    if (val.trim().length > 200) {
                      return 'O título não pode ultrapassar 200 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Content Input
                const Text(
                  'Conteúdo do Debate',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Compartilhe suas observações, experiências e sugestões de acessibilidade...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 10) {
                      return 'O conteúdo deve ter no mínimo 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Visibility Selector
                const Text(
                  'Nível de Visibilidade',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'PUBLIC',
                        groupValue: _selectedVisibility,
                        title: const Row(
                          children: [
                            Text('Público', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            VisibilityBadge(visibility: 'PUBLIC', isCompact: true),
                          ],
                        ),
                        subtitle: const Text('Visível para todos e visitantes anônimos.'),
                        onChanged: (val) => setState(() => _selectedVisibility = val!),
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        value: 'COMMUNITY',
                        groupValue: _selectedVisibility,
                        title: const Row(
                          children: [
                            Text('Comunidade', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            VisibilityBadge(visibility: 'COMMUNITY', isCompact: true),
                          ],
                        ),
                        subtitle: const Text('Restrito a membros cadastrados da plataforma.'),
                        onChanged: (val) => setState(() => _selectedVisibility = val!),
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        value: 'AUTHOR',
                        groupValue: _selectedVisibility,
                        title: const Row(
                          children: [
                            Text('Privado', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            VisibilityBadge(visibility: 'AUTHOR', isCompact: true),
                          ],
                        ),
                        subtitle: const Text('Visível apenas para você (rascunho / anotação).'),
                        onChanged: (val) => setState(() => _selectedVisibility = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Publicar Debate',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
