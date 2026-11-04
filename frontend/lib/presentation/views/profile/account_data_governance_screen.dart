import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/responsive_container.dart';

class AccountDataGovernanceScreen extends StatelessWidget {
  const AccountDataGovernanceScreen({super.key});

  void _showAnonymizeConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warningOrange, size: 26),
            SizedBox(width: 8),
            Expanded(child: Text('Confirmar Exclusão e Anonimização?')),
          ],
        ),
        content: const Text(
          'Todos os seus dados pessoais identificáveis (nome, e-mail, perfil de saúde) serão definitivamente apagados ou desvinculados. Suas avaliações públicas serão mantidas com autoria anônima para preservar a utilidade comunitária.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warningOrange),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(AnonymizeAccountEvent());
            },
            child: const Text('Anonimizar e Excluir Minha Conta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Dados e Conta'),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            if (state.anonymizeSuccess) {
              SemanticsHelper.announce('Sua conta foi anonimizada e seus dados foram apagados.');
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.of(context).pop();
            }
            if (state.exportedData != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Pacote de dados pessoais exportado com sucesso!'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ResponsiveContainer.medium(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informative Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppColors.primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Direitos do Titular de Dados',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Você possui controle integral sobre seus dados pessoais cadastrados.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Portability Section (Art. 18, V)
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderLight, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  'Portabilidade de Dados (Art. 18, V)',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Baixe uma cópia estruturada em formato aberto (JSON) de todos os seus dados cadastrais, consentimentos e histórico.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 16),
                        AccessibleButton(
                          label: 'Exportar Meus Dados em JSON',
                          icon: Icons.download_rounded,
                          isSecondary: true,
                          onPressed: () {
                            context.read<ProfileBloc>().add(ExportDataEvent());
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Right to be forgotten (Danger Zone - Art. 18, VI)
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.warningOrange.withValues(alpha: 0.3), width: 1.2),
                  ),
                  color: AppColors.warningLight.withValues(alpha: 0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.delete_forever_rounded, color: AppColors.warningOrange, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  'Direito ao Esquecimento (Art. 18, VI)',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.warningOrange,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Solicite a exclusão de sua conta e a anonimização permanente de seus dados.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 16),
                        AccessibleButton(
                          label: 'Anonimizar e Excluir Minha Conta',
                          icon: Icons.delete_forever,
                          isSecondary: true,
                          onPressed: () => _showAnonymizeConfirmation(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}
