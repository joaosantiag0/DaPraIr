import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin/admin_users_bloc.dart';
import '../../../domain/entities/user_penalty.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    context.read<AdminUsersBloc>().add(
          LoadUsersEvent(
            status: _selectedStatus,
            query: _searchController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUsersBloc, AdminUsersState>(
      listener: (context, state) {
        if (state is AdminUsersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AdminUsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
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
                            hintText: 'Buscar usuários por nome, email ou @handle...',
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
                        label: 'Buscar usuários cadastrados',
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
                      children: ['TODOS', 'ACTIVE', 'WARNED', 'SUSPENDED', 'BANNED'].map((s) {
                        final isSelected =
                            (s == 'TODOS' && _selectedStatus == null) || _selectedStatus == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(s),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedStatus = s == 'TODOS' ? null : s);
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
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state is AdminUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AdminUsersLoaded) {
                    final users = state.users;
                    if (users.isEmpty) {
                      return const Center(
                        child: Text('Nenhum usuário encontrado com os filtros aplicados.'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _UserCard(user: users[index]);
                      },
                    );
                  }

                  return Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
                      onPressed: _triggerSearch,
                      child: const Text('Carregar Usuários'),
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

class _UserCard extends StatelessWidget {
  final AdminUserSummary user;

  const _UserCard({required this.user});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green.shade800;
      case 'WARNED':
        return Colors.amber.shade900;
      case 'SUSPENDED':
        return Colors.orange.shade900;
      case 'BANNED':
        return Colors.red.shade900;
      default:
        return Colors.grey.shade700;
    }
  }

  void _showPenaltyModal(BuildContext context) {
    String selectedType = 'WARNING';
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text('Aplicar Sanção a @${user.handle}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecione a modalidade da penalidade progressiva:'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(
                        value: 'WARNING',
                        child: Text('1ª Advertência formal (sem bloqueio)'),
                      ),
                      DropdownMenuItem(
                        value: 'SUSPENSION_7_DAYS',
                        child: Text('2ª Suspensão temporária (7 dias)'),
                      ),
                      DropdownMenuItem(
                        value: 'PERMANENT_BAN',
                        child: Text('3ª Banimento permanente definitivo'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Motivo obrigatório (mínimo 10 caracteres)',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedType == 'PERMANENT_BAN'
                      ? Colors.red.shade800
                      : Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(88, 48),
                ),
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('O motivo da penalidade deve ter no mínimo 10 caracteres.'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(dialogCtx).pop();
                  context.read<AdminUsersBloc>().add(
                        ApplyUserPenaltyEvent(
                          userId: user.id,
                          penaltyType: selectedType,
                          reason: reason,
                        ),
                      );
                },
                child: const Text('Aplicar Sanção'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(
                    '${user.name} (@${user.handle})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(user.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Email: ${user.email} • Papel: ${user.role}'),
            const SizedBox(height: 4),
            Text(
              'Penalidades acumuladas: ${user.penaltiesCount}',
              style: TextStyle(
                color: user.penaltiesCount > 0 ? Colors.red.shade900 : Colors.grey.shade700,
                fontWeight: user.penaltiesCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Semantics(
                  button: true,
                  label: 'Aplicar sanção ou banimento a ${user.name}',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 48),
                    ),
                    icon: const Icon(Icons.gavel),
                    label: const Text('Aplicar Sanção'),
                    onPressed: user.role == 'ADMIN' ? null : () => _showPenaltyModal(context),
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
